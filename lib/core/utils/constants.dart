class AppConstants {
  static const String appName = 'Ibu CareLink';
  
  // Storage Keys
  static const String keyUserRole = 'user_role';
  static const String keyIsOffline = 'is_offline_mode';

  // IDAI 2024 Vaccination Master Schedule
  static const List<Map<String, dynamic>> idaiVaccineSchedule2024 = [
    {
      'id': 'hep_b_0',
      'name': 'Hepatitis B (Dosis 0)',
      'ageMonths': 0,
      'description': 'Diberikan dalam 24 jam setelah lahir',
      'phase': '0 Bulan (Pasca-Lahir)'
    },
    {
      'id': 'polio_0',
      'name': 'Polio Tetes Oral 0 (OPV)',
      'ageMonths': 0,
      'description': 'Diberikan saat kunjungan lahir sebelum pulang',
      'phase': '0 Bulan (Pasca-Lahir)'
    },
    {
      'id': 'bcg',
      'name': 'BCG (Tuberkulosis)',
      'ageMonths': 1,
      'description': 'Optimal diberikan sebelum usia 1 bulan',
      'phase': '0 Bulan (Pasca-Lahir)'
    },
    {
      'id': 'pentavalen_1',
      'name': 'Pentavalen 1 (DTP-HB-Hib 1) & Polio 1',
      'ageMonths': 2,
      'description': 'Pencegahan Difteri, Tetanus, Pertusis, Hep B, Hib & Polio',
      'phase': 'Bulan 2, 3, 4'
    },
    {
      'id': 'pcv_1',
      'name': 'PCV 1 & Rotavirus 1',
      'ageMonths': 2,
      'description': 'Pneumokokus dan diare Rotavirus dosis awal',
      'phase': 'Bulan 2, 3, 4'
    },
    {
      'id': 'pentavalen_2',
      'name': 'Pentavalen 2 (DTP-HB-Hib 2) & Polio 2',
      'ageMonths': 3,
      'description': 'Lanjutan dosis kedua Pentavalen',
      'phase': 'Bulan 2, 3, 4'
    },
    {
      'id': 'pentavalen_3',
      'name': 'Pentavalen 3 (DTP-HB-Hib 3), Polio 3 & IPV',
      'ageMonths': 4,
      'description': 'Lanjutan dosis ketiga Pentavalen dan Polio Suntik (IPV)',
      'phase': 'Bulan 2, 3, 4'
    },
    {
      'id': 'pcv_3',
      'name': 'PCV Penutup Dosis Dasar & Rotavirus',
      'ageMonths': 6,
      'description': 'Dosis penutup dasar Pneumokokus & Rotavirus',
      'phase': '6 Bulan'
    },
    {
      'id': 'influenza_1',
      'name': 'Influenza Dosis Inisial (Ganda)',
      'ageMonths': 6,
      'description': 'Diberikan dosis ganda dengan selang waktu 1 bulan',
      'phase': '6 Bulan'
    },
    {
      'id': 'hfmd_1',
      'name': 'HFMD (Flu Singapore) Dosis 1',
      'ageMonths': 6,
      'description': 'Rekomendasi IDAI 2024 untuk pencegahan Hand Foot Mouth Disease',
      'phase': '6 Bulan'
    },
    {
      'id': 'mr_1',
      'name': 'MR (Measles-Rubella) Dosis 1',
      'ageMonths': 9,
      'description': 'Pencegahan Campak dan Rubella',
      'phase': '9 Bulan'
    },
    {
      'id': 'je_1',
      'name': 'Japanese Encephalitis (JE)',
      'ageMonths': 9,
      'description': 'Untuk daerah endemis atau pertimbangan risiko',
      'phase': '9 Bulan'
    },
    {
      'id': 'booster_pcv',
      'name': 'Booster PCV & Booster DTP',
      'ageMonths': 12,
      'description': 'Penguatan imunitas memori anak di usia 1 tahun',
      'phase': '12 - 18 Bulan'
    },
    {
      'id': 'mmr_1',
      'name': 'MMR & Varicella (Cacar Air)',
      'ageMonths': 18,
      'description': 'Pencegahan Gondongan, Campak, Rubella dan Cacar Air',
      'phase': '12 - 18 Bulan'
    },
    {
      'id': 'tifoid_1',
      'name': 'Tifoid Dosis 1',
      'ageMonths': 24,
      'description': 'Diulang setiap 3 tahun',
      'phase': '2 Tahun ke Atas'
    },
  ];

  // CDC / Pediatric Developmental Milestones
  static const List<Map<String, dynamic>> developmentalMilestones = [
    {
      'id': 'm_2_1',
      'ageMonths': 2,
      'domain': 'Sosial-Emosional',
      'description': 'Menginisiasi senyum sosial ketika diajak bicara atau merespons senyuman'
    },
    {
      'id': 'm_2_2',
      'ageMonths': 2,
      'domain': 'Motorik Kasar',
      'description': 'Dapat mengangkat kepala sedikit saat dalam posisi tengkurap (tummy time)'
    },
    {
      'id': 'm_6_1',
      'ageMonths': 6,
      'domain': 'Motorik Kasar',
      'description': 'Berguling dari terlentang ke tengkurap dan sebaliknya secara aktif'
    },
    {
      'id': 'm_6_2',
      'ageMonths': 6,
      'domain': 'Bahasa',
      'description': 'Mengeluarkan suara ocehan (babbling) merespons percakapan'
    },
    {
      'id': 'm_12_1',
      'ageMonths': 12,
      'domain': 'Motorik Kasar',
      'description': 'Dapat berdiri sendiri dan mencoba melangkah sambil berpegangan'
    },
    {
      'id': 'm_12_2',
      'ageMonths': 12,
      'domain': 'Bahasa',
      'description': 'Mengucapkan suku kata bermakna seperti "mama" atau "papa"'
    },
    {
      'id': 'm_24_1',
      'ageMonths': 24,
      'domain': 'Motorik Kasar',
      'description': 'Berlari dan menendang bola dengan keseimbangan yang baik'
    },
    {
      'id': 'm_24_2',
      'ageMonths': 24,
      'domain': 'Kognitif',
      'description': 'Menggabungkan dua kata menjadi kalimat pendek (contoh: "mau minum")'
    },
    {
      'id': 'm_36_1',
      'ageMonths': 36,
      'domain': 'Motorik Halus',
      'description': 'Dapat melepaskan dan mengenakan pakaian sederhana sendiri'
    },
  ];

  // WHO Standard Reference (Weight & Height Median and SD values for estimation)
  // Boys Length/Height (cm) by age in months (approx -2 SD, Median, +2 SD)
  static const Map<int, List<double>> whoBoysHeight = {
    0: [46.1, 49.9, 55.6],
    6: [63.3, 67.6, 71.9],
    12: [71.0, 75.7, 80.5],
    24: [81.0, 87.1, 93.2],
    36: [88.7, 96.1, 103.5],
    60: [100.7, 110.0, 119.2],
  };

  // Girls Length/Height (cm) by age in months (approx -2 SD, Median, +2 SD)
  static const Map<int, List<double>> whoGirlsHeight = {
    0: [45.4, 49.1, 54.7],
    6: [61.2, 65.7, 70.3],
    12: [68.9, 74.0, 79.2],
    24: [80.0, 85.7, 92.9],
    36: [87.4, 95.1, 102.7],
    60: [99.9, 108.9, 118.9],
  };

  // Boys Weight (kg) by age in months (approx -2 SD, Median, +2 SD)
  static const Map<int, List<double>> whoBoysWeight = {
    0: [2.5, 3.3, 4.3],
    6: [6.4, 7.9, 9.8],
    12: [7.7, 9.6, 12.0],
    24: [9.7, 12.2, 15.3],
    36: [11.3, 14.3, 18.3],
    60: [14.1, 18.3, 24.2],
  };

  // Girls Weight (kg) by age in months (approx -2 SD, Median, +2 SD)
  static const Map<int, List<double>> whoGirlsWeight = {
    0: [2.4, 3.2, 4.2],
    6: [5.8, 7.3, 9.3],
    12: [7.0, 8.9, 11.5],
    24: [9.0, 11.5, 14.8],
    36: [10.8, 13.9, 18.1],
    60: [13.7, 18.2, 24.9],
  };
}
