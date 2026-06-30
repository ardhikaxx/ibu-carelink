import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';

class HelpFaqPage extends StatelessWidget {
  const HelpFaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomFloatingHeader(
        title: 'Bantuan & FAQ Ibu CareLink',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Help Center Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRose.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pusat Bantuan Ibu & Anak',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 17,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Temukan panduan klinis & solusi cepat untuk seluruh fitur skrining dan pemantauan.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Pertanyaan Sering Diajukan (FAQ)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            _buildFaqItem(
              question: 'Bagaimana cara menghitung tendangan janin yang tepat?',
              answer:
                  'Carilah waktu di mana janin biasanya aktif (setelah makan atau malam hari). Berbaring santai miring ke kiri, ketuk tombol hitung setiap kali merasakan tendangan, berguling, atau gerakan janin. Sesi normal adalah mencapai 10 gerakan dalam waktu kurang dari 2 jam.',
            ),
            const SizedBox(height: 12),

            _buildFaqItem(
              question: 'Apa arti peringatan Pola Kontraksi 5-1-1?',
              answer:
                  'Aturan 5-1-1 adalah standar obstetri internasional untuk persalinan aktif: Kontraksi terjadi setiap 5 menit sekali, berlangsung selama minimal 1 menit setiap sesinya, dan telah bertahan konsisten selama 1 jam berturut-turut. Segera bersiap menuju fasilitas kebidanan/rumah sakit terdekat bila pola ini terdeteksi.',
            ),
            const SizedBox(height: 12),

            _buildFaqItem(
              question: 'Bagaimana cara kerja fitur Skrining Preeklamsia?',
              answer:
                  'Fitur ini mengevaluasi kombinasi pembacaan tekanan darah (sistolik ≥ 140 mmHg atau diastolik ≥ 90 mmHg) bersama gejala penyerta klinis seperti sakit kepala hebat yang tidak hilang, gangguan penglihatan, dan pembengkakan ekstrem pada wajah atau tangan untuk mendeteksi risiko preeklamsia sejak dini.',
            ),
            const SizedBox(height: 12),

            _buildFaqItem(
              question: 'Apakah aplikasi tetap berjalan saat tidak ada internet?',
              answer:
                  'Ya, 100%! Ibu CareLink dibangun menggunakan teknologi Offline-First. Seluruh penghitung tendangan, pengatur waktu kontraksi, log gejala harian, dan kalkulasi grafik pertumbuhan WHO dapat diakses lancar di daerah terpencil tanpa koneksi internet.',
            ),
            const SizedBox(height: 12),

            _buildFaqItem(
              question: 'Bagaimana cara membaca Kurva Pertumbuhan WHO balita?',
              answer:
                  'Kurva WHO membandingkan tinggi badan (TB/U) atau berat badan (BB/U) anak dengan standar global seusianya. Area hijau menandakan pertumbuhan normal, sedangkan titik pada zona merah atau kuning merupakan indikasi untuk segera melakukan konsultasi nutrisi dengan dokter spesialis anak.',
            ),
            const SizedBox(height: 28),

            // Live Support Contact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.headset_mic_rounded, color: AppTheme.accentWarm, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Butuh Bantuan Langsung?',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tim dukungan teknis dan konselor maternal kami siap membantu kendala teknis atau pertanyaan Anda.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Menghubungkan ke WhatsApp Layanan Bantuan Ibu CareLink...'),
                            backgroundColor: AppTheme.primaryRose,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: const Text(
                        'Hubungi Dukungan WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: AppTheme.primaryRose,
          collapsedIconColor: const Color(0xFF64748B),
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          title: Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14.5,
              color: Color(0xFF0F172A),
            ),
          ),
          children: [
            Text(
              answer,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF475569),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
