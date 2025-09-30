import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/client_provider.dart';
import '../helpers/csv_helper.dart';
import '../models/client_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<void> _exportAndShowSnackBar(List<Client> clients) async {
    final path = await CsvHelper.exportToCsv(clients);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV exportado a: $path')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final clients = clientProvider.clients;

    final activeClients = clients.where((c) => c.endDate.isAfter(DateTime.now())).toList();
    final expiredClients = clients.where((c) => c.endDate.isBefore(DateTime.now())).toList();
    final newClientsThisMonth = clients.where((c) {
      final now = DateTime.now();
      return c.startDate.year == now.year && c.startDate.month == now.month;
    }).toList();
    final referredClients = clients.where((c) => c.referredBy != null && c.referredBy!.isNotEmpty).toList();

    final double monthlyRecurringRevenue = activeClients.fold(0.0, (sum, client) => sum + client.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMetricCard(
            context,
            title: 'Ingresos mensuales',
            value: '\$${monthlyRecurringRevenue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            title: 'Clientes Activos',
            value: activeClients.length.toString(),
            icon: Icons.person,
            color: Colors.blue,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            title: 'Clientes Expirados',
            value: expiredClients.length.toString(),
            icon: Icons.person_off,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            title: 'Nuevos Clientes (Este Mes)',
            value: newClientsThisMonth.length.toString(),
            icon: Icons.person_add,
            color: Colors.purple,
          ),
          const SizedBox(height: 16),
          _buildMetricCard(
            context,
            title: 'Clientes Referidos',
            value: referredClients.length.toString(),
            icon: Icons.group,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}