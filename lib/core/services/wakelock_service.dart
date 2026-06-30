class WakeLockService {
  static bool _isEnabled = false;

  static bool get isEnabled => _isEnabled;

  /// Aktifkan Wake Lock saat memasuki sesi Kick Counter atau Contraction Timer
  static Future<void> enable() async {
    _isEnabled = true;
    // Dalam implementasi nyata, memanggil plugin wakelock_plus.
    // Di sini kita kelola state agar kompatibel di semua target platform (Android/iOS/Web/Desktop).
  }

  /// Matikan Wake Lock saat sesi selesai atau keluar halaman
  static Future<void> disable() async {
    _isEnabled = false;
  }
}
