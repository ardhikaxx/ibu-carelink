import 'package:equatable/equatable.dart';
import '../../domain/entities/milestone_entity.dart';

abstract class MilestoneEvent extends Equatable {
  const MilestoneEvent();

  @override
  List<Object?> get props => [];
}

class LoadMilestonesEvent extends MilestoneEvent {
  final String userId;
  final String childId;
  const LoadMilestonesEvent({required this.userId, required this.childId});

  @override
  List<Object?> get props => [userId, childId];
}

class ToggleMilestoneEvent extends MilestoneEvent {
  final MilestoneEntity milestone;
  final String userId;
  const ToggleMilestoneEvent({required this.milestone, required this.userId});

  @override
  List<Object?> get props => [milestone, userId];
}
