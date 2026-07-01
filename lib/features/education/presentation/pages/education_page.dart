import 'package:flutter/material.dart';
import '../../../../core/utils/theme.dart';
import '../../../../core/widgets/custom_floating_header.dart';

class Article {
  final String title;
  final String category;
  final String readTime;
  final String source;
  final String summary;
  final String content;
  final bool isEmergencyGuide;

  const Article({
    required this.title,
    required this.category,
    required this.readTime,
    required this.source,
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
  final List<String> _categories = ['Semua', 'Kehamilan', 'Menyusui', 'Nutrisi', 'Kedaruratan', 'Tumbuh Kembang'];

  final List<Article> _articles = const [
    Article(
      title: 'Tanda Bahaya Kehamilan Trimester 3 yang Waspada Segera',
      category: 'Kedaruratan',
      readTime: '4 Menit Baca',
      source: 'Buku KIA Kemenkes RI 2023 & POGI',
      summary: 'Kenali perdarahan jalan lahir, pusing hebat, pandangan kabur, dan gerakan janin berkurang sebagai tanda gawat darurat.',
      content:
          'Trimester ketiga merupakan periode kritis penantian persalinan. Berdasarkan panduan resmi Buku Kesehatan Ibu dan Anak (KIA) Kemenkes RI 2023 dan POGI, ibu hamil wajib segera menuju unit gawat darurat (UGD) atau fasilitas kebidanan terdekat apabila mengalami tanda berikut:\n\n'
          '1. Perdarahan per vaginam (merah segar ataupun gumpalan).\n'
          '2. Pusing hebat yang tidak hilang dengan istirahat disertai penglihatan kabur dan nyeri ulu hati (gejala klinis preeklamsia berat).\n'
          '3. Bengkak mendadak pada wajah, tangan, dan kaki disertai tekanan darah tinggi.\n'
          '4. Gerakan janin berkurang drastis (< 10 tendangan dalam periode 2 jam pemantauan aktif).\n'
          '5. Ketuban pecah dini (keluar cairan bening hangat berbau manis/amis yang tidak dapat ditahan).\n\n'
          'Jangan menunda atau menunggu hingga esok hari dalam situasi darurat ini demi keselamatan ibu dan janin.',
      isEmergencyGuide: true,
    ),
    Article(
      title: 'Nutrisi Emas 1000 Hari Pertama Kehidupan (HPK) Cegah Stunting',
      category: 'Nutrisi',
      readTime: '5 Menit Baca',
      source: 'Pedoman Pencegahan Stunting Kemenkes RI & IDAI',
      summary: 'Asupan tablet tambah darah (TTD), asam folat, dan protein hewani berkualitas tinggi sejak masa kehamilan hingga anak 2 tahun.',
      content:
          'Seribu Hari Pertama Kehidupan (1000 HPK) dimulai sejak masa pembuahan (270 hari kehamilan) hingga anak berusia 2 tahun (730 hari). Periode ini merupakan masa keemasan perkembangan otak dan pertumbuhan fisik anak. Kunci utama mencegah stunting menurut Kemenkes RI adalah:\n\n'
          '• Masa Kehamilan: Rutin mengonsumsi minimal 90 Tablet Tambah Darah (TTD) selama hamil, asam folat, kalsium, dan protein hewani (ikan, telur, ayam, daging).\n'
          '• ASI Eksklusif 0-6 Bulan: Berikan ASI saja tanpa tambahan air putih, madu, atau makanan apapun.\n'
          '• MPASI Kaya Protein Hewani: Sejak usia 6 bulan, wajib menyertakan sumber protein hewani pada setiap suapan anak (minimal 1 butir telur atau hati ayam per hari).',
    ),
    Article(
      title: 'Panduan Manajemen Kontraksi & Teknik Pernapasan Persalinan',
      category: 'Kehamilan',
      readTime: '3 Menit Baca',
      source: 'Pedoman Pelayanan Antenatal Kemenkes RI',
      summary: 'Cara membedakan kontraksi palsu Braxton Hicks dengan persalinan aktif Aturan 5-1-1 serta teknik napas rileks.',
      content:
          'Saat gelombang persalinan (kontraksi) datang, kepanikan akan memicu hormon adrenalin yang justru mempertegang otot rahim dan menambah rasa nyeri. Praktikkan manajemen persalinan berikut:\n\n'
          '1. Kenali Aturan 5-1-1 Persalinan Aktif: Kontraksi terjadi setiap 5 menit sekali, durasi minimal 1 menit, dan berlangsung konsisten selama 1 jam.\n'
          '2. Teknik Napas Dalam: Tarik napas perlahan melalui hidung hitungan 1-2-3-4 hingga perut mengembang, lalu hembuskan lewat mulut santai seolah meniup lilin.\n'
          '3. Pijatan Counter-Pressure: Pendamping persalinan (suami) memberikan penekanan lembut tapi tegas pada tulang ekor atau punggung bawah ibu saat gelombang kontraksi berlangsung.',
    ),
    Article(
      title: 'Sukses Mengasihi: Mengatasi Pelekatan (Latch-On) yang Nyeri',
      category: 'Menyusui',
      readTime: '4 Menit Baca',
      source: 'Rekomendasi Satgas ASI IDAI & AIMI',
      summary: 'Posisi menyusui yang benar agar puting tidak lecet dan pengosongan payudara optimal sesuai kebutuhan bayi.',
      content:
          'Pelekatan yang tidak tepat adalah penyebab utama puting lecet, mastitis, dan bayi rewel karena kurang ASI. Berdasarkan rekomendasi IDAI, pastikan tanda pelekatan benar (AMOP):\n\n'
          '• Areola (bagian gelap payudara) bagian bawah masuk ke dalam mulut bayi lebih banyak dibanding bagian atas.\n'
          '• Mulut terbuka lebar (M) dan dagu bayi menempel erat langsung pada payudara ibu.\n'
          '• Bibir bawah dan atas bayi terlipat keluar (dower/flanged out).\n'
          '• Pipi bayi membulat dan tidak terdengar bunyi berdecak (klik), melainkan suara menelan ASI yang teratur dan tenang.',
    ),
    Article(
      title: 'Jadwal & Pentingnya Imunisasi Dasar Lengkap Bayi 0-12 Bulan',
      category: 'Tumbuh Kembang',
      readTime: '5 Menit Baca',
      source: 'Jadwal Imunisasi IDAI 2024 & Permenkes RI No. 12 Tahun 2017',
      summary: 'Daftar vaksin wajib pemerintah & IDAI untuk perlindungan maksimal dari Penyakit yang Dapat Dicegah dengan Imunisasi (PD3I).',
      content:
          'Imunisasi dasar lengkap merupakan hak anak yang dijamin oleh Permenkes RI dan Ikatan Dokter Anak Indonesia (IDAI) 2024 untuk mencegah kesakitan, kecacatan, dan kematian akibat PD3I. Jadwal wajib pada usia < 1 tahun:\n\n'
          '• Baru Lahir (< 24 jam): Hepatitis B 0\n'
          '• Usia 1 Bulan: BCG & Polio Tetes 1\n'
          '• Usia 2 Bulan: DPT-HB-Hib 1, Polio Tetes 2, PCV 1, Rotavirus 1\n'
          '• Usia 3 Bulan: DPT-HB-Hib 2, Polio Tetes 3, PCV 2, Rotavirus 2\n'
          '• Usia 4 Bulan: DPT-HB-Hib 3, Polio Tetes 4, Polio Suntik (IPV) 1, Rotavirus 3\n'
          '• Usia 9 Bulan: Campak - Rubella (MR)\n\n'
          'Imunisasi terbukti secara ilmiah sangat aman dan merangsang pembentukan antibodi spesifik pada anak.',
    ),
    Article(
      title: 'Memahami Z-Score Berat & Tinggi Badan Bayi (WHO / Kemenkes)',
      category: 'Tumbuh Kembang',
      readTime: '4 Menit Baca',
      source: 'Permenkes RI No. 2 Tahun 2020 tentang Standar Antropometri Anak',
      summary: 'Cara membaca kurva pertumbuhan standar WHO dan mendeteksi dini risiko gizi kurang, gizi buruk, atau stunting.',
      content:
          'Berdasarkan Permenkes RI No. 2 Tahun 2020, penilaian status gizi anak di Indonesia wajib menggunakan standar kurva antropometri WHO dengan perhitungan Z-Score:\n\n'
          '• Status Normal (Gizi Baik): Z-Score berada di antara -2 SD sampai dengan +1 SD.\n'
          '• Gizi Kurang (Underweight / Wasting): Z-Score berada di antara -3 SD sampai dengan <-2 SD.\n'
          '• Stunting (Pendek): Panjang/Tinggi badan menurut umur berada pada Z-Score <-2 SD.\n\n'
          'Penting bagi orang tua untuk membawa anak rutin menimbang ke Posyandu atau fasilitas kesehatan setiap bulan agar *Weight Faltering* (berat badan tidak naik adekuat) dapat segera diintervensi oleh dokter.',
    ),
    Article(
      title: 'Deteksi Dini Perkembangan Anak dengan Buku KPSP (0-72 Bulan)',
      category: 'Tumbuh Kembang',
      readTime: '4 Menit Baca',
      source: 'Pedoman SDIDTK Kemenkes RI',
      summary: 'Evaluasi berkala 4 aspek tumbuh kembang: motorik kasar, motorik halus, bicara & bahasa, serta sosialisasi kemandirian.',
      content:
          'Kuesioner Pra Skrining Perkembangan (KPSP) adalah instrumen resmi Kemenkes RI dalam Program SDIDTK untuk mendeteksi keterlambatan perkembangan anak secara dini pada rentang usia 3, 6, 9, 12, hingga 72 bulan.\n\n'
          'Interpretasi Hasil Penilaian KPSP:\n'
          '• Sesuai (S): Jawaban YA berjumlah 9-10. Perkembangan anak optimal sesuai usianya. Lanjutkan stimulasi rutin.\n'
          '• Meragukan (M): Jawaban YA berjumlah 7-8. Jadwalkan kunjungan ulang 2 minggu kemudian dan intensifkan stimulasi di rumah.\n'
          '• Penyimpangan (P): Jawaban YA <= 6. Segera rujuk anak ke dokter spesialis anak atau klinik tumbuh kembang untuk pemeriksaan lebih mendalam.',
    ),
    Article(
      title: 'Asupan Besi & Asam Folat untuk Pencegahan Anemia Ibu Hamil',
      category: 'Nutrisi',
      readTime: '4 Menit Baca',
      source: 'Program Penanggulangan Anemia Kemenkes RI & WHO',
      summary: 'Mengapa anemia meningkatkan risiko perdarahan pascapersalinan dan BBLR, serta aturan minum TTD yang benar.',
      content:
          'Anemia pada ibu hamil (Kadar Hemoglobin < 11 g/dL) merupakan ancaman serius karena meningkatkan risiko perdarahan hebat saat persalinan, kelahiran prematur, dan Bayi Berat Lahir Rendah (BBLR).\n\n'
          'Aturan Minum Tablet Tambah Darah (TTD) agar Penyerapan Maksimal:\n'
          '1. Minum TTD bersama air putih atau jus jeruk yang kaya Vitamin C untuk melipatgandakan penyerapan zat besi.\n'
          '2. HINDARI minum TTD bersama teh, kopi, atau susu karena kandungan tanin dan kalsium menghambat penyerapan zat besi hingga 80%.\n'
          '3. Jika mual, konsumsi tablet sebelum tidur malam.',
    ),
    Article(
      title: 'Pertolongan Pertama Demam & Kejang Demam pada Bayi di Rumah',
      category: 'Kedaruratan',
      readTime: '5 Menit Baca',
      source: 'Rekomendasi Penatalaksanaan Kejang Demam IDAI',
      summary: 'Langkah tenang menghadapi suhu tinggi (>38°C) dan kejang demam agar anak terhindar dari cedera fatal.',
      content:
          'Kejang demam dapat terjadi pada anak usia 6 bulan hingga 5 tahun akibat kenaikan suhu tubuh mendadak (>38°C). Pedoman pertolongan pertama menurut IDAI:\n\n'
          '1. TETAP TENANG dan jangan panik. Letakkan anak di tempat datar, luas, dan aman agar tidak terbentur.\n'
          '2. Posisikan tubuh miring ke samping (posisi pulih) agar lendir atau muntahan keluar dan tidak menyumbat jalan napas.\n'
          '3. JANGAN memasukkan sendok, jari, kopi, atau benda apapun ke dalam mulut anak karena berisiko menyumbat jalan napas atau merusak gigi.\n'
          '4. Catat durasi kejang. Jika kejang berlangsung > 5 menit atau anak tidak sadarkan diri setelah kejang, segera bawa ke UGD terdekat.',
      isEmergencyGuide: true,
    ),
    Article(
      title: 'Manajemen Penyimpanan ASI Perah (ASIP) bagi Ibu Bekerja',
      category: 'Menyusui',
      readTime: '4 Menit Baca',
      source: 'Pedoman ASI Eksklusif Kemenkes RI & Satgas ASI IDAI',
      summary: 'Durasi tahan lama ASIP di suhu ruang, kulkas, dan freezer serta prinsip FIFO (First In First Out).',
      content:
          'Ibu bekerja tetap dapat sukses memberikan ASI Eksklusif dengan menerapkan manajemen penyimpanan ASIP yang higienis sesuai pedoman IDAI:\n\n'
          '• Suhu Ruang (< 25°C): Tahan hingga 4 jam.\n'
          '• Chiller/Kulkas Bawah (4°C): Tahan hingga 4-5 hari.\n'
          '• Freezer Kulkas 2 Pintu (-18°C): Tahan hingga 3-6 bulan.\n\n'
          'Prinsip Penghangatan & Pemberian:\n'
          'Gunakan aturan FIFO (First In First Out) di mana ASI yang diperah lebih awal digunakan terlebih dahulu. Rendam botol ASIP di dalam wadah berisi air hangat (jangan merebus langsung di atas api atau memakai microwave agar kandungan nutrisi & antibodi ASI tidak rusak).',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Semua'
        ? _articles
        : _articles.where((a) => a.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomFloatingHeader(
        title: 'Edukasi Ibu CareLink',
        showBackButton: false,
        leading: ClipOval(
          child: Image.asset(
            'assets/images/logo.png',
            width: 42,
            height: 42,
            fit: BoxFit.cover,
          ),
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
                        'Tekan untuk panggilan cepat saat tanda bahaya kehamilan/persalinan.',
                        style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 11.5, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category Chips Filter
          SizedBox(
            height: 54,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _selectedCategory = cat),
                    backgroundColor: Colors.white,
                    selectedColor: AppTheme.primaryRose,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryRose : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Articles List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                final isEmg = item.isEmergencyGuide;
                final accentColor = isEmg ? AppTheme.errorRed : AppTheme.primaryRose;

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
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.verified_user_rounded, size: 13.5, color: AppTheme.primaryRose),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Sumber: ${item.source}',
                                  style: const TextStyle(color: AppTheme.primaryRose, fontSize: 11.5, fontWeight: FontWeight.w700),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            child: Divider(color: Color(0xFFF1F5F9), height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Baca Panduan Lengkap', style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.w800, fontSize: 12.5)),
                              Icon(Icons.arrow_forward_rounded, size: 16, color: AppTheme.primaryRose),
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
                  color: (article.isEmergencyGuide ? AppTheme.errorRed : AppTheme.primaryRose).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  article.category,
                  style: TextStyle(
                    color: article.isEmergencyGuide ? AppTheme.errorRed : AppTheme.primaryRose,
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
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primaryRose.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.verified_rounded, color: AppTheme.primaryRose, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Rujukan Ilmiah & Regulasi:',
                            style: TextStyle(color: Color(0xFF0F172A), fontSize: 11.0, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            article.source,
                            style: const TextStyle(color: AppTheme.primaryRose, fontSize: 12.5, fontWeight: FontWeight.w800, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
