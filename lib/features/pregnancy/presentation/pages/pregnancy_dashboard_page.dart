import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../../../contraction_timer/presentation/pages/contraction_timer_page.dart';
import '../../../kick_counter/presentation/pages/kick_counter_page.dart';
import '../bloc/pregnancy_bloc.dart';
import '../bloc/pregnancy_event.dart';
import '../bloc/pregnancy_state.dart';
import 'fetal_3d_view_page.dart';
import 'symptom_log_page.dart';

class PregnancyDashboardPage extends StatefulWidget {
  final String userId;
  const PregnancyDashboardPage({super.key, required this.userId});

  @override
  State<PregnancyDashboardPage> createState() => _PregnancyDashboardPageState();
}

class _PregnancyDashboardPageState extends State<PregnancyDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<PregnancyBloc>().add(LoadActivePregnancyEvent(widget.userId));
  }

  void _showCreatePregnancyModal() {
    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 60)); // Default ~8 minggu lalu
    final weightController = TextEditingController(text: '55.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Konfigurasi Kehamilan Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('Masukkan Hari Pertama Haid Terakhir (HPHT) untuk kalkulasi Hukum Naegele.', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 20),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.shade300)),
                leading: const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryRose),
                title: const Text('Tanggal HPHT'),
                subtitle: Text(DateHelper.formatIndonesianDate(selectedDate), style: const TextStyle(fontWeight: FontWeight.bold)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(DateTime.now().year - 1),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() => selectedDate = picked);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Berat Badan Sebelum Hamil (kg)',
                  prefixIcon: const Icon(Icons.monitor_weight_outlined, color: AppTheme.primaryRose),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final weight = double.tryParse(weightController.text) ?? 55.0;
                    context.read<PregnancyBloc>().add(CreatePregnancyProfileEvent(
                          userId: widget.userId,
                          hpht: selectedDate,
                          preWeight: weight,
                        ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Mulai Pelacakan Gestasi'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PregnancyBloc, PregnancyState>(
      builder: (context, state) {
        if (state is PregnancyLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose));
        }

        if (state is PregnancyEmpty || state is PregnancyError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: AppTheme.primaryRose.withValues(alpha: 0.12), shape: BoxShape.circle),
                    child: const Icon(Icons.pregnant_woman_rounded, size: 64, color: AppTheme.primaryRose),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum Ada Data Kehamilan Aktif', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const Text('Aktifkan modul pemantauan untuk mendapatkan kalkulasi taksiran persalinan (HPL) & panduan kehamilan.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: _showCreatePregnancyModal,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Konfigurasi Kehamilan'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PregnancyLoaded) {
          final pregnancy = state.pregnancy;
          final weeks = pregnancy.gestationalWeeks;
          final tri = pregnancy.trimester;
          final isTri3 = tri == 3 || weeks >= 28; // T3 feature flag

          return RefreshIndicator(
            onRefresh: () async {
              context.read<PregnancyBloc>().add(LoadActivePregnancyEvent(widget.userId));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Banner Gestasi HPL
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE85A71), Color(0xFFD9465F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryRose.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(20)),
                              child: Text('TRIMESTER $tri', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                            const Icon(Icons.favorite, color: Colors.white, size: 28),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text('$weeks MINGGU', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text('Taksiran Persalinan (HPL): ${DateHelper.formatIndonesianDate(pregnancy.estimatedDueDate)}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryRose),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => Fetal3DViewPage(pregnancy: pregnancy)));
                            },
                            icon: const Icon(Icons.view_in_ar_rounded),
                            label: Text('Lihat Analogi Janin (${pregnancy.fetalSizeFruitAnalogy.split(" ")[0]} ${pregnancy.fetalSizeFruitAnalogy.split(" ")[1]})'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Alat Diagnostik Trimester 3
                  const Text('Alat Diagnostik Real-Time', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Kick Counter',
                          subtitle: isTri3 ? 'Aktif Trimester 3' : 'Rekomendasi T3',
                          icon: Icons.touch_app_rounded,
                          color: AppTheme.primaryRose,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KickCounterPage(pregnancyId: pregnancy.id, userId: widget.userId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _buildFeatureCard(
                          title: 'Contraction Timer',
                          subtitle: 'Ambang Batas 5-1-1',
                          icon: Icons.timer_rounded,
                          color: AppTheme.primaryTeal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ContractionTimerPage(pregnancyId: pregnancy.id, userId: widget.userId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Diari Gejala
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Diari Gejala Maternal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SymptomLogPage(pregnancyId: pregnancy.id, userId: widget.userId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                        label: const Text('Catat Baru'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (state.symptomLogs.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: Text('Belum ada catatan gejala harian terekam.', style: TextStyle(color: Colors.grey.shade500)),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.symptomLogs.length,
                      itemBuilder: (context, index) {
                        final log = state.symptomLogs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(DateHelper.formatIndonesianDate(log.date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                    Row(
                                      children: [
                                        _buildBadge('Mual ${log.nauseaLevel}/5', AppTheme.primaryRose),
                                        const SizedBox(width: 6),
                                        _buildBadge('Lelah ${log.fatigueLevel}/5', AppTheme.primaryTeal),
                                      ],
                                    ),
                                  ],
                                ),
                                if (log.triggers.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    children: log.triggers.map((t) => Chip(label: Text(t, style: const TextStyle(fontSize: 10)), backgroundColor: Colors.grey.shade100, materialTapTargetSize: MaterialTapTargetSize.shrinkWrap)).toList(),
                                  ),
                                ],
                                if (log.moodNote.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text('"${log.moodNote}"', style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF475569))),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildFeatureCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}
