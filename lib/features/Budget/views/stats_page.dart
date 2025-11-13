import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:my_app/features/Budget/controller/budget_controller.dart';






class StatsPage extends StatelessWidget {
  final controller = Get.put(BudgetController());

  StatsPage({super.key});

  final List<Color> colors = [
    Colors.pink,
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final stats = controller.getDepensesParCategorie();
    final entries = stats.entries.toList();

    // Préparer données pour Line Chart
    Map<DateTime, double> lineData = {};
    for (var cat in controller.categories) {
      for (var dep in cat['depenses']) {
        DateTime date = DateTime.parse(dep['date']);
        double montant = dep['montant'] as double;
        lineData[date] = (lineData[date] ?? 0) + montant;
      }
    }
    final sortedDates = lineData.keys.toList()..sort();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Statistiques"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Répartition"),
              Tab(text: "Budget vs Dépense"),
              Tab(text: "Évolution"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ================= Pie Chart =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    "Répartition des dépenses par animal",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: List.generate(entries.length, (index) {
                          final e = entries[index];
                          return PieChartSectionData(
                            value: e.value,
                            title: "${e.value.toStringAsFixed(1)}",
                            color: colors[index % colors.length],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    children: List.generate(entries.length, (index) {
                      final e = entries[index];
                      return Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            color: colors[index % colors.length],
                          ),
                          const SizedBox(width: 8),
                          Text("${e.key}: ${e.value.toStringAsFixed(1)} DT"),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            // ================= Bar Chart =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: BarChart(
                BarChartData(
                  maxY: (controller.categories
                              .map((c) => c['budget'] as double)
                              .fold(0.0, (prev, e) => e > prev ? e : prev) +
                          20)
                      .toDouble(),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < controller.categories.length) {
                            return Text(controller.categories[index]['nom']);
                          }
                          return const Text('');
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  barGroups: List.generate(controller.categories.length, (index) {
                    final cat = controller.categories[index];
                    final key = cat['nom'] as String;
                    final budget = cat['budget'] as double;
                    final depense = controller.calculerDepenses(key);
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: budget,
                          color: Colors.green,
                          width: 15,
                        ),
                        BarChartRodData(
                          toY: depense,
                          color: Colors.pink,
                          width: 15,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),

            // ================= Line Chart =================
            Padding(
              padding: const EdgeInsets.all(20),
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: (lineData.values.fold(0.0, (a, b) => a > b ? a : b)) + 20,
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < sortedDates.length) {
                            final date = sortedDates[index];
                            return Text("${date.day}/${date.month}");
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(sortedDates.length, (index) {
                        final date = sortedDates[index];
                        return FlSpot(index.toDouble(), lineData[date]!);
                      }),
                      isCurved: true,
                      barWidth: 3,
                      color: Colors.pink,
                      dotData: FlDotData(show: true),
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
}
