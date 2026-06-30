import '../../domain/entities/contraction_entity.dart';

class ContractionModel extends ContractionEntity {
  const ContractionModel({
    required super.id,
    required super.pregnancyId,
    required super.startTime,
    required super.endTime,
    required super.durationSeconds,
    required super.intervalSeconds,
    super.intensityLevel,
  });

  factory ContractionModel.fromFirestore(Map<String, dynamic> map, String docId, String pregnancyId) {
    return ContractionModel(
      id: docId,
      pregnancyId: pregnancyId,
      startTime: map['startTime'] != null ? DateTime.tryParse(map['startTime'].toString()) ?? DateTime.now() : DateTime.now(),
      endTime: map['endTime'] != null ? DateTime.tryParse(map['endTime'].toString()) ?? DateTime.now() : DateTime.now(),
      durationSeconds: map['durationSeconds'] ?? 0,
      intervalSeconds: map['intervalSeconds'] ?? 0,
      intensityLevel: map['intensityLevel'] ?? 'sedang',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'intervalSeconds': intervalSeconds,
      'intensityLevel': intensityLevel,
    };
  }

  factory ContractionModel.fromJson(Map<String, dynamic> map) {
    return ContractionModel(
      id: map['id'],
      pregnancyId: map['pregnancyId'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      durationSeconds: map['durationSeconds'],
      intervalSeconds: map['intervalSeconds'],
      intensityLevel: map['intensityLevel'] ?? 'sedang',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregnancyId': pregnancyId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'durationSeconds': durationSeconds,
      'intervalSeconds': intervalSeconds,
      'intensityLevel': intensityLevel,
    };
  }
}
