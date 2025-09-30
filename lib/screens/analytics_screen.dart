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
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    final expiredClients = clients.where((c) => DateUtils.dateOnly(c.endDate).isBefore(today)).toList();
    final expiringSoonClients = clients.where((c) {
      final endDate = DateUtils.dateOnly(c.endDate);
      final difference = endDate.difference(today).inDays;
      return difference >= 0 && difference <= 7;
    }).toList();
    final activeClients = clients.where((c) => DateUtils.dateOnly(c.endDate).difference(today).inDays > 7).toList();
    
    final referredClients = clients.where((c) => c.referredBy != null && c.referredBy!.isNotEmpty).toList();
    final nonReferredClients = clients.length - referredClients.length;

    final revenueByMonth = _calculateMonthlyRevenue(clients);
    final newClientsByMonth = _calculateNewClientsByMonth(clients);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analítica General'),
      ),
      body: clients.isEmpty
          ? const Center(
              child: Text(
                'No hay datos suficientes para mostrar analíticas.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildRevenueTrendChart(context, revenueByMonth),
                const SizedBox(height: 24),
                _buildNewClientsChart(context, newClientsByMonth),
                const SizedBox(height: 24),
                _buildClientStatusChart(context, activeClients.length, expiringSoonClients.length, expiredClients.length),
                const SizedBox(height: 24),
                _buildReferredClientsChart(context, referredClients.length, nonReferredClients),
              ],
            ),
    );
  }

  // --- Data Calculation Methods ---
  Map<String, int> _calculateNewClientsByMonth(List<Client> clients) {
    final Map<int, int> monthlyTotals = {};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyTotals[month.year * 100 + month.month] = 0;
    }

    for (final client in clients) {
      final startMonthKey = client.startDate.year * 100 + client.startDate.month;
      if (monthlyTotals.containsKey(startMonthKey)) {
        monthlyTotals[startMonthKey] = (monthlyTotals[startMonthKey] ?? 0) + 1;
      }
    }

    final DateFormat formatter = DateFormat.MMM('es');
    final Map<String, int> formattedData = {};
    final sortedKeys = monthlyTotals.keys.toList()..sort();

    for (var key in sortedKeys) {
      final year = key ~/ 100;
      final month = key % 100;
      final monthDate = DateTime(year, month);
      formattedData[formatter.format(monthDate)] = monthlyTotals[key]!;
    }

    return formattedData;
  }

  Map<String, double> _calculateMonthlyRevenue(List<Client> clients) {
    final Map<int, double> monthlyTotals = {};
    final now = DateTime.now();

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      monthlyTotals[month.year * 100 + month.month] = 0.0;
    }

    for (final client in clients) {
      for (int i = 0; i < client.months; i++) {
        final paymentMonth = DateTime(client.startDate.year, client.startDate.month + i, 1);
        final paymentMonthKey = paymentMonth.year * 100 + paymentMonth.month;
        if (monthlyTotals.containsKey(paymentMonthKey)) {
          monthlyTotals[paymentMonthKey] = (monthlyTotals[paymentMonthKey] ?? 0) + (client.price / client.months);
        }
      }
    }

    final DateFormat formatter = DateFormat.MMM('es');
    final Map<String, double> formattedData = {};
    final sortedKeys = monthlyTotals.keys.toList()..sort();

    for (var key in sortedKeys) {
      final year = key ~/ 100;
      final month = key % 100;
      final monthDate = DateTime(year, month);
      formattedData[formatter.format(monthDate)] = monthlyTotals[key]!;
    }

    return formattedData;
  }

  // --- Chart Building Methods ---
  Widget _buildRevenueTrendChart(BuildContext context, Map<String, double> revenueData) {
    final theme = Theme.of(context);
    final spots = revenueData.entries.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.value);
    }).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Tendencia de Ingresos', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final titles = revenueData.keys.toList();
                          if (value.toInt() >= titles.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(titles[value.toInt()], style: theme.textTheme.bodySmall),
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
                      color: theme.colorScheme.primary,
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withAlpha(77),
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
  
  Widget _buildNewClientsChart(BuildContext context, Map<String, int> newClientsData) {
    final theme = Theme.of(context);
    final barGroups = newClientsData.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data.value.toDouble(),
            color: theme.colorScheme.secondary,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();

    final double maxY = (newClientsData.values.isEmpty ? 0 : newClientsData.values.reduce((a, b) => a > b ? a : b)) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Nuevos Clientes por Mes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY == 0 ? 5 : maxY, // Set a default max Y if all values are 0
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
                          final titles = newClientsData.keys.toList();
                          if (value.toInt() >= titles.length) return const SizedBox.shrink();
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8.0,
                            child: Text(titles[value.toInt()], style: theme.textTheme.bodySmall),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientStatusChart(BuildContext context, int activeCount, int expiringSoonCount, int expiredCount) {
    final theme = Theme.of(context);
    final totalClients = activeCount + expiringSoonCount + expiredCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Estado de Clientes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                  sections: totalClients == 0 ? [] : [
                    PieChartSectionData(
                      color: Colors.green,
                      value: activeCount.toDouble(),
                      title: '${(activeCount / totalClients * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: expiringSoonCount.toDouble(),
                      title: '${(expiringSoonCount / totalClients * 100).toStringAsFixed(0)}%',
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
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Activos ($activeCount)'),
                _buildLegendItem(Colors.orange, 'Expira Pronto ($expiringSoonCount)'),
                _buildLegendItem(Colors.red, 'Expirados ($expiredCount)'),
              ],
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildReferredClientsChart(BuildContext context, int referredCount, int nonReferredCount) {
    final theme = Theme.of(context);
    final totalClients = referredCount + nonReferredCount;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Fuente de Clientes', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(touchCallback: (FlTouchEvent event, pieTouchResponse) {}),
                  centerSpaceRadius: 50,
                  sectionsSpace: 2,
                  sections: totalClients == 0 ? [] : [
                    PieChartSectionData(
                      color: theme.colorScheme.tertiary,
                      value: referredCount.toDouble(),
                      title: '${(referredCount / totalClients * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiary),
                    ),
                    PieChartSectionData(
                      color: Colors.grey.shade400,
                      value: nonReferredCount.toDouble(),
                      title: '${(nonReferredCount / totalClients * 100).toStringAsFixed(0)}%',
                      radius: 50,
                      titleStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLegendItem(theme.colorScheme.tertiary, 'Referidos ($referredCount)'),
                _buildLegendItem(Colors.grey.shade400, 'Otros ($nonReferredCount)'),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 16, height: 16, color: color),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
