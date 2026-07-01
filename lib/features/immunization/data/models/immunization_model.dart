import '../../domain/entities/immunization_entity.dart';

class ImmunizationModel extends ImmunizationEntity {
  const ImmunizationModel({
    required super.id,
    required super.childId,
    required super.vaccineName,
    required super.targetAgeMonths,
    required super.isCompleted,
    super.dateAdministered,
    super.batchNumber,
    super.clinicName,
  });

  factory ImmunizationModel.fromFirestore(Map<String, dynamic> map, String docId, String childId) {
    return ImmunizationModel(
      id: docId,
      childId: childId,
      vaccineName: map['vaccineName'] ?? '',
      targetAgeMonths: map['targetAgeMonths'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      dateAdministered: map['dateAdministered'] != null ? DateTime.tryParse(map['dateAdministered'].toString()) : null,
      batchNumber: map['batchNumber'] ?? '',
      clinicName: map['clinicName'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'vaccineName': vaccineName,
      'targetAgeMonths': targetAgeMonths,
      'isCompleted': isCompleted,
      'status': isCompleted ? 'completed' : 'pending',
      'dateAdministered': dateAdministered?.toIso8601String(),
      'batchNumber': batchNumber,
      'clinicName': clinicName,
    };
  }

  factory ImmunizationModel.fromJson(Map<String, dynamic> map) {
    return ImmunizationModel(
      id: map['id'],
      childId: map['childId'],
      vaccineName: map['vaccineName'],
      targetAgeMonths: map['targetAgeMonths'],
      isCompleted: map['isCompleted'],
      dateAdministered: map['dateAdministered'] != null ? DateTime.parse(map['dateAdministered']) : null,
      batchNumber: map['batchNumber'] ?? '',
      clinicName: map['clinicName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'vaccineName': vaccineName,
      'targetAgeMonths': targetAgeMonths,
      'isCompleted': isCompleted,
      'dateAdministered': dateAdministered?.toIso8601String(),
      'batchNumber': batchNumber,
      'clinicName': clinicName,
    };
  }
}
