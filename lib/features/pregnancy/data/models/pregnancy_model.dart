import '../../domain/entities/pregnancy_entity.dart';

class PregnancyModel extends PregnancyEntity {
  const PregnancyModel({
    required super.id,
    required super.userId,
    required super.hpht,
    required super.estimatedDueDate,
    required super.prePregnancyWeight,
    super.isActive,
  });

  factory PregnancyModel.fromFirestore(Map<String, dynamic> map, String docId, String userId) {
    return PregnancyModel(
      id: docId,
      userId: userId,
      hpht: map['hpht'] != null ? DateTime.tryParse(map['hpht'].toString()) ?? DateTime.now() : DateTime.now(),
      estimatedDueDate: map['estimatedDueDate'] != null
          ? DateTime.tryParse(map['estimatedDueDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      prePregnancyWeight: (map['prePregnancyWeight'] ?? 55.0).toDouble(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'hpht': hpht.toIso8601String(),
      'estimatedDueDate': estimatedDueDate.toIso8601String(),
      'prePregnancyWeight': prePregnancyWeight,
      'isActive': isActive,
    };
  }

  factory PregnancyModel.fromJson(Map<String, dynamic> map) {
    return PregnancyModel(
      id: map['id'],
      userId: map['userId'],
      hpht: DateTime.parse(map['hpht']),
      estimatedDueDate: DateTime.parse(map['estimatedDueDate']),
      prePregnancyWeight: (map['prePregnancyWeight'] ?? 55.0).toDouble(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'hpht': hpht.toIso8601String(),
      'estimatedDueDate': estimatedDueDate.toIso8601String(),
      'prePregnancyWeight': prePregnancyWeight,
      'isActive': isActive,
    };
  }
}
