import 'package:equatable/equatable.dart';

abstract class ContractionTimerEvent extends Equatable {
  const ContractionTimerEvent();

  @override
  List<Object?> get props => [];
}

class StartContractionSessionEvent extends ContractionTimerEvent {
  final String pregnancyId;
  final String userId;
  const StartContractionSessionEvent({required this.pregnancyId, required this.userId});

  @override
  List<Object?> get props => [pregnancyId, userId];
}

class ToggleContractionEvent extends ContractionTimerEvent {
  final String intensity; // 'ringan', 'sedang', 'kuat'
  const ToggleContractionEvent([this.intensity = 'sedang']);

  @override
  List<Object?> get props => [intensity];
}

class TickContractionTimerEvent extends ContractionTimerEvent {
  final int currentDuration;
  final int currentInterval;
  const TickContractionTimerEvent({required this.currentDuration, required this.currentInterval});

  @override
  List<Object?> get props => [currentDuration, currentInterval];
}

class StopContractionSessionEvent extends ContractionTimerEvent {}

class LoadHistoryContractionsEvent extends ContractionTimerEvent {
  final String pregnancyId;
  final String userId;
  const LoadHistoryContractionsEvent({required this.pregnancyId, required this.userId});

  @override
  List<Object?> get props => [pregnancyId, userId];
}
