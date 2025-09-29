import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';
import 'add_edit_client_screen.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<ClientProvider>(context, listen: false).loadClients();
  }

  void _showDeleteConfirmationDialog(BuildContext context, Client client) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de que deseas eliminar a ${client.name} ${client.lastName}?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: const Text('Eliminar'),
              onPressed: () {
                Provider.of<ClientProvider>(context, listen: false).deleteClient(client.id!);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showClientDetailsDialog(BuildContext context, Client client) {
    final remainingDays = client.endDate.difference(DateTime.now()).inDays;
    final statusText = remainingDays <= 0 ? 'Expirado' : '$remainingDays días restantes';
    final statusColor = remainingDays <= 7 ? Colors.red : Colors.green;

    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('${client.name} ${client.lastName}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Usuario: ${client.username}'),
                Text('Contraseña: ${client.password}'),
                const SizedBox(height: 8),
                Text('Teléfono: ${client.phone}'),
                if (client.referredBy != null && client.referredBy!.isNotEmpty)
                  Text('Referido por: ${client.referredBy}'),
                const Divider(height: 20),
                Text('Suscripción: ${DateFormat.yMd().format(client.startDate)} - ${DateFormat.yMd().format(client.endDate)}'),
                Text('Meses: ${client.months}'),
                Text('Precio: \$${client.price.toStringAsFixed(2)}'),
                const Divider(height: 20),
                Text(
                  statusText,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes IPTV'),
      ),
      body: Consumer<ClientProvider>(
        builder: (context, clientProvider, child) {
          if (clientProvider.clients.isEmpty) {
            return const Center(
              child: Text(
                'No hay clientes todavía.\n¡Añade uno para empezar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: clientProvider.clients.length,
            itemBuilder: (context, index) {
              Client client = clientProvider.clients[index];
              final remainingDays = client.endDate.difference(DateTime.now()).inDays;
              final tileColor = remainingDays <= 0
                  ? Colors.red.withAlpha(25)
                  : remainingDays <= 7
                      ? Colors.orange.withAlpha(25)
                      : null;
              final statusText = remainingDays <= 0 ? 'Expirado' : '$remainingDays días restantes';
              final statusColor = remainingDays <= 7 ? Colors.red : Colors.green;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                color: tileColor,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  title: Text(
                    '${client.name} ${client.lastName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4.0),
                      Text('Usuario: ${client.username}'),
                      Text('Teléfono: ${client.phone}'),
                      if (client.referredBy != null && client.referredBy!.isNotEmpty)
                        Text('Referido por: ${client.referredBy}'),
                      const SizedBox(height: 4.0),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AddEditClientScreen(client: client),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, client);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Editar'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Eliminar'),
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    _showClientDetailsDialog(context, client);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AddEditClientScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
