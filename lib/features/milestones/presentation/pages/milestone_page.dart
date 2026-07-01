import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../child_growth/domain/entities/child_entity.dart';
import '../bloc/milestone_bloc.dart';
import '../bloc/milestone_event.dart';
import '../bloc/milestone_state.dart';
import '../../domain/entities/milestone_entity.dart';

class MilestonePage extends StatefulWidget {
  final ChildEntity child;
  final String userId;

  const MilestonePage({super.key, required this.child, required this.userId});

  @override
  State<MilestonePage> createState() => _MilestonePageState();
}

class _MilestonePageState extends State<MilestonePage> {
  String _selectedBand = '0-3 bln';
  final List<String> _ageBands = ['0-3 bln', '4-6 bln', '7-9 bln', '10-12 bln', '13-18 bln', '19-24 bln', '25-36 bln'];

  bool _matchesBand(MilestoneEntity m, String band) {
    if (m.targetAgeBand == band) return true;
    final month = m.maxMonthBand;
    switch (band) {
      case '0-3 bln':
        return month <= 3;
      case '4-6 bln':
        return month > 3 && month <= 6;
      case '7-9 bln':
        return month > 6 && month <= 9;
      case '10-12 bln':
        return month > 9 && month <= 12;
      case '13-18 bln':
        return month > 12 && month <= 18;
      case '19-24 bln':
        return month > 18 && month <= 24;
      case '25-36 bln':
        return month > 24 && month <= 36;
      default:
        return false;
    }
  }

  Color _getDomainColor(String domain) {
    if (domain.contains('Motorik Kasar')) return AppTheme.primaryRose;
    if (domain.contains('Motorik Halus')) return AppTheme.primaryTeal;
    if (domain.contains('Bicara') || domain.contains('Bahasa')) return const Color(0xFFD97706);
    if (domain.contains('Sosial') || domain.contains('Kognitif')) return AppTheme.successGreen;
    return AppTheme.primaryRose;
  }

  @override
  void initState() {
    super.initState();
    context.read<MilestoneBloc>().add(LoadMilestonesEvent(userId: widget.userId, childId: widget.child.id));
  }

  @override
  Widget build(BuildContext context) {
    final childAgeMonths = widget.child.ageInMonths;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomFloatingHeader(
        title: 'Perkembangan KPSP (${widget.child.name})',
        showBackButton: true,
      ),
      body: BlocBuilder<MilestoneBloc, MilestoneState>(
        builder: (context, state) {
          if (state is MilestoneLoading) {
            return AppSkeleton.listSkeleton(itemCount: 5);
          }

          if (state is MilestoneLoaded) {
            final all = state.milestones;
            final bandFiltered = all.where((m) => _matchesBand(m, _selectedBand)).toList();

            // Calculate overall domain progress
            int grossTotal = all.where((m) => m.domain.contains('Motorik Kasar')).length;
            int grossDone = all.where((m) => m.domain.contains('Motorik Kasar') && m.isAchieved).length;

            int fineTotal = all.where((m) => m.domain.contains('Motorik Halus')).length;
            int fineDone = all.where((m) => m.domain.contains('Motorik Halus') && m.isAchieved).length;

            int speechTotal = all.where((m) => m.domain.contains('Bicara')).length;
            int speechDone = all.where((m) => m.domain.contains('Bicara') && m.isAchieved).length;

            int socialTotal = all.where((m) => m.domain.contains('Sosial')).length;
            int socialDone = all.where((m) => m.domain.contains('Sosial') && m.isAchieved).length;

            // Check red flags
            final overdueMilestones = all.where((m) => !m.isAchieved && childAgeMonths > m.maxMonthBand + 1).toList();

            return Column(
              children: [
                // Age Band Tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: _ageBands.map((band) {
                      final isSel = _selectedBand == band;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(band),
                          selected: isSel,
                          selectedColor: AppTheme.primaryRose,
                          backgroundColor: Colors.white,
                          showCheckmark: false,
                          side: BorderSide(color: isSel ? AppTheme.primaryRose : Colors.grey.shade300),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : const Color(0xFF0F172A),
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          ),
                          onSelected: (_) => setState(() => _selectedBand = band),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Red flag warning
                        if (overdueMilestones.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: AppTheme.errorRed,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: AppTheme.errorRed.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline_rounded, color: Colors.white, size: 36),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('RED FLAG TUMBUH KEMBANG!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Terdapat ${overdueMilestones.length} indikator perkembangan usia sebelumnya yang belum tercapai. Segera konsultasikan ke Klinik Tumbuh Kembang Dokter Anak.',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Progress bars per domain
                        Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Progres Domain Tumbuh Kembang (Denver II)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                                const SizedBox(height: 14),
                                _buildProgressBar('Motorik Kasar', grossDone, grossTotal, AppTheme.primaryRose),
                                const SizedBox(height: 10),
                                _buildProgressBar('Motorik Halus', fineDone, fineTotal, AppTheme.primaryTeal),
                                const SizedBox(height: 10),
                                _buildProgressBar('Bicara & Bahasa', speechDone, speechTotal, const Color(0xFFD97706)),
                                const SizedBox(height: 10),
                                _buildProgressBar('Sosialisasi & Kemandirian', socialDone, socialTotal, AppTheme.successGreen),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text('Checklist KPSP ($_selectedBand)', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                        const SizedBox(height: 12),
                        if (bandFiltered.isEmpty)
                          Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Tidak ada daftar untuk kelompok usia ini.', style: TextStyle(color: Colors.grey.shade500))))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: bandFiltered.length,
                            itemBuilder: (context, index) {
                              final item = bandFiltered[index];
                              final domainColor = _getDomainColor(item.domain);
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                color: item.isAchieved ? AppTheme.primaryRose.withValues(alpha: 0.05) : Colors.white,
                                elevation: item.isAchieved ? 0 : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: item.isAchieved ? AppTheme.primaryRose : Colors.grey.shade200,
                                    width: item.isAchieved ? 1.5 : 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  activeColor: AppTheme.primaryRose,
                                  checkColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  title: Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: item.isAchieved ? AppTheme.primaryRose : const Color(0xFF0F172A),
                                      decoration: item.isAchieved ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: domainColor.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            item.domain,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: domainColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  value: item.isAchieved,
                                  onChanged: (val) {
                                    context.read<MilestoneBloc>().add(ToggleMilestoneEvent(milestone: item, userId: widget.userId));
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildProgressBar(String label, int done, int total, Color color) {
    final ratio = total > 0 ? (done / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text('$done/$total (${(ratio * 100).toInt()}%)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: ratio,
          minHeight: 8,
          backgroundColor: color.withValues(alpha: 0.12),
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    );
  }
}
