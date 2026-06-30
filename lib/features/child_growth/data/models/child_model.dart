import '../../domain/entities/child_entity.dart';

class ChildModel extends ChildEntity {
  const ChildModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.gender,
    required super.dateOfBirth,
    required super.birthWeightKg,
    required super.birthLengthCm,
    super.childOrder,
  });

  factory ChildModel.fromFirestore(Map<String, dynamic> map, String docId, String userId) {
    return ChildModel(
      id: docId,
      userId: userId,
      name: map['name'] ?? 'Bayi CareLink',
      gender: map['gender'] ?? 'Laki-laki',
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.tryParse(map['dateOfBirth'].toString()) ?? DateTime.now() : DateTime.now(),
      birthWeightKg: (map['birthWeight'] ?? 3.2).toDouble(),
      birthLengthCm: (map['birthLength'] ?? 50.0).toDouble(),
      childOrder: map['childOrder'] ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'birthWeight': birthWeightKg,
      'birthLength': birthLengthCm,
      'childOrder': childOrder,
    };
  }

  factory ChildModel.fromJson(Map<String, dynamic> map) {
    return ChildModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      gender: map['gender'],
      dateOfBirth: DateTime.parse(map['dateOfBirth']),
      birthWeightKg: (map['birthWeight'] ?? 3.2).toDouble(),
      birthLengthCm: (map['birthLength'] ?? 50.0).toDouble(),
      childOrder: map['childOrder'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'birthWeight': birthWeightKg,
      'birthLength': birthLengthCm,
      'childOrder': childOrder,
    };
  }
}
