import '../../domain/entities/milestone_entity.dart';

class MilestoneModel extends MilestoneEntity {
  const MilestoneModel({
    required super.id,
    required super.childId,
    required super.title,
    required super.domain,
    required super.targetAgeBand,
    required super.maxMonthBand,
    required super.isAchieved,
    super.achievedDate,
    super.notes,
  });

  factory MilestoneModel.fromFirestore(Map<String, dynamic> map, String docId, String childId) {
    return MilestoneModel(
      id: docId,
      childId: childId,
      title: map['title'] ?? '',
      domain: map['domain'] ?? 'Motorik Kasar',
      targetAgeBand: map['targetAgeBand'] ?? '0-3 bln',
      maxMonthBand: map['maxMonthBand'] ?? 3,
      isAchieved: map['isAchieved'] ?? false,
      achievedDate: map['achievedDate'] != null ? DateTime.tryParse(map['achievedDate'].toString()) : null,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'domain': domain,
      'targetAgeBand': targetAgeBand,
      'maxMonthBand': maxMonthBand,
      'isAchieved': isAchieved,
      'achievedDate': achievedDate?.toIso8601String(),
      'notes': notes,
    };
  }

  factory MilestoneModel.fromJson(Map<String, dynamic> map) {
    return MilestoneModel(
      id: map['id'],
      childId: map['childId'],
      title: map['title'],
      domain: map['domain'],
      targetAgeBand: map['targetAgeBand'],
      maxMonthBand: map['maxMonthBand'],
      isAchieved: map['isAchieved'],
      achievedDate: map['achievedDate'] != null ? DateTime.parse(map['achievedDate']) : null,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'domain': domain,
      'targetAgeBand': targetAgeBand,
      'maxMonthBand': maxMonthBand,
      'isAchieved': isAchieved,
      'achievedDate': achievedDate?.toIso8601String(),
      'notes': notes,
    };
  }
}
