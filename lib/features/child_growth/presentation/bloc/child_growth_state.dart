import 'package:equatable/equatable.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/growth_log_entity.dart';

abstract class ChildGrowthState extends Equatable {
  const ChildGrowthState();

  @override
  List<Object?> get props => [];
}

class ChildGrowthInitial extends ChildGrowthState {}

class ChildGrowthLoading extends ChildGrowthState {}

class ChildGrowthLoaded extends ChildGrowthState {
  final List<ChildEntity> children;
  final ChildEntity selectedChild;
  final List<GrowthLogEntity> logs;
  final bool hasMedicalAlert; // < -2 SD stunting or underweight

  const ChildGrowthLoaded({
    required this.children,
    required this.selectedChild,
    required this.logs,
    this.hasMedicalAlert = false,
  });

  @override
  List<Object?> get props => [children, selectedChild, logs, hasMedicalAlert];
}

class ChildGrowthEmpty extends ChildGrowthState {}

class ChildGrowthError extends ChildGrowthState {
  final String message;
  const ChildGrowthError(this.message);

  @override
  List<Object?> get props => [message];
}
