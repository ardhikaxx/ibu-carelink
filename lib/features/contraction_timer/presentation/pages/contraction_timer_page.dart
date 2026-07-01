import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';
import '../bloc/contraction_timer_bloc.dart';
import '../bloc/contraction_timer_event.dart';
import '../bloc/contraction_timer_state.dart';
import '../../domain/entities/contraction_entity.dart';

class ContractionTimerPage extends StatefulWidget {
  final String pregnancyId;
  final String userId;

  const ContractionTimerPage({super.key, required this.pregnancyId, required this.userId});

  @override
  State<ContractionTimerPage> createState() => _ContractionTimerPageState();
}

class _ContractionTimerPageState extends State<ContractionTimerPage> {
  String _selectedIntensity = 'sedang';

  @override
  void initState() {
    super.initState();
    context.read<ContractionTimerBloc>().add(LoadHistoryContractionsEvent(
          pregnancyId: widget.pregnancyId,
          userId: widget.userId,
        ));
  }

  String _formatSeconds(int secs) {
    final mins = (secs ~/ 60).toString().padLeft(2, '0');
    final s = (secs % 60).toString().padLeft(2, '0');
    return '$mins:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomFloatingHeader(
        title: 'Pengatur Waktu Kontraksi',
        showBackButton: true,
      ),
      body: BlocConsumer<ContractionTimerBloc, ContractionTimerState>(
        listener: (context, state) {
          if (state is ContractionTimerActive && state.is511AlertActive) {
            // Show alert dialog if 5-1-1 pattern detected
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.local_hospital_rounded, color: AppTheme.errorRed, size: 28),
                    SizedBox(width: 10),
                    Text('PERINGATAN 5-1-1', style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'Pola kontraksi Anda menunjukkan karakteristik persalinan aktif (setiap ≤ 5 menit, durasi ~1 menit, konsisten).\n\nSegera persiapkan diri menuju fasilitas kesehatan atau rumah sakit bersalin terdekat!',
                  style: TextStyle(height: 1.4),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Mengerti & Hubungi Dokter'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ContractionTimerActive) {
            final isContraction = state.status == ContractionStatus.contractionStarted;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Clinical Alert Card 5-1-1
                    if (state.is511AlertActive)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppTheme.errorRed.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 36),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('POLA 5-1-1 TERDETEKSI!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15)),
                                  SizedBox(height: 4),
                                  Text('Persalinan aktif dimulai. Segera menuju fasilitas kebidanan/UGD terdekat.', style: TextStyle(color: Colors.white, fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Intensity Selector
                    if (!isContraction)
                      Column(
                        children: [
                          const Text('Pilih Intensitas Nyeri Saat Ini:', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          const SizedBox(height: 12),
                          Row(
                            children: ['ringan', 'sedang', 'kuat'].map((level) {
                              final isSel = _selectedIntensity == level;
                              final label = level == 'ringan'
                                  ? 'Ringan'
                                  : level == 'sedang'
                                      ? 'Sedang'
                                      : 'Kuat';
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedIntensity = level),
                                    borderRadius: BorderRadius.circular(16),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppTheme.primaryRose : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSel ? AppTheme.primaryRose : const Color(0xFFE2E8F0),
                                          width: isSel ? 2 : 1,
                                        ),
                                        boxShadow: isSel
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primaryRose.withValues(alpha: 0.25),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Center(
                                        child: Text(
                                          label,
                                          style: TextStyle(
                                            color: isSel ? Colors.white : const Color(0xFF475569),
                                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Active Timer Display Card
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isContraction ? AppTheme.primaryRose : const Color(0xFFE2E8F0),
                          width: isContraction ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isContraction ? AppTheme.primaryRose : const Color(0xFF64748B)).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isContraction ? 'KONTRAKSI BERLANGSUNG' : 'INTERVAL ISTIRAHAT',
                              style: TextStyle(
                                color: isContraction ? AppTheme.primaryRose : const Color(0xFF475569),
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            isContraction
                                ? _formatSeconds(state.activeDurationSeconds)
                                : _formatSeconds(state.currentIntervalSeconds),
                            style: TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.w900,
                              color: isContraction ? AppTheme.primaryRose : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isContraction
                                ? 'Tarik napas dalam dari hidung, hembuskan perlahan...'
                                : 'Istirahat dan rilekskan tubuh sebelum gelombang berikutnya.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),

                    // Action Button
                    GestureDetector(
                      onTap: () {
                        context.read<ContractionTimerBloc>().add(ToggleContractionEvent(_selectedIntensity));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: isContraction
                              ? const Color(0xFF475569)
                              : AppTheme.primaryRose,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: (isContraction ? Colors.black : AppTheme.primaryRose).withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isContraction ? 'HENTIKAN KONTRAKSI' : 'MULAI REKAM KONTRAKSI',
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        context.read<ContractionTimerBloc>().add(StopContractionSessionEvent());
                      },
                      icon: const Icon(Icons.done_all_rounded),
                      label: const Text('Selesai Sesi Pemantauan'),
                    ),
                  ],
                ),
              ),
            );
          }

          final history = state is ContractionTimerSuccess
              ? state.history
              : state is ContractionTimerInitial
                  ? state.history
                  : <ContractionEntity>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer_rounded, color: AppTheme.primaryRose, size: 32),
                          SizedBox(width: 12),
                          Text('Observasi Kontraksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Pencatatan interval dan durasi membantu membedakan kontraksi palsu (Braxton Hicks) dengan persalinan aktif (Aturan 5-1-1). Sistem akan otomatis memperingatkan Anda saat waktu evakuasi tiba.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF334155)),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
                          onPressed: () {
                            context.read<ContractionTimerBloc>().add(StartContractionSessionEvent(
                                  pregnancyId: widget.pregnancyId,
                                  userId: widget.userId,
                                ));
                          },
                          icon: const Icon(Icons.play_circle_fill_rounded),
                          label: const Text('Mulai Pelacakan Waktu'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Catatan Kontraksi Sesi Ini',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Belum ada catatan kontraksi terekam.', style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final item = history[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRose.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.show_chart_rounded, color: AppTheme.primaryRose, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Durasi: ${_formatSeconds(item.durationSeconds)}',
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A)),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          item.intensityLevel.toUpperCase(),
                                          style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.w800, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Mulai: ${DateHelper.formatTime(item.startTime)} • Jarak istirahat: ${_formatSeconds(item.intervalSeconds)}',
                                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
