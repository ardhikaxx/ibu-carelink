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
    DateTime selectedDate = DateTime.now().subtract(const Duration(days: 60));
    final weightController = TextEditingController(text: '55.0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Konfigurasi Kehamilan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan Hari Pertama Haid Terakhir (HPHT) untuk mengalkulasi taksiran persalinan akurat.',
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                tileColor: const Color(0xFFF8FAFC),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.calendar_today_rounded, color: AppTheme.primaryRose, size: 20),
                ),
                title: const Text('Tanggal HPHT', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                subtitle: Text(
                  DateHelper.formatIndonesianDate(selectedDate),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 15),
                ),
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
              const SizedBox(height: 14),
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Berat Badan Sebelum Hamil (kg)',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    final weight = double.tryParse(weightController.text) ?? 55.0;
                    context.read<PregnancyBloc>().add(CreatePregnancyProfileEvent(
                          userId: widget.userId,
                          hpht: selectedDate,
                          preWeight: weight,
                        ));
                    Navigator.pop(ctx);
                  },
                  child: const Text('Mulai Pantau Kehamilan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: BlocBuilder<PregnancyBloc, PregnancyState>(
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
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.pregnant_woman_rounded, size: 56, color: AppTheme.primaryRose),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Belum Ada Data Kehamilan',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aktifkan pemantauan kehamilan Anda untuk melihat usia gestasi, taksiran persalinan (HPL), dan perkembangan janin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryRose,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                        ),
                        onPressed: _showCreatePregnancyModal,
                        icon: const Icon(Icons.add_rounded, size: 20),
                        label: const Text('Konfigurasi Kehamilan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
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

            return RefreshIndicator(
              color: AppTheme.primaryRose,
              onRefresh: () async {
                context.read<PregnancyBloc>().add(LoadActivePregnancyEvent(widget.userId));
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ultra-Modern White Floating Gestation Card
                    Container(
                      padding: const EdgeInsets.all(24),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  Icons.pregnant_woman_rounded,
                                  color: AppTheme.primaryRose,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Usia Gestasi',
                                          style: TextStyle(
                                            color: Color(0xFF0F172A),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryRose.withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'TRIMESTER $tri',
                                            style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.w800, fontSize: 11),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Taksiran Lahir: ${DateHelper.formatIndonesianDate(pregnancy.estimatedDueDate)}',
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '$weeks',
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 44,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.5,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'MINGGU',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.child_friendly_rounded, color: AppTheme.primaryRose, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('Analogi Perkembangan Janin', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        pregnancy.fetalSizeFruitAnalogy,
                                        style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryRose,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => Fetal3DViewPage(pregnancy: pregnancy)));
                              },
                              icon: const Icon(Icons.view_in_ar_rounded, size: 20),
                              label: const Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Text(
                                  'Lihat Analogi & Model Janin 3D',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, height: 1.35),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Diagnostic Tools Section
                    const Text(
                      'Pantauan & Alat Gestasi',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildServiceCard(
                            title: 'Kick Counter',
                            subtitle: 'Hitung Tendangan Janin',
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
                          child: _buildServiceCard(
                            title: 'Contraction Timer',
                            subtitle: 'Pantau Kontraksi Latih',
                            icon: Icons.timer_rounded,
                            color: AppTheme.primaryRose,
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

                    // Symptom Diary Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Diari Gejala Maternal',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.primaryRose),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SymptomLogPage(pregnancyId: pregnancy.id, userId: widget.userId),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryRose,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text('Catat Gejala', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (state.symptomLogs.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: const Center(
                          child: Text(
                            'Belum ada catatan gejala harian terekam.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final log = state.symptomLogs[index];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SymptomLogPage(pregnancyId: pregnancy.id, userId: widget.userId, initialLog: log),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateHelper.formatIndonesianDate(log.date),
                                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.primaryRose),
                                        ),
                                        Row(
                                          children: [
                                            _buildBadge('Mual ${log.nauseaLevel}/5', AppTheme.primaryRose),
                                            const SizedBox(width: 6),
                                            _buildBadge('Lelah ${log.fatigueLevel}/5', AppTheme.primaryRose),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.edit_rounded, size: 16, color: AppTheme.primaryRose),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    if (log.triggers.isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: log.triggers.map((t) => Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF8FAFC),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFF1F5F9)),
                                          ),
                                          child: Text(t, style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600)),
                                        )).toList(),
                                      ),
                                    ],
                                    if (log.moodNote.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Text(
                                        '"${log.moodNote}"',
                                        style: const TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF64748B), fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
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
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
