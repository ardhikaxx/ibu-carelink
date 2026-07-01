import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomFloatingHeader(
        title: 'Kebijakan Privasi Medis',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Security Shield Banner Card (Rose Pink Theme)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryRose,
                    AppTheme.primaryRose.withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRose.withValues(alpha: 0.3),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
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
                      Icons.verified_user_rounded,
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
                          'Komitmen Privasi Total',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Data medis ibu hamil & balita dienkripsi berlapis sesuai standar UU PDP & HIPAA.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
              'Detail Perlindungan Data',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 14),

            _buildPolicySection(
              icon: Icons.health_and_safety_rounded,
              color: AppTheme.primaryRose,
              title: '1. Pengumpulan Data Kesehatan Maternal',
              content:
                  'Ibu CareLink mengumpulkan data metrik kesehatan yang Anda masukkan secara sukarela, seperti riwayat tekanan darah, catatan kontraksi rahim, hitungan tendangan janin, log pertumbuhan tinggi & berat badan balita, serta hasil skrining KPSP. Data ini diperlukan untuk memberikan analisis grafik dan peringatan medis dini.',
            ),
            const SizedBox(height: 14),

            _buildPolicySection(
              icon: Icons.lock_outline_rounded,
              color: AppTheme.primaryRose,
              title: '2. Enkripsi & Penyimpanan Offline-First',
              content:
                  'Aplikasi kami dirancang dengan arsitektur Offline-First. Seluruh data kesehatan disimpan secara lokal di dalam basis data terenkripsi pada perangkat Anda terlebih dahulu. Sinkronisasi cloud (Firebase Cloud Firestore) dilakukan secara aman menggunakan protokol enkripsi TLS/SSL standar perbankan.',
            ),
            const SizedBox(height: 14),

            _buildPolicySection(
              icon: Icons.do_not_disturb_alt_rounded,
              color: AppTheme.primaryRose,
              title: '3. Tanpa Komersialisasi Data',
              content:
                  'Kami tidak pernah memperjualbelikan, menyewakan, atau membagikan informasi medis pribadi atau data anak Anda kepada pengiklan, perusahaan asuransi, atau pihak ketiga mana pun. Identitas medis Anda adalah privasi mutlak yang tidak dapat diganggu gugat.',
            ),
            const SizedBox(height: 14),

            _buildPolicySection(
              icon: Icons.share_rounded,
              color: AppTheme.primaryRose,
              title: '4. Berbagi dengan Tenaga Medis',
              content:
                  'Anda memiliki kontrol penuh untuk mengekspor atau membagikan ringkasan catatan kesehatan (seperti kurva WHO atau log kontraksi) langsung kepada dokter spesialis kandungan atau bidan pendamping saat jadwal konsultasi.',
            ),
            const SizedBox(height: 14),

            _buildPolicySection(
              icon: Icons.manage_accounts_rounded,
              color: AppTheme.primaryRose,
              title: '5. Hak Penghapusan Data (Right to be Forgotten)',
              content:
                  'Sesuai regulasi pelindungan data pribadi, Anda berhak meminta penghapusan seluruh riwayat akun dan data medis kapan saja melalui menu pengaturan akun atau dengan menghubungi tim dukungan teknis kami.',
            ),
            const SizedBox(height: 28),

            // Contact Card (Rose Pink Theme)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.primaryRose.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mark_email_unread_rounded, color: AppTheme.primaryRose, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pertanyaan Tentang Privasi?',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Hubungi petugas proteksi data kami di privacy@ibucarelink.id',
                          style: TextStyle(fontSize: 12, color: const Color(0xFF64748B)),
                        ),
                      ],
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

  Widget _buildPolicySection({
    required IconData icon,
    required Color color,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
