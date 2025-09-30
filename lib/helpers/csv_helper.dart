import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/client_model.dart';

class CsvHelper {
  static Future<String> exportToCsv(List<Client> clients) async {
    final List<List<dynamic>> rows = [];
    // Add header row
    rows.add([
      'ID',
      'Name',
      'Last Name',
      'Username',
      'Password',
      'Phone',
      'Start Date',
      'End Date',
      'Months',
      'Price',
      'Referred By'
    ]);

    // Add data rows
    for (final client in clients) {
      rows.add([
        client.id,
        client.name,
        client.lastName,
        client.username,
        client.password,
        client.phone,
        client.startDate.toIso8601String(),
        client.endDate.toIso8601String(),
        client.months,
        client.price,
        client.referredBy,
      ]);
    }

    final String csv = const ListToCsvConverter().convert(rows);
    final Directory directory = await getApplicationDocumentsDirectory();
    final String path = '${directory.path}/clients.csv';
    final File file = File(path);
    await file.writeAsString(csv);
    return path;
  }
}
