import 'package:equatable/equatable.dart';

enum AlertStatus { active, resolved, falseAlarm }

class EmergencyAlert extends Equatable {
  final String? id;
  final DateTime triggeredAt;
  final double latitude;
  final double longitude;
  final AlertStatus status;
  final List<String> notifiedContacts;

  const EmergencyAlert({
    this.id,
    required this.triggeredAt,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.notifiedContacts = const [],
  });

  @override
  List<Object?> get props => [id, triggeredAt, latitude, longitude, status, notifiedContacts];
}
