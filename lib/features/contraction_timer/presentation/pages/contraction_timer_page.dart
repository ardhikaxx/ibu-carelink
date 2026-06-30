import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
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
      appBar: AppBar(
        title: const Text('Pengatur Waktu Kontraksi'),
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
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
                            BoxShadow(color: AppTheme.errorRed.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6)),
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
                          const Text('Pilih Intensitas Nyeri Saat Ini:', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 10),
                          SegmentedButton<String>(
                            segments: const [
                              ButtonSegment(value: 'ringan', label: Text('Ringan')),
                              ButtonSegment(value: 'sedang', label: Text('Sedang')),
                              ButtonSegment(value: 'kuat', label: Text('Kuat')),
                            ],
                            selected: {_selectedIntensity},
                            onSelectionChanged: (val) {
                              setState(() => _selectedIntensity = val.first);
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),

                    // Active Timer Display Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      decoration: BoxDecoration(
                        color: isContraction ? AppTheme.primaryRose.withOpacity(0.12) : AppTheme.primaryTeal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: isContraction ? AppTheme.primaryRose : AppTheme.primaryTeal, width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isContraction ? 'KONTRAKSI BERLANGSUNG' : 'INTERVAL ISTIRAHAT',
                            style: TextStyle(
                              color: isContraction ? AppTheme.primaryRose : AppTheme.primaryTeal,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isContraction
                                ? _formatSeconds(state.activeDurationSeconds)
                                : _formatSeconds(state.currentIntervalSeconds),
                            style: const TextStyle(fontSize: 54, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isContraction
                                ? 'Tarik napas dalam dari hidung, hembuskan perlahan...'
                                : 'Istirahat dan rilekskan tubuh sebelum gelombang berikutnya.',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
                          gradient: LinearGradient(
                            colors: isContraction
                                ? [const Color(0xFF475569), const Color(0xFF1E293B)]
                                : [AppTheme.primaryRose, const Color(0xFFD9465F)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: (isContraction ? Colors.black : AppTheme.primaryRose).withOpacity(0.3),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.timer_rounded, color: AppTheme.primaryTeal, size: 32),
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
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryTeal),
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
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryRose.withOpacity(0.15),
                            child: const Icon(Icons.show_chart_rounded, color: AppTheme.primaryRose),
                          ),
                          title: Text(
                            'Durasi: ${_formatSeconds(item.durationSeconds)} • Intensitas: ${item.intensityLevel.toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Mulai: ${DateHelper.formatTime(item.startTime)} • Jarak dari sebelumnya: ${_formatSeconds(item.intervalSeconds)}',
                            style: const TextStyle(fontSize: 12),
                          ),
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
