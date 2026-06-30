import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/emergency_alert.dart';

class EmergencyAlertModel extends EmergencyAlert {
  const EmergencyAlertModel({
    super.id,
    required super.triggeredAt,
    required super.latitude,
    required super.longitude,
    required super.status,
    super.notifiedContacts,
  });

  factory EmergencyAlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmergencyAlertModel(
      id: doc.id,
      triggeredAt: (data['triggeredAt'] as Timestamp).toDate(),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      status: AlertStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => AlertStatus.active,
      ),
      notifiedContacts: List<String>.from(data['notifiedContacts'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'triggeredAt': Timestamp.fromDate(triggeredAt),
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'notifiedContacts': notifiedContacts,
    };
  }
}
