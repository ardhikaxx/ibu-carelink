import '../../domain/entities/kick_session_entity.dart';

class KickSessionModel extends KickSessionEntity {
  const KickSessionModel({
    required super.id,
    required super.pregnancyId,
    required super.startTime,
    required super.sessionDurationSeconds,
    required super.totalKicks,
    required super.isCompleted,
  });

  factory KickSessionModel.fromFirestore(Map<String, dynamic> map, String docId, String pregnancyId) {
    return KickSessionModel(
      id: docId,
      pregnancyId: pregnancyId,
      startTime: map['startTime'] != null ? DateTime.tryParse(map['startTime'].toString()) ?? DateTime.now() : DateTime.now(),
      sessionDurationSeconds: map['sessionDuration'] ?? 0,
      totalKicks: map['totalKicks'] ?? 0,
      isCompleted: map['isCompleted'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': startTime.toIso8601String(),
      'sessionDuration': sessionDurationSeconds,
      'totalKicks': totalKicks,
      'isCompleted': isCompleted,
    };
  }

  factory KickSessionModel.fromJson(Map<String, dynamic> map) {
    return KickSessionModel(
      id: map['id'],
      pregnancyId: map['pregnancyId'],
      startTime: DateTime.parse(map['startTime']),
      sessionDurationSeconds: map['sessionDuration'],
      totalKicks: map['totalKicks'],
      isCompleted: map['isCompleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregnancyId': pregnancyId,
      'startTime': startTime.toIso8601String(),
      'sessionDuration': sessionDurationSeconds,
      'totalKicks': totalKicks,
      'isCompleted': isCompleted,
    };
  }
}
