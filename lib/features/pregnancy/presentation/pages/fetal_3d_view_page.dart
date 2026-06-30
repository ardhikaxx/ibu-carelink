import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../domain/entities/pregnancy_entity.dart';

class Fetal3DViewPage extends StatelessWidget {
  final PregnancyEntity pregnancy;
  const Fetal3DViewPage({super.key, required this.pregnancy});

  @override
  Widget build(BuildContext context) {
    final weeks = pregnancy.gestationalWeeks;
    final analogy = pregnancy.fetalSizeFruitAnalogy;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualisasi Anatomi & Ukuran Janin'),
        backgroundColor: AppTheme.primaryRose,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF1F2), Color(0xFFF8FAFC)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'Usia Kehamilan: $weeks Minggu (Trimester ${pregnancy.trimester})',
                  style: const TextStyle(
                    color: AppTheme.primaryRose,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Visual Card Metafora Buah 3D
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE85A71), Color(0xFFD9465F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withOpacity(0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.child_care_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Ukuran Janin Analogis:',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      analogy,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Penjelasan Klinis Anatomi mingguan
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppTheme.primaryTeal),
                          SizedBox(width: 10),
                          Text(
                            'Perkembangan Anatomi Minggu Ini',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        _getAnatomicalDescription(weeks),
                        style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF334155)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Checklist Edukasi / Saran Medis mingguan
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tips_and_updates_rounded, color: AppTheme.accentWarm),
                          SizedBox(width: 10),
                          Text(
                            'Saran Medis & Nutrisi',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      _buildTipItem(
                        weeks <= 12
                            ? 'Pastikan konsumsi rutin Asam Folat (400-800 mcg) untuk pembentukan tabung saraf janin.'
                            : weeks <= 27
                                ? 'Konsumsi suplemen zat besi dan kalsium. Jadwalkan pemeriksaan USG anatomi untuk mengecek organ janin.'
                                : 'Siapkan tas persalinan dan perhatikan pola gerakan tendangan janin setiap hari.',
                      ),
                      const SizedBox(height: 10),
                      _buildTipItem('Minum air putih minimal 2,5 - 3 liter per hari dan istirahat cukup.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
        ),
      ],
    );
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
