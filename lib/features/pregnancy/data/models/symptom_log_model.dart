import '../../domain/entities/symptom_log_entity.dart';

class SymptomLogModel extends SymptomLogEntity {
  const SymptomLogModel({
    required super.id,
    required super.pregnancyId,
    required super.date,
    required super.nauseaLevel,
    required super.fatigueLevel,
    required super.moodNote,
    required super.triggers,
  });

  factory SymptomLogModel.fromFirestore(Map<String, dynamic> map, String docId, String pregnancyId) {
    return SymptomLogModel(
      id: docId,
      pregnancyId: pregnancyId,
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      nauseaLevel: map['nauseaLevel'] ?? 1,
      fatigueLevel: map['fatigueLevel'] ?? 1,
      moodNote: map['moodNote'] ?? '',
      triggers: List<String>.from(map['triggers'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'date': date.toIso8601String(),
      'nauseaLevel': nauseaLevel,
      'fatigueLevel': fatigueLevel,
      'moodNote': moodNote,
      'triggers': triggers,
    };
  }

  factory SymptomLogModel.fromJson(Map<String, dynamic> map) {
    return SymptomLogModel(
      id: map['id'],
      pregnancyId: map['pregnancyId'],
      date: DateTime.parse(map['date']),
      nauseaLevel: map['nauseaLevel'] ?? 1,
      fatigueLevel: map['fatigueLevel'] ?? 1,
      moodNote: map['moodNote'] ?? '',
      triggers: List<String>.from(map['triggers'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pregnancyId': pregnancyId,
      'date': date.toIso8601String(),
      'nauseaLevel': nauseaLevel,
      'fatigueLevel': fatigueLevel,
      'moodNote': moodNote,
      'triggers': triggers,
    };
  }
}
