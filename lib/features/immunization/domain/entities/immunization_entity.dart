import 'package:equatable/equatable.dart';

enum ImmunizationStatus { completed, upcoming, overdue }

class ImmunizationEntity extends Equatable {
  final String id;
  final String childId;
  final String vaccineName;
  final int targetAgeMonths;
  final bool isCompleted;
  final DateTime? dateAdministered;
  final String batchNumber;
  final String clinicName;

  const ImmunizationEntity({
    required this.id,
    required this.childId,
    required this.vaccineName,
    required this.targetAgeMonths,
    required this.isCompleted,
    this.dateAdministered,
    this.batchNumber = '',
    this.clinicName = '',
  });

  ImmunizationStatus getStatus(int currentChildAgeMonths) {
    if (isCompleted) return ImmunizationStatus.completed;
    if (currentChildAgeMonths > targetAgeMonths + 1) return ImmunizationStatus.overdue;
    return ImmunizationStatus.upcoming;
  }

  @override
  List<Object?> get props => [id, childId, vaccineName, targetAgeMonths, isCompleted, dateAdministered, batchNumber, clinicName];
}
