import 'package:flutter/material.dart';
import '../models/client_model.dart';
import '../helpers/database_helper.dart';

class ClientProvider with ChangeNotifier {
  List<Client> _clients = [];

  List<Client> get clients => _clients;

  Future<void> loadClients() async {
    _clients = await DatabaseHelper().getClients();
    notifyListeners();
  }

  Future<void> addClient(Client client) async {
    await DatabaseHelper().addClient(client);
    await loadClients();
  }

  Future<void> updateClient(Client client) async {
    await DatabaseHelper().updateClient(client);
    await loadClients();
  }

  Future<void> deleteClient(int id) async {
    await DatabaseHelper().deleteClient(id);
    await loadClients();
  }
}
