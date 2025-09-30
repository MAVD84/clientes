import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/client_provider.dart';
import '../models/client_model.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);
    final clients = clientProvider.clients;

    // --- Data Calculation ---
    final activeClients = clients.where((c) => c.endDate.isAfter(DateTime.now())).toList();
    final expiredClients = clients.where((c) => c.endDate.isBefore(DateTime.now())).toList();

    final double monthlyRecurringRevenue = activeClients.fold(0.0, (sum, client) => sum + client.price);

    final Map<String, double> revenueByMonth = _calculateMonthlyRevenue(clients);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analítica'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMetricCard(
            context,
            title: 'Ingresos Mensuales Actuales (MRR)',
            value: '\$${monthlyRecurringRevenue.toStringAsFixed(2)}',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          _buildClientDistributionChart(context, activeClients.length, expiredClients.length),
          const SizedBox(height: 24),
          _buildRevenueTrendChart(context, revenueByMonth),
        ],
      ),
    );
  }

  Map<String, double> _calculateMonthlyRevenue(List<Client> clients) {
    final Map<int, double> monthlyTotals = {};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyTotals[month.month] = 0.0;
    }

    for (final client in clients) {
      for (int i = 0; i < client.months; i++) {
        final paymentMonth = DateTime(client.startDate.year, client.startDate.month + i, 1);
        if (monthlyTotals.containsKey(paymentMonth.month)) {
          monthlyTotals[paymentMonth.month] = (monthlyTotals[paymentMonth.month] ?? 0) + (client.price / client.months);
        }
      }
    }

    final DateFormat formatter = DateFormat.MMM('es');
    final Map<String, double> formattedData = {};
    monthlyTotals.forEach((month, total) {
      final monthDate = DateTime(now.year, month);
      formattedData[formatter.format(monthDate)] = total;
    });

    return formattedData;
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
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientDistributionChart(BuildContext context, int activeCount, int expiredCount) {
    final totalClients = activeCount + expiredCount;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Distribución de Clientes', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: activeCount.toDouble(),
                      title: '${(activeCount / totalClients * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.red,
                      value: expiredCount.toDouble(),
                      title: '${(expiredCount / totalClients * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Activos ($activeCount)'),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.red, 'Expirados ($expiredCount)'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueTrendChart(BuildContext context, Map<String, double> revenueData) {
    final List<FlSpot> spots = [];
    revenueData.entries.toList().asMap().forEach((index, entry) {
      spots.add(FlSpot(index.toDouble(), entry.value));
    });

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tendencia de Ingresos (Últimos 6 Meses)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final titles = revenueData.keys.toList();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 10,
                            child: Text(titles[value.toInt()], style: const TextStyle(fontSize: 12)),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.deepPurple,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
