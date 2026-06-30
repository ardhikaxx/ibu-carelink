import 'package:flutter/services.dart';

class HapticService {
  /// Umpan balik taktil saat menekan tombol tendangan janin (tanpa melihat layar)
  static Future<void> triggerKickImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Umpan balik ringan saat mulai atau selesai kontraksi
  static Future<void> triggerContractionImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Umpan balik darurat SOS (serangkaian getaran)
  static Future<void> triggerSosVibration() async {
    await HapticFeedback.vibrate();
  }
}
