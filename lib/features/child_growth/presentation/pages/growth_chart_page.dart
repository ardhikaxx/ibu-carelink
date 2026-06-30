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
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5, color: Colors.white),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: Color(0xFF64748B)),
                tabs: const [
                  Tab(text: 'Tinggi Badan (TB/U)'),
                  Tab(text: 'Berat Badan (BB/U)'),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _buildChartTab(
              context,
              title: 'Tinggi / Panjang Badan menurut Usia',
              yLabel: 'Tinggi (cm)',
              refMap: heightRef,
              isHeight: true,
            ),
            _buildChartTab(
              context,
              title: 'Berat Badan menurut Usia',
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

    final latestLog = logs.isNotEmpty ? logs.last : null;
    final latestVal = latestLog != null ? (isHeight ? latestLog.heightCm : latestLog.weightKg) : null;
    final ageMonths = DateHelper.calculateAgeInMonths(child.dateOfBirth);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Z-Score Standar WHO', style: TextStyle(color: AppTheme.successGreen, fontWeight: FontWeight.w800, fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        Text('Usia $ageMonths Bulan', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                if (latestVal != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$latestVal ${isHeight ? "cm" : "kg"}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryTeal),
                      ),
                      const Text('Pengukuran Terakhir', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                    ],
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
              _buildLegendPill(color: AppTheme.successGreen, label: 'Median Optimal'),
              _buildLegendPill(color: const Color(0xFFF59E0B), label: '+2 SD Batas Atas', isDash: true),
              _buildLegendPill(color: AppTheme.errorRed, label: '-2 SD Batas Bawah', isDash: true),
              _buildLegendPill(color: AppTheme.primaryTeal, label: 'Titik Aktual Anak', isCircle: true),
            ],
          ),
          const SizedBox(height: 18),

          // Chart Container
          Container(
            height: 380,
            padding: const EdgeInsets.only(right: 22, top: 28, bottom: 14, left: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 24,
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
                      reservedSize: 34,
                      interval: 12,
                      getTitlesWidget: (val, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('${val.toInt()} bln', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (val, meta) => Text('${val.toInt()}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
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
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.successGreen.withValues(alpha: 0.05),
                    ),
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
                          radius: 5.5,
                          color: AppTheme.primaryTeal,
                          strokeWidth: 2.5,
                          strokeColor: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Clinical Guide Card
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.menu_book_rounded, color: AppTheme.primaryTeal, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Panduan Membaca Kurva WHO',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Color(0xFF0F172A)),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Divider(color: Color(0xFFF1F5F9), height: 1),
                ),
                _buildGuideRow(color: AppTheme.successGreen, text: 'Garis Hijau (Median): Merupakan lintasan pertumbuhan optimal standar WHO internasional.'),
                const SizedBox(height: 10),
                _buildGuideRow(color: const Color(0xFFF59E0B), text: 'Garis Oranye (+2 SD): Batas atas kewaspadaan pertumbuhan berlebih atau risiko kelebihan berat badan.'),
                const SizedBox(height: 10),
                _buildGuideRow(color: AppTheme.errorRed, text: 'Garis Merah (-2 SD): Batas intervensi klinis. Titik di bawah garis ini mengindikasikan risiko Stunting atau Gizi Kurang.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildGuideRow({required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF475569))),
        ),
      ],
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
