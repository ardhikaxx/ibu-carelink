import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/utils/theme.dart';
import '../bloc/kick_counter_bloc.dart';
import '../bloc/kick_counter_event.dart';
import '../bloc/kick_counter_state.dart';
import '../../domain/entities/kick_session_entity.dart';

class KickCounterPage extends StatefulWidget {
  final String pregnancyId;
  final String userId;

  const KickCounterPage({super.key, required this.pregnancyId, required this.userId});

  @override
  State<KickCounterPage> createState() => _KickCounterPageState();
}

class _KickCounterPageState extends State<KickCounterPage> {
  @override
  void initState() {
    super.initState();
    context.read<KickCounterBloc>().add(LoadHistorySessionsEvent(
          pregnancyId: widget.pregnancyId,
          userId: widget.userId,
        ));
  }

  String _formatDuration(int totalSecs) {
    final mins = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSecs % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penghitung Tendangan Janin'),
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<KickCounterBloc, KickCounterState>(
        listener: (context, state) {
          if (state is KickCounterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sesi penghitungan tendangan berhasil disimpan ke Firestore!'),
                backgroundColor: AppTheme.successGreen,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is KickCounterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is KickCounterSaving) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryRose),
                  SizedBox(height: 16),
                  Text('Menyimpan dokumen sesi ke Cloud Firestore...'),
                ],
              ),
            );
          }

          if (state is KickCounterActive) {
            final progress = (state.totalKicks / 10).clamp(0.0, 1.0);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Wake Lock Active Indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTeal.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.screen_lock_landscape_rounded, color: AppTheme.primaryTeal, size: 16),
                          SizedBox(width: 8),
                          Text('Wake Lock Aktif • Layar tidak akan padam', style: TextStyle(color: AppTheme.primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Medical target warning if time exceeded
                    if (state.isTimeExceededWarning)
                      Container(
                        padding: const EdgeInsets.all(14),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.errorRed),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.warning_rounded, color: AppTheme.errorRed, size: 28),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Peringatan Medis: Waktu observasi melebihi 2 jam tanpa mencapai 10 tendangan. Segera konsultasikan dengan bidan atau dokter spesialis kandungan Anda.',
                                style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Text(
                      'Waktu Observasi: ${_formatDuration(state.elapsedSeconds)}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade200,
                      color: state.targetAchieved ? AppTheme.successGreen : AppTheme.primaryRose,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Target Klinis: ${state.totalKicks}/10 Ketukan dalam 2 Jam',
                      style: TextStyle(
                        color: state.targetAchieved ? AppTheme.successGreen : Colors.grey.shade700,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),

                    // Big Tactile Kick Button
                    GestureDetector(
                      onTap: () {
                        context.read<KickCounterBloc>().add(RecordKickEvent());
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: state.targetAchieved
                                ? [AppTheme.successGreen, const Color(0xFF059669)]
                                : [AppTheme.primaryRose, const Color(0xFFD9465F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (state.targetAchieved ? AppTheme.successGreen : AppTheme.primaryRose).withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.touch_app_rounded, size: 64, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              'KETUK DISINI\n(${state.totalKicks})',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Haptic Teraktifkan',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: AppTheme.errorRed, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () {
                          context.read<KickCounterBloc>().add(StopAndSaveSessionEvent());
                        },
                        icon: const Icon(Icons.stop_circle_rounded, color: AppTheme.errorRed),
                        label: const Text(
                          'Selesai & Kirim Sesi ke Firestore',
                          style: TextStyle(color: AppTheme.errorRed, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Initial or Success View
          final history = state is KickCounterSuccess
              ? state.history
              : state is KickCounterInitial
                  ? state.history
                  : <KickSessionEntity>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF1F2), Color(0xFFFEE2E2)],
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
                          Icon(Icons.child_friendly_rounded, color: AppTheme.primaryRose, size: 32),
                          SizedBox(width: 12),
                          Text('Observasi Trimester 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Menghitung pergerakan janin sangat esensial mulai pekan ke-28 untuk mendeteksi tanda gawat janin. Layar akan menyala terus (Wake Lock) dan getaran haptic akan berdenyut setiap Anda mengetuk.',
                        style: TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<KickCounterBloc>().add(StartKickSessionEvent(
                                  pregnancyId: widget.pregnancyId,
                                  userId: widget.userId,
                                ));
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Mulai Sesi Penghitungan'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Riwayat Sesi Tersinkronisasi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 12),
                if (history.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text('Belum ada riwayat sesi tendangan.', style: TextStyle(color: Colors.grey.shade500)),
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
                            backgroundColor: item.targetAchieved ? AppTheme.successGreen.withOpacity(0.2) : AppTheme.warningYellow.withOpacity(0.2),
                            child: Icon(
                              Icons.favorite,
                              color: item.targetAchieved ? AppTheme.successGreen : AppTheme.warningYellow,
                            ),
                          ),
                          title: Text(
                            '${item.totalKicks} Tendangan (${_formatDuration(item.sessionDurationSeconds)})',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(DateHelper.formatIndonesianDate(item.startTime)),
                          trailing: Chip(
                            label: Text(item.targetAchieved ? 'Tercapai' : 'Kurang'),
                            backgroundColor: item.targetAchieved ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.warningYellow.withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: item.targetAchieved ? AppTheme.successGreen : AppTheme.warningYellow,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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
