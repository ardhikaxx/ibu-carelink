import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';
import '../../domain/entities/pregnancy_entity.dart';

class FetalAnatomyPage extends StatelessWidget {
  final PregnancyEntity pregnancy;
  const FetalAnatomyPage({super.key, required this.pregnancy});

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

            // Ultra-Modern Floating Hero Analogy Card with Cropped Fetal Image
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
                    width: 145,
                    height: 145,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.25), width: 2.5),
                    ),
                    child: Image.asset(
                      _getFetalStageImagePath(weeks),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.child_care_rounded,
                        size: 64,
                        color: AppTheme.primaryRose,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      _getFetalStageTitle(weeks),
                      style: const TextStyle(
                        color: AppTheme.primaryRose,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                      fontSize: 24,
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

            // 12 Fetal Stages Carousel Card
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
                        child: const Icon(Icons.timeline_rounded, color: AppTheme.primaryRose, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Galeri 12 Tahapan Janin',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 2),
                            Text('Geser untuk melihat evolusi bentuk janin', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 145,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 12,
                      separatorBuilder: (context, index) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final stageData = _getAllStagesData()[index];
                        final isCurrentStage = _isCurrentStageIndex(weeks, index);
                        return GestureDetector(
                          onTap: () {
                            _showStageDetailModal(context, stageData);
                          },
                          child: Container(
                            width: 110,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isCurrentStage ? AppTheme.primaryRose.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isCurrentStage ? AppTheme.primaryRose : const Color(0xFFE2E8F0),
                                width: isCurrentStage ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    stageData['image']!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  stageData['label']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isCurrentStage ? FontWeight.w800 : FontWeight.w600,
                                    color: isCurrentStage ? AppTheme.primaryRose : const Color(0xFF334155),
                                  ),
                                ),
                                if (isCurrentStage) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRose,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'Saat Ini',
                                      style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
                          color: AppTheme.primaryRose.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.tips_and_updates_rounded, color: AppTheme.primaryRose, size: 22),
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

  void _showStageDetailModal(BuildContext context, Map<String, String> stageData) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Detail Anatomi: ${stageData['label']}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 20),
              Container(
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.2)),
                ),
                child: InteractiveViewer(
                  child: Image.asset(stageData['image']!, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                stageData['desc']!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13.5, height: 1.5, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
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
          decoration: BoxDecoration(
            color: AppTheme.primaryRose.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: AppTheme.primaryRose, size: 14),
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

  String _getFetalStageImagePath(int weeks) {
    if (weeks <= 3) return 'assets/images/fetal/stage_01_3w.png';
    if (weeks == 4) return 'assets/images/fetal/stage_02_4w.png';
    if (weeks == 5) return 'assets/images/fetal/stage_03_5w.png';
    if (weeks == 6) return 'assets/images/fetal/stage_04_6w.png';
    if (weeks == 7) return 'assets/images/fetal/stage_05_7w.png';
    if (weeks <= 10) return 'assets/images/fetal/stage_06_8_10w.png';
    if (weeks <= 13) return 'assets/images/fetal/stage_07_11_13w.png';
    if (weeks <= 18) return 'assets/images/fetal/stage_08_14_18w.png';
    if (weeks <= 22) return 'assets/images/fetal/stage_09_19_22w.png';
    if (weeks <= 29) return 'assets/images/fetal/stage_10_23_29w.png';
    if (weeks <= 35) return 'assets/images/fetal/stage_11_30_35w.png';
    return 'assets/images/fetal/stage_12_36_41w.png';
  }

  String _getFetalStageTitle(int weeks) {
    if (weeks <= 3) return 'Tahap 1: 3 Minggu (Zigot)';
    if (weeks == 4) return 'Tahap 2: 4 Minggu (Blastosis)';
    if (weeks == 5) return 'Tahap 3: 5 Minggu (Embrio Huruf C)';
    if (weeks == 6) return 'Tahap 4: 6 Minggu (Tunas Anggota Gerak)';
    if (weeks == 7) return 'Tahap 5: 7 Minggu (Kepala & Ekor Janin)';
    if (weeks <= 10) return 'Tahap 6: 8-10 Minggu (Bentuk Janin Terbentuk)';
    if (weeks <= 13) return 'Tahap 7: 11-13 Minggu (Kepala Membulat)';
    if (weeks <= 18) return 'Tahap 8: 14-18 Minggu (Detail Wajah & Jari Jelas)';
    if (weeks <= 22) return 'Tahap 9: 19-22 Minggu (Proporsi Tubuh Seimbang)';
    if (weeks <= 29) return 'Tahap 10: 23-29 Minggu (Pertumbuhan Otot Pesat)';
    if (weeks <= 35) return 'Tahap 11: 30-35 Minggu (Pematangan Paru & Organ)';
    return 'Tahap 12: 36-41 Minggu (Siap Lahir / Full Term)';
  }

  bool _isCurrentStageIndex(int weeks, int index) {
    if (weeks <= 3 && index == 0) return true;
    if (weeks == 4 && index == 1) return true;
    if (weeks == 5 && index == 2) return true;
    if (weeks == 6 && index == 3) return true;
    if (weeks == 7 && index == 4) return true;
    if (weeks >= 8 && weeks <= 10 && index == 5) return true;
    if (weeks >= 11 && weeks <= 13 && index == 6) return true;
    if (weeks >= 14 && weeks <= 18 && index == 7) return true;
    if (weeks >= 19 && weeks <= 22 && index == 8) return true;
    if (weeks >= 23 && weeks <= 29 && index == 9) return true;
    if (weeks >= 30 && weeks <= 35 && index == 10) return true;
    if (weeks >= 36 && index == 11) return true;
    return false;
  }

  List<Map<String, String>> _getAllStagesData() {
    return [
      {
        'image': 'assets/images/fetal/stage_01_3w.png',
        'label': '3 minggu',
        'desc': 'Sel telur yang telah dibuahi (zigot) mengalami pembelahan cepat menjadi morula dan bersiap menempel pada dinding rahim.',
      },
      {
        'image': 'assets/images/fetal/stage_02_4w.png',
        'label': '4 minggu',
        'desc': 'Terbentuk blastosis dan kantung kehamilan awal. Plasenta dan tali pusat mulai berkembang untuk menyalurkan nutrisi.',
      },
      {
        'image': 'assets/images/fetal/stage_03_5w.png',
        'label': '5 minggu',
        'desc': 'Embrio berukuran sebesar biji wijen melengkung seperti huruf C. Detak jantung janin mulai berdenyut untuk pertama kalinya.',
      },
      {
        'image': 'assets/images/fetal/stage_04_6w.png',
        'label': '6 minggu',
        'desc': 'Tunas kecil lengan dan kaki mulai muncul. Tabung saraf otak dan sumsum tulang belakang menutup sempurna.',
      },
      {
        'image': 'assets/images/fetal/stage_05_7w.png',
        'label': '7 minggu',
        'desc': 'Bagian kepala membesar mengimbangi perkembangan otak yang pesat. Tonjolan ekor embrio perlahan menyusut.',
      },
      {
        'image': 'assets/images/fetal/stage_06_8_10w.png',
        'label': '8-10 minggu',
        'desc': 'Janin resmi kehilangan ekor embrioniknya. Jari tangan dan kaki mulai memisah, rahang serta hidung mulai terlihat.',
      },
      {
        'image': 'assets/images/fetal/stage_07_11_13w.png',
        'label': '11-13 minggu',
        'desc': 'Akhir Trimester 1. Kepala janin semakin membulat dan proporsional. Organ vital telah terbentuk dan mulai berfungsi.',
      },
      {
        'image': 'assets/images/fetal/stage_08_14_18w.png',
        'label': '14-18 minggu',
        'desc': 'Janin dapat menghisap jempol dan berekspresi. Sensasi gerakan halus janin (quickening) mungkin mulai dirasakan Bunda.',
      },
      {
        'image': 'assets/images/fetal/stage_09_19_22w.png',
        'label': '19-22 minggu',
        'desc': 'Kulit janin dilindungi lapisan vernix caseosa. Pendengaran janin berkembang tajam dan mampu merespons suara Bunda.',
      },
      {
        'image': 'assets/images/fetal/stage_10_23_29w.png',
        'label': '23-29 minggu',
        'desc': 'Kelopak mata mulai terbuka dan kelenjar paru memproduksi surfaktan untuk persiapan bernapas di dunia luar.',
      },
      {
        'image': 'assets/images/fetal/stage_11_30_35w.png',
        'label': '30-35 minggu',
        'desc': 'Cadangan lemak janin meningkat pesat membuat kulitnya makin mulus. Tulang semakin kuat dan janin mulai berputar kepala di bawah.',
      },
      {
        'image': 'assets/images/fetal/stage_12_36_41w.png',
        'label': '36-41 minggu',
        'desc': 'Siap Persalinan (Full Term). Organ paru dan otak telah matang sepenuhnya. Kepala janin masuk ke dalam rongga panggul.',
      },
    ];
  }

  String _getEstimatedLength(int weeks) {
    if (weeks <= 3) return '~0.1 cm';
    if (weeks == 4) return '~0.2 cm';
    if (weeks == 5) return '~0.3 cm';
    if (weeks == 6) return '~0.6 cm';
    if (weeks == 7) return '~1.3 cm';
    if (weeks <= 10) return '~2.5 cm';
    if (weeks <= 13) return '~6.0 cm';
    if (weeks <= 18) return '~14.0 cm';
    if (weeks <= 22) return '~26.0 cm';
    if (weeks <= 29) return '~36.0 cm';
    if (weeks <= 35) return '~45.0 cm';
    return '~50.5 cm';
  }

  String _getEstimatedWeight(int weeks) {
    if (weeks <= 6) return '< 1 gram';
    if (weeks <= 10) return '~4 gram';
    if (weeks <= 13) return '~23 gram';
    if (weeks <= 18) return '~190 gram';
    if (weeks <= 22) return '~460 gram';
    if (weeks <= 29) return '~1.200 gram';
    if (weeks <= 35) return '~2.400 gram';
    return '~3.300 gram';
  }

  String _getAnatomicalDescription(int weeks) {
    if (weeks <= 7) {
      return 'Trimester 1 (Tahap Embrio): Sel telur yang dibuahi bertumbuh menjadi blastosis, lalu menempel pada dinding rahim. Pembentukan tabung saraf, denyut jantung awal, serta tunas anggota gerak berlangsung pesat.';
    }
    if (weeks <= 13) {
      return 'Trimester 1 Akhir: Wujud janin terbentuk jelas dengan jari tangan dan kaki terpisah. Organ vital utama seperti jantung, otak, ginjal, dan hati mulai berfungsi secara mandiri.';
    }
    if (weeks <= 22) {
      return 'Trimester 2: Tulang janin mengeras (oksifikasi). Janin aktif berputar, menghisap jempol, serta dapat mendengarkan suara detak jantung ibu maupun suara dari luar perut.';
    }
    if (weeks <= 29) {
      return 'Trimester 2 Lanjut: Kelopak mata janin mulai terbuka. Perkembangan massa otot dan produksi lemak bawah kulit meningkat pesat.';
    }
    return 'Trimester 3: Pematangan fungsional organ paru-paru dan otak. Janin terus bertambah bobotnya dan memposisikan kepala ke arah rongga panggul menyambut momen persalinan.';
  }
}
