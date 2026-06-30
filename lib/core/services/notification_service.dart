import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> initialize() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        String? token = await _fcm.getToken();
        if (kDebugMode) {
          print('FCM Token terdaftar: $token');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('FCM Inisialisasi offline/simulasi: $e');
      }
    }
  }

  /// Simulasi trigger pengingat lokal (Vitamin, Jadwal USG, Vaksin IDAI, SOS Alert)
  void scheduleLocalReminder({required String title, required String body}) {
    if (kDebugMode) {
      print('[NOTIFICATION ALERT] $title: $body');
    }
  }
}
