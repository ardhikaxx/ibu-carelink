import 'package:equatable/equatable.dart';

abstract class KickCounterEvent extends Equatable {
  const KickCounterEvent();

  @override
  List<Object?> get props => [];
}

class StartKickSessionEvent extends KickCounterEvent {
  final String pregnancyId;
  final String userId;
  const StartKickSessionEvent({required this.pregnancyId, required this.userId});

  @override
  List<Object?> get props => [pregnancyId, userId];
}

class RecordKickEvent extends KickCounterEvent {}

class TickTimerEvent extends KickCounterEvent {
  final int elapsedSeconds;
  const TickTimerEvent(this.elapsedSeconds);

  @override
  List<Object?> get props => [elapsedSeconds];
}

class StopAndSaveSessionEvent extends KickCounterEvent {}

class LoadHistorySessionsEvent extends KickCounterEvent {
  final String pregnancyId;
  final String userId;
  const LoadHistorySessionsEvent({required this.pregnancyId, required this.userId});

  @override
  List<Object?> get props => [pregnancyId, userId];
}
