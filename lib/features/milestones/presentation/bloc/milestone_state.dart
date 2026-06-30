import 'package:equatable/equatable.dart';
import '../../domain/entities/milestone_entity.dart';

abstract class MilestoneState extends Equatable {
  const MilestoneState();

  @override
  List<Object?> get props => [];
}

class MilestoneInitial extends MilestoneState {}

class MilestoneLoading extends MilestoneState {}

class MilestoneLoaded extends MilestoneState {
  final List<MilestoneEntity> milestones;
  final bool hasRedFlagWarning;
  const MilestoneLoaded({required this.milestones, required this.hasRedFlagWarning});

  @override
  List<Object?> get props => [milestones, hasRedFlagWarning];
}

class MilestoneError extends MilestoneState {
  final String message;
  const MilestoneError(this.message);

  @override
  List<Object?> get props => [message];
}
