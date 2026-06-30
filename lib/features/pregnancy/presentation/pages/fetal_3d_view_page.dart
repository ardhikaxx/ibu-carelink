import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';
import '../../domain/entities/pregnancy_entity.dart';

class Fetal3DViewPage extends StatelessWidget {
  final PregnancyEntity pregnancy;
  const Fetal3DViewPage({super.key, required this.pregnancy});

  @override
  Widget build(BuildContext context) {
    final weeks = pregnancy.gestationalWeeks;
    final analogy = pregnancy.fetalSizeFruitAnalogy;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomFloatingHeader(
        title: 'Anatomi & Ukuran Janin',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Gestasi Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 16, color: AppTheme.primaryRose),
                      const SizedBox(width: 6),
                      Text(
                        'USIA GESTASI $weeks MINGGU',
                        style: const TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'TRIMESTER ${pregnancy.trimester}',
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Ultra-Modern Floating Hero Analogy Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
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
                children: [
                  Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.2), width: 2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.child_care_rounded,
                        size: 64,
                        color: AppTheme.primaryRose,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Analogi Ukuran Janin Saat Ini',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    analogy,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildEstimatorBox(
                          label: 'Perkiraan Panjang',
                          value: _getEstimatedLength(weeks),
                          icon: Icons.straighten_rounded,
                          color: AppTheme.primaryRose,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEstimatorBox(
                          label: 'Perkiraan Berat',
                          value: _getEstimatedWeight(weeks),
                          icon: Icons.monitor_weight_outlined,
                          color: AppTheme.primaryRose,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Anatomical Development Card
            Container(
              padding: const EdgeInsets.all(22),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRose.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryRose, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Perkembangan Anatomi Mingguan',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 2),
                            Text('Proses pembentukan fisiologis janin', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),
                  Text(
                    _getAnatomicalDescription(weeks),
                    style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF334155)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Medical Advice & Nutrition Checklist Card
            Container(
              padding: const EdgeInsets.all(22),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.tips_and_updates_rounded, color: Color(0xFFD97706), size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saran Medis & Nutrisi Maternal',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 2),
                            Text('Rekomendasi klinis menjaga kehamilan', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),
                  _buildTipItem(
                    weeks <= 12
                        ? 'Pastikan konsumsi rutin Asam Folat (400-800 mcg) untuk mencegah defek tabung saraf janin.'
                        : weeks <= 27
                            ? 'Konsumsi suplemen zat besi dan kalsium. Jadwalkan pemeriksaan USG anatomi untuk mengecek organ janin secara menyeluruh.'
                            : 'Siapkan tas persalinan dan perhatikan pola gerakan tendangan janin setiap hari secara rutin.',
                  ),
                  const SizedBox(height: 14),
                  _buildTipItem('Cukupi kebutuhan hidrasi air putih minimal 2,5 - 3 liter per hari dan hindari aktivitas berisiko tinggi.'),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimatorBox({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF0F172A))),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            color: Color(0xFFECFDF5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: AppTheme.successGreen, size: 14),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xFF334155), fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  String _getEstimatedLength(int weeks) {
    if (weeks <= 8) return '~1.6 cm';
    if (weeks <= 12) return '~5.4 cm';
    if (weeks <= 16) return '~11.6 cm';
    if (weeks <= 20) return '~25.6 cm';
    if (weeks <= 24) return '~30.0 cm';
    if (weeks <= 28) return '~37.6 cm';
    if (weeks <= 32) return '~42.4 cm';
    if (weeks <= 36) return '~47.4 cm';
    return '~50.5 cm';
  }

  String _getEstimatedWeight(int weeks) {
    if (weeks <= 8) return '~1 gram';
    if (weeks <= 12) return '~14 gram';
    if (weeks <= 16) return '~100 gram';
    if (weeks <= 20) return '~300 gram';
    if (weeks <= 24) return '~600 gram';
    if (weeks <= 28) return '~1.000 gram';
    if (weeks <= 32) return '~1.700 gram';
    if (weeks <= 36) return '~2.600 gram';
    return '~3.300 gram';
  }

  String _getAnatomicalDescription(int weeks) {
    if (weeks <= 8) {
      return 'Trimester 1: Embrio mulai membenih dan melakukan organogenesis. Pembentukan tabung saraf, detak jantung awal, serta tunas anggota gerak dasar sedang berlangsung pesat.';
    }
    if (weeks <= 16) {
      return 'Trimester 2 Awal: Tulang janin mulai mengeras (oksifikasi). Janin sudah dapat merespons suara primer dari detak jantung dan suara ibu. Sensasi pergerakan halus (quickening) mungkin mulai dirasakan.';
    }
    if (weeks <= 27) {
      return 'Trimester 2 Lanjut: Janin bertumbuh pesat dan aktif bergerak di dalam cairan ketuban. Sidik jari telah terbentuk sempurna dan kelopak mata mulai terbuka.';
    }
    return 'Trimester 3: Pematangan fungsional organ paru janin dan akumulasi cadangan lemak bawah kulit. Posisi kepala janin bersiap turun menuju rongga panggul menyambut masa persalinan.';
  }
}
