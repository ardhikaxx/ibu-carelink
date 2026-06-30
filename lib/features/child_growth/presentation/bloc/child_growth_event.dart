import 'package:equatable/equatable.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/entities/growth_log_entity.dart';

abstract class ChildGrowthEvent extends Equatable {
  const ChildGrowthEvent();

  @override
  List<Object?> get props => [];
}

class LoadChildrenEvent extends ChildGrowthEvent {
  final String userId;
  const LoadChildrenEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

class SelectChildEvent extends ChildGrowthEvent {
  final ChildEntity child;
  final String userId;
  const SelectChildEvent({required this.child, required this.userId});

  @override
  List<Object?> get props => [child, userId];
}

class AddNewChildEvent extends ChildGrowthEvent {
  final ChildEntity child;
  final String userId;
  const AddNewChildEvent({required this.child, required this.userId});

  @override
  List<Object?> get props => [child, userId];
}

class RecordGrowthLogEvent extends ChildGrowthEvent {
  final GrowthLogEntity log;
  final ChildEntity child;
  final String userId;
  const RecordGrowthLogEvent({required this.log, required this.child, required this.userId});

  @override
  List<Object?> get props => [log, child, userId];
}
