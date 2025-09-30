import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/client_model.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_helper.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];
  List<Client> _filteredClients = [];

  List<Client> get clients => _filteredClients;

  String _searchTerm = '';
  String _filterStatus = 'all';

  String get filterStatus => _filterStatus; // Getter for filterStatus

  Future<void> loadClients() async {
    _clients = await DatabaseHelper().getClients();
    _applyFilters();
  }

  Future<void> addClient(Client client) async {
    final newId = await DatabaseHelper().addClient(client);
    client.id = newId;
    await NotificationHelper.scheduleExpirationNotifications(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await DatabaseHelper().updateClient(client);
    await NotificationHelper.scheduleExpirationNotifications(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await DatabaseHelper().deleteClient(id);
    await NotificationHelper.cancelNotificationsForClient(id);
    await loadClients();
  }

  Future<void> rescheduleAllNotifications() async {
    final clients = await DatabaseHelper().getClients();
    developer.log(
        'Loaded ${clients.length} clients to reschedule notifications.',
        name: 'my_app.client_provider');
    for (var client in clients) {
      developer.log('Scheduling notifications for client: ${client.name}',
          name: 'my_app.client_provider');
      await NotificationHelper.scheduleExpirationNotifications(client);
    }
  }

  Future<String> importClientsFromCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.single.path == null) {
      throw 'No se seleccionó ningún archivo.';
    }

    final filePath = result.files.single.path!;
    final file = File(filePath);

    try {
      final input = file.openRead();
      final fields = await input
          .transform(utf8.decoder)
          .transform(const CsvToListConverter())
          .toList();

      if (fields.length <= 1) {
        throw 'El archivo CSV está vacío o solo contiene la cabecera.';
      }

      int importedCount = 0;
      for (var i = 1; i < fields.length; i++) {
        final row = fields[i];
        if (row.length >= 9) {
          final client = Client(
            name: row[0].toString(),
            lastName: row[1].toString(),
            username: row[2].toString(),
            password: row[3].toString(),
            phone: row[4].toString(),
            startDate: DateTime.parse(row[5].toString()),
            endDate: DateTime.parse(row[6].toString()),
            months: int.parse(row[7].toString()),
            price: double.parse(row[8].toString()),
            referredBy: row.length > 9 ? row[9].toString() : null,
          );
          await addClient(client);
          importedCount++;
        }
      }
      return '$importedCount clientes importados correctamente.';
    } catch (e) {
      developer.log('Error parsing CSV file: $e',
          name: 'my_app.client_provider');
      throw 'Formato de archivo CSV no válido. Asegúrate de que las columnas y los tipos de datos son correctos.';
    }
  }

  Future<String> exportClientsToCsv() async {
    if (_clients.isEmpty) {
      throw 'No hay clientes para exportar.';
    }

    List<List<dynamic>> rows = [];
    rows.add([
      "name",
      "lastName",
      "username",
      "password",
      "phone",
      "startDate",
      "endDate",
      "months",
      "price",
      "referredBy"
    ]);

    for (var client in _clients) {
      rows.add([
        client.name,
        client.lastName,
        client.username,
        client.password,
        client.phone,
        client.startDate.toIso8601String(),
        client.endDate.toIso8601String(),
        client.months,
        client.price,
        client.referredBy ?? ''
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/clientes_exportados.csv';
      final file = File(path);

      await file.writeAsString(csv);

      // ignore: deprecated_member_use
      await Share.shareXFiles([XFile(path)],
          text: 'Aquí está la lista de clientes exportados.');

      return 'Clientes exportados y listos para compartir.';
    } catch (e) {
      developer.log('Error exporting CSV file: $e',
          name: 'my_app.client_provider');
      throw 'No se pudo generar o compartir el archivo CSV.';
    }
  }

  void searchClients(String searchTerm) {
    _searchTerm = searchTerm;
    _applyFilters();
  }

  void filterByStatus(String filterStatus) {
    _filterStatus = filterStatus;
    _applyFilters();
  }

  void _applyFilters() {
    List<Client> tempClients = List.from(_clients);
    final today = DateUtils.dateOnly(DateTime.now());

    if (_filterStatus == 'expired') {
      tempClients = tempClients.where((client) {
        final endDate = DateUtils.dateOnly(client.endDate);
        return endDate.isBefore(today);
      }).toList();
    } else if (_filterStatus == 'expiring_soon') {
      tempClients = tempClients.where((client) {
        final endDate = DateUtils.dateOnly(client.endDate);
        final differenceInDays = endDate.difference(today).inDays;
        return differenceInDays >= 0 && differenceInDays <= 7;
      }).toList();
    }

    if (_searchTerm.isNotEmpty) {
      tempClients = tempClients.where((client) {
        final searchTermLower = _searchTerm.toLowerCase();
        return client.name.toLowerCase().contains(searchTermLower) ||
            client.lastName.toLowerCase().contains(searchTermLower) ||
            client.username.toLowerCase().contains(searchTermLower);
      }).toList();
    }

    _filteredClients = tempClients;
    notifyListeners();
  }
}
