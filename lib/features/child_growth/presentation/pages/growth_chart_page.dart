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
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'Kurva WHO (${child.name})',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
          ),
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: const Color(0xFF0F172A),
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF64748B)),
            tabs: const [
              Tab(text: 'Tinggi Badan (TB/U)'),
              Tab(text: 'Berat Badan (BB/U)'),
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

  Widget _buildChartTab(
    BuildContext context, {
    required String title,
    required String yLabel,
    required Map<int, List<double>> refMap,
    required bool isHeight,
  }) {
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

    final List<FlSpot> actualSpots = [];
    for (var log in logs) {
      final m = DateHelper.calculateAgeInMonths(child.dateOfBirth, currentDate: log.measurementDate);
      final val = isHeight ? log.heightCm : log.weightKg;
      actualSpots.add(FlSpot(m.toDouble(), val));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                const SizedBox(height: 6),
                const Text(
                  'Standar antropometri WHO memetakan zona hijau (median optimal), kuning (waspada +2 SD), dan merah (< -2 SD stunting/gizi kurang).',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Editorial Legend Pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildLegendPill(color: AppTheme.successGreen, label: 'Median WHO (Normal)'),
              _buildLegendPill(color: const Color(0xFFF59E0B), label: '+2 SD (Batas Atas)', isDash: true),
              _buildLegendPill(color: AppTheme.errorRed, label: '-2 SD (Batas Intervensi)', isDash: true),
              _buildLegendPill(color: AppTheme.primaryTeal, label: 'Aktual (${child.name})', isCircle: true),
            ],
          ),
          const SizedBox(height: 18),

          // Chart Container
          Container(
            height: 360,
            padding: const EdgeInsets.only(right: 20, top: 24, bottom: 12, left: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (val) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
                  getDrawingVerticalLine: (val) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 12,
                      getTitlesWidget: (val, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${val.toInt()} bln', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true, border: Border.all(color: const Color(0xFFE2E8F0))),
                lineBarsData: [
                  // Median WHO
                  LineChartBarData(
                    spots: medianSpots,
                    isCurved: true,
                    color: AppTheme.successGreen,
                    barWidth: 2.5,
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
                    color: const Color(0xFFF59E0B),
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                  // Actual User Spots
                  if (actualSpots.isNotEmpty)
                    LineChartBarData(
                      spots: actualSpots,
                      isCurved: false,
                      color: AppTheme.primaryTeal,
                      barWidth: 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                          radius: 5,
                          color: AppTheme.primaryTeal,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Clinical Note
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppTheme.successGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Panduan Evaluasi Klinis Z-Score',
                        style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Apabila titik aktual pertumbuhan anak menyentuh atau berada di bawah garis putus-putus merah (-2 SD), segera konsultasikan ke Puskesmas atau dokter spesialis anak untuk evaluasi gizi intensif.',
                        style: TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF047857), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLegendPill({required Color color, required String label, bool isDash = false, bool isCircle = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCircle ? 10 : 16,
            height: isCircle ? 10 : 3.5,
            decoration: BoxDecoration(
              color: color,
              shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
              borderRadius: isCircle ? null : BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }
}
