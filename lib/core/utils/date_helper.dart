import 'package:intl/intl.dart';

class DateHelper {
  /// Hukum Naegele untuk kalkulasi Hari Perkiraan Lahir (HPL)
  /// Standar obstetri: HPHT ditambahkan 280 hari (40 minggu)
  static DateTime calculateDueDateNaegele(DateTime hpht) {
    return hpht.add(const Duration(days: 280));
  }

  /// Usia kehamilan dalam minggu berdasarkan HPHT
  static int calculateGestationalWeeks(DateTime hpht) {
    final diff = DateTime.now().difference(hpht).inDays;
    if (diff < 0) return 0;
    return diff ~/ 7;
  }

  /// Trimester saat ini (1, 2, atau 3)
  static int calculateTrimester(int weeks) {
    if (weeks <= 12) return 1;
    if (weeks <= 27) return 2;
    return 3;
  }

  /// Usia kronologis anak dalam bulan
  static int calculateAgeInMonths(DateTime dateOfBirth) {
    final now = DateTime.now();
    int months = (now.year - dateOfBirth.year) * 12 + now.month - dateOfBirth.month;
    if (now.day < dateOfBirth.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  /// Usia kronologis format teks (misal: "1 Tahun 3 Bulan")
  static String formatAgeText(DateTime dateOfBirth) {
    final months = calculateAgeInMonths(dateOfBirth);
    if (months < 12) {
      return '$months Bulan';
    }
    final years = months ~/ 12;
    final remMonths = months % 12;
    if (remMonths == 0) return '$years Tahun';
    return '$years Tahun $remMonths Bulan';
  }

  /// Format tanggal Indonesia standar (misal: 30 Juni 2026)
  static String formatIndonesianDate(DateTime date) {
    return DateFormat('dd MMMM yyyy').format(date);
  }

  /// Format jam pendek (misal: 14:30)
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }
}
