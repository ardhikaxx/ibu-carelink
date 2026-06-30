import 'package:equatable/equatable.dart';
import '../../domain/entities/immunization_entity.dart';

abstract class ImmunizationEvent extends Equatable {
  const ImmunizationEvent();

  @override
  List<Object?> get props => [];
}

class LoadImmunizationsEvent extends ImmunizationEvent {
  final String userId;
  final String childId;
  const LoadImmunizationsEvent({required this.userId, required this.childId});

  @override
  List<Object?> get props => [userId, childId];
}

class MarkImmunizationDoneEvent extends ImmunizationEvent {
  final ImmunizationEntity immunization;
  final String userId;
  final String batchNumber;
  final String clinicName;
  final DateTime dateAdministered;

  const MarkImmunizationDoneEvent({
    required this.immunization,
    required this.userId,
    required this.batchNumber,
    required this.clinicName,
    required this.dateAdministered,
  });

  @override
  List<Object?> get props => [immunization, userId, batchNumber, clinicName, dateAdministered];
}
