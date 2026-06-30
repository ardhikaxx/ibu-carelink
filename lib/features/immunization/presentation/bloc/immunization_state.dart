import 'package:equatable/equatable.dart';
import '../../domain/entities/immunization_entity.dart';

abstract class ImmunizationState extends Equatable {
  const ImmunizationState();

  @override
  List<Object?> get props => [];
}

class ImmunizationInitial extends ImmunizationState {}

class ImmunizationLoading extends ImmunizationState {}

class ImmunizationLoaded extends ImmunizationState {
  final List<ImmunizationEntity> immunizations;
  final int childAgeMonths;
  const ImmunizationLoaded({required this.immunizations, required this.childAgeMonths});

  @override
  List<Object?> get props => [immunizations, childAgeMonths];
}

class ImmunizationError extends ImmunizationState {
  final String message;
  const ImmunizationError(this.message);

  @override
  List<Object?> get props => [message];
}
