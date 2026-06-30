import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';

class Article {
  final String title;
  final String category;
  final String readTime;
  final String summary;
  final String content;
  final bool isEmergencyGuide;

  const Article({
    required this.title,
    required this.category,
    required this.readTime,
    required this.summary,
    required this.content,
    this.isEmergencyGuide = false,
  });
}

class EducationPage extends StatefulWidget {
  const EducationPage({super.key});

  @override
  State<EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Kehamilan', 'Menyusui', 'Nutrisi', 'Kedaruratan'];

  final List<Article> _articles = const [
    Article(
      title: 'Tanda Bahaya Kehamilan Trimester 3 yang Waspada Segera',
      category: 'Kedaruratan',
      readTime: '4 Menit Baca',
      summary: 'Kenali perdarahan jalan lahir, pusing hebat, pandangan kabur, dan gerakan janin berkurang sebagai tanda gawat janin.',
      content:
          'Trimester ketiga merupakan periode kritis penantian persalinan. Ibu hamil wajib segera menuju darurat atau fasilitas kebidanan terdekat apabila mengalami tanda berikut:\n\n1. Perdarahan per vaginam (merah segar ataupun gumpalan).\n2. Pusing hebat yang tidak hilang dengan istirahat disertai penglihatan kabur (gejala preeklamsia).\n3. Nyeri ulu hati hebat disertai bengkak berlebih pada wajah dan tangan.\n4. Gerakan janin berkurang drastis (< 10 tendangan dalam 2 jam).\n5. Ketuban pecah dini (keluar cairan bening hangat berbau amis tanpa bisa ditahan).\n\nJangan menunda evaluasi medis dalam situasi darurat ini.',
      isEmergencyGuide: true,
    ),
    Article(
      title: 'Nutrisi Emas 1000 Hari Pertama Kehidupan (HPK) Cegah Stunting',
      category: 'Nutrisi',
      readTime: '5 Menit Baca',
      summary: 'Asupan asam folat, zat besi, dan protein hewani berkualitas tinggi bagi ibu hamil serta MPASI bergizi seimbang.',
      content:
          'Seribu Hari Pertama Kehidupan (1000 HPK) dimulai sejak pembuahan janin dalam kandungan hingga anak berusia 2 tahun. Kunci utama mencegah stunting adalah:\n\n• Masa Kehamilan: Rutin mengonsumsi tablet tambah darah (TTD), asam folat, dan protein hewani (ikan, telur, daging).\n• ASI Eksklusif 0-6 Bulan: Tanpa tambahan air putih atau makanan lain.\n• MPASI Kaya Protein Hewani: Sejak usia 6 bulan, utamakan telur, hati ayam, atau ikan pada setiap suapan anak.',
    ),
    Article(
      title: 'Panduan Manajemen Kontraksi & Teknik Pernapasan Persalinan',
      category: 'Kehamilan',
      readTime: '3 Menit Baca',
      summary: 'Cara membedakan kontraksi palsu Braxton Hicks dengan persalinan aktif Aturan 5-1-1 serta teknik napas rileks.',
      content:
          'Saat gelombang cinta (kontraksi) datang, kepanikan akan memicu hormon adrenalin yang justru mempertegang otot rahim. Praktikkan teknik napas dalam:\n\n1. Tarik napas perlahan melalui hidung hitungan 1-2-3-4.\n2. Hembuskan perlahan lewat mulut dengan santai seolah meniup lilin.\n3. Libatkan pendamping (suami) untuk memberikan pijatan lembut pada punggung bawah (counter-pressure).',
    ),
    Article(
      title: 'Sukses Mengasihi: Mengatasi Pelekatan (Latch-on) yang Nyeri',
      category: 'Menyusui',
      readTime: '4 Menit Baca',
      summary: 'Posisi menyusui yang benar agar puting tidak lecet dan produksi ASI melimpah sesuai kebutuhan bayi.',
      content:
          'Pelekatan yang tidak tepat adalah penyebab nomor satu puting lecet dan bayi rewel karena kurang ASI. Pastikan:\n\n• Seluruh areola (bagian gelap payudara) bagian bawah masuk ke dalam mulut bayi lebih banyak dibanding bagian atas.\n• Dagu bayi menempel erat pada payudara ibu.\n• Bibir bawah bayi terlipat keluar (dower).\n• Tidak terdengar bunyi berdecak, melainkan bunyi menelan yang teratur.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Semua'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset('assets/images/logo.png', width: 28, height: 28, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text(
              'Edukasi Ibu CareLink',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: Column(
        children: [
          // Emergency Hotline Banner Card
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(color: AppTheme.errorRed, shape: BoxShape.circle),
                  child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Siaga Darurat Kebidanan 119',
                        style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.errorRed, fontSize: 13.5),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Segera hubungi ambulans apabila mengalami perdarahan akut.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF991B1B), height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Menghubungkan ke Saluran Siaga Darurat 119...'),
                        backgroundColor: AppTheme.errorRed,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: const Text('Call 119', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          // Categories Filter Switcher
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSel ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          color: isSel ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Articles List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isEmg = item.isEmergencyGuide;
                final accentColor = isEmg ? AppTheme.errorRed : AppTheme.primaryTeal;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: isEmg ? AppTheme.errorRed.withValues(alpha: 0.3) : const Color(0xFFF1F5F9)),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => _showArticleDetail(item),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: accentColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isEmg ? Icons.warning_amber_rounded : Icons.menu_book_rounded,
                                      size: 13,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      item.category,
                                      style: TextStyle(color: accentColor, fontSize: 11.5, fontWeight: FontWeight.w800),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 13, color: Color(0xFF94A3B8)),
                                  const SizedBox(width: 4),
                                  Text(item.readTime, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A), height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.summary,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, height: 1.5),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Baca Panduan Lengkap', style: TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.w800, fontSize: 12.5)),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryTeal),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showArticleDetail(Article article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (article.isEmergencyGuide ? AppTheme.errorRed : AppTheme.primaryTeal).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.category,
                  style: TextStyle(
                    color: article.isEmergencyGuide ? AppTheme.errorRed : AppTheme.primaryTeal,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                article.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), height: 1.35),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule_rounded, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 5),
                  Text(article.readTime, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w600)),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Color(0xFFF1F5F9), height: 1),
              ),
              Text(
                article.content,
                style: const TextStyle(fontSize: 15, height: 1.7, color: Color(0xFF334155), fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
