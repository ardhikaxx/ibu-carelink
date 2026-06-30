import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/emergency_alert_model.dart';

abstract class EmergencyRemoteDataSource {
  Future<EmergencyAlertModel> createAlert(EmergencyAlertModel alert);
}

class EmergencyRemoteDataSourceImpl implements EmergencyRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  EmergencyRemoteDataSourceImpl({required this.firestore, required this.auth});

  @override
  Future<EmergencyAlertModel> createAlert(EmergencyAlertModel alert) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw ServerException('Pengguna tidak terotentikasi.');
      }

      final docRef = firestore
          .collection('users')
          .doc(user.uid)
          .collection('emergency_alerts')
          .doc();

      final alertMap = alert.toFirestore();
      alertMap['userId'] = user.uid;

      await docRef.set(alertMap);

      return EmergencyAlertModel(
        id: docRef.id,
        triggeredAt: alert.triggeredAt,
        latitude: alert.latitude,
        longitude: alert.longitude,
        status: alert.status,
        notifiedContacts: alert.notifiedContacts,
      );
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(e.toString());
    }
  }
}
