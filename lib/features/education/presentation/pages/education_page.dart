import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';

class Article {
  final String title;
  final String category; // 'Kehamilan', 'Menyusui', 'Nutrisi', 'Kedaruratan'
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
          'Trimester ketiga merupakan periode kritis penantian persalinan. Ibu hamil wajib segera menuju UGD atau fasilitas kebidanan terdekat apabila mengalami tanda berikut:\n\n1. Perdarahan per vaginam (merah segar ataupun gumpalan).\n2. Pusing hebat yang tidak hilang dengan istirahat disertai penglihatan kabur (gejala preeklamsia).\n3. Nyeri ulu hati hebat disertai bengkak berlebih pada wajah dan tangan.\n4. Gerakan janin berkurang drastis (< 10 tendangan dalam 2 jam).\n5. Ketuban pecah dini (keluar cairan bening hangat berbau amis tanpa bisa ditahan).\n\nJangan menunda evaluasi medis dalam situasi darurat ini.',
      isEmergencyGuide: true,
    ),
    Article(
      title: 'Nutrisi Emas 1000 Hari Pertama Kehidupan (HPK) Cegah Stunting',
      category: 'Nutrisi',
      readTime: '5 Menit Baca',
      summary: 'Asupan asam folat, zat besi, dan protein hewani berkualitas tinggi bagi ibu hamil serta MPASI bergizi seimbang.',
      content:
          'Seribu Hari Pertama Kehidupan (1000 HPK) dimulai sejak pembuahan janin dalam kandungan hingga anak berusia 2 tahun. Kunci utama mencegah stunting adalah:\n\n- Masa Kehamilan: Rutin mengonsumsi tablet tambah darah (TTD), asam folat, dan protein hewani (ikan, telur, daging).\n- ASI Eksklusif 0-6 Bulan: Tanpa tambahan air putih atau makanan lain.\n- MPASI Kaya Protein Hewani: Sejak usia 6 bulan, utamakan telur, hati ayam, atau ikan pada setiap suapan anak.',
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
          'Pelekatan yang tidak tepat adalah penyebab nomor satu puting lecet dan bayi rewel karena kurang ASI. Pastikan:\n\n- Seluruh areola (bagian gelap payudara) bagian bawah masuk ke dalam mulut bayi lebih banyak dibanding bagian atas.\n- Dagu bayi menempel erat pada payudara ibu.\n- Bibir bawah bayi terlipat keluar (dower).\n- Tidak terdengar bunyi berdecak, melainkan bunyi menelan yang teratur.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Semua'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipOval(
              child: Image.asset('assets/images/logo.png', width: 30, height: 30, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Text('Edukasi Ibu CareLink'),
          ],
        ),
        backgroundColor: AppTheme.primaryTeal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Emergency Hotline Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppTheme.errorRed.withValues(alpha: 0.12),
            child: Row(
              children: [
                const Icon(Icons.phone_in_talk_rounded, color: AppTheme.errorRed, size: 28),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Layanan Darurat Kebidanan / Ambulance', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.errorRed, fontSize: 13)),
                      Text('Hubungi 119 atau fasilitas kesehatan terdekat jika terjadi kegawatdaruratan maternal.', style: TextStyle(fontSize: 11, color: Color(0xFF7F1D1D))),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Menghubungkan ke Saluran Siaga Darurat 119...')),
                    );
                  },
                  child: const Text('Call 119', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          // Categories Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSel,
                    selectedColor: AppTheme.primaryTeal,
                    labelStyle: TextStyle(color: isSel ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: item.isEmergencyGuide ? AppTheme.errorRed.withValues(alpha: 0.5) : Colors.grey.shade200, width: item.isEmergencyGuide ? 1.5 : 1),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showArticleDetail(item),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: item.isEmergencyGuide ? AppTheme.errorRed.withValues(alpha: 0.12) : AppTheme.primaryTeal.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item.category,
                                  style: TextStyle(
                                    color: item.isEmergencyGuide ? AppTheme.errorRed : AppTheme.primaryTeal,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(item.readTime, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF0F172A))),
                          const SizedBox(height: 6),
                          Text(item.summary, style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.4)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
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
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 20),
              Chip(label: Text(article.category), backgroundColor: AppTheme.primaryTeal.withValues(alpha: 0.15), labelStyle: const TextStyle(color: AppTheme.primaryTeal, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(article.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              Text(article.readTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const Divider(height: 32),
              Text(article.content, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
