import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/growth_log_entity.dart';

class GrowthChartPage extends StatelessWidget {
  final ChildEntity child;
  final List<GrowthLogEntity> logs;

  const GrowthChartPage({super.key, required this.child, required this.logs});

  @override
  Widget build(BuildContext context) {
    final isBoys = child.gender.toLowerCase().contains('laki');
    final heightRef = isBoys ? AppConstants.whoBoysHeight : AppConstants.whoGirlsHeight;
    final weightRef = isBoys ? AppConstants.whoBoysWeight : AppConstants.whoGirlsWeight;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kurva Pertumbuhan WHO (${child.name})'),
          backgroundColor: AppTheme.primaryTeal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            unselectedLabelStyle: TextStyle(color: Colors.white70),
            tabs: [
              Tab(text: 'Kurva Tinggi Badan (TB/U)'),
              Tab(text: 'Kurva Berat Badan (BB/U)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChartTab(
              context,
              title: 'Tinggi / Panjang Badan menurut Usia (TB/U)',
              yLabel: 'Tinggi (cm)',
              refMap: heightRef,
              isHeight: true,
            ),
            _buildChartTab(
              context,
              title: 'Berat Badan menurut Usia (BB/U)',
              yLabel: 'Berat (kg)',
              refMap: weightRef,
              isHeight: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab(BuildContext context, {required String title, required String yLabel, required Map<int, List<double>> refMap, required bool isHeight}) {
    // Generate reference lines (-2SD, Median, +2SD)
    final months = [0, 6, 12, 24, 36, 60];
    final List<FlSpot> minus2SdSpots = [];
    final List<FlSpot> medianSpots = [];
    final List<FlSpot> plus2SdSpots = [];

    for (int m in months) {
      if (refMap.containsKey(m)) {
        minus2SdSpots.add(FlSpot(m.toDouble(), refMap[m]![0]));
        medianSpots.add(FlSpot(m.toDouble(), refMap[m]![1]));
        plus2SdSpots.add(FlSpot(m.toDouble(), refMap[m]![2]));
      }
    }

    // Actual user logs
    final List<FlSpot> actualSpots = [];
    for (var log in logs) {
      final m = DateHelper.calculateAgeInMonths(child.dateOfBirth, currentDate: log.measurementDate);
      final val = isHeight ? log.heightCm : log.weightKg;
      actualSpots.add(FlSpot(m.toDouble(), val));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 6),
          Text(
            'Kurva standar WHO membedakan batas normal warna hijau, kuning (waspada), dan merah (di bawah -2 SD).',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildLegendItem(Colors.green, 'Median (Normal)'),
              _buildLegendItem(Colors.orange, '+2 SD / Batas Atas'),
              _buildLegendItem(AppTheme.errorRed, '-2 SD (Batas Bawah)'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(AppTheme.primaryTeal, '• Aktual Anak (${child.name})', isCircle: true),
            ],
          ),
          const SizedBox(height: 24),

          // Chart
          Container(
            height: 350,
            padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: true, drawVerticalLine: true),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 12,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()} bln', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey.shade300)),
                lineBarsData: [
                  // Median WHO
                  LineChartBarData(
                    spots: medianSpots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                  ),
                  // -2 SD WHO
                  LineChartBarData(
                    spots: minus2SdSpots,
                    isCurved: true,
                    color: AppTheme.errorRed,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  // +2 SD WHO
                  LineChartBarData(
                    spots: plus2SdSpots,
                    isCurved: true,
                    color: Colors.orange,
                    barWidth: 1.5,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  // Actual Spots
                  if (actualSpots.isNotEmpty)
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: false,
                      color: AppTheme.primaryTeal,
                      barWidth: 3.5,
                      dotData: const FlDotData(show: true),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Clinical Note
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFFF0FDF4),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.health_and_safety_rounded, color: AppTheme.successGreen, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Jika titik aktual anak Anda menyentuh atau berada di bawah garis putus-putus merah (-2 SD), segera lakukan pemeriksaan ke Puskesmas atau dokter spesialis anak untuk penanganan intervensi gizi.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: Color(0xFF166534)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text, {bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: isCircle ? 10 : 16,
          height: isCircle ? 10 : 3,
          decoration: BoxDecoration(color: color, shape: isCircle ? BoxShape.circle : BoxShape.rectangle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
