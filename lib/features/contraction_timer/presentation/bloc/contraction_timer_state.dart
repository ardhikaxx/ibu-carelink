import 'package:equatable/equatable.dart';
import '../../domain/entities/contraction_entity.dart';

enum ContractionStatus { idle, contractionStarted, intervalRunning }

abstract class ContractionTimerState extends Equatable {
  const ContractionTimerState();

  @override
  List<Object?> get props => [];
}

class ContractionTimerInitial extends ContractionTimerState {
  final List<ContractionEntity> history;
  const ContractionTimerInitial({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class ContractionTimerActive extends ContractionTimerState {
  final String pregnancyId;
  final String userId;
  final ContractionStatus status;
  final DateTime? currentStartTime;
  final DateTime? lastEndTime;
  final int activeDurationSeconds;
  final int currentIntervalSeconds;
  final String currentIntensity;
  final List<ContractionEntity> history;
  final bool is511AlertActive;

  const ContractionTimerActive({
    required this.pregnancyId,
    required this.userId,
    required this.status,
    this.currentStartTime,
    this.lastEndTime,
    this.activeDurationSeconds = 0,
    this.currentIntervalSeconds = 0,
    this.currentIntensity = 'sedang',
    this.history = const [],
    this.is511AlertActive = false,
  });

  ContractionTimerActive copyWith({
    ContractionStatus? status,
    DateTime? currentStartTime,
    DateTime? lastEndTime,
    int? activeDurationSeconds,
    int? currentIntervalSeconds,
    String? currentIntensity,
    List<ContractionEntity>? history,
    bool? is511AlertActive,
  }) {
    return ContractionTimerActive(
      pregnancyId: pregnancyId,
      userId: userId,
      status: status ?? this.status,
      currentStartTime: currentStartTime ?? this.currentStartTime,
      lastEndTime: lastEndTime ?? this.lastEndTime,
      activeDurationSeconds: activeDurationSeconds ?? this.activeDurationSeconds,
      currentIntervalSeconds: currentIntervalSeconds ?? this.currentIntervalSeconds,
      currentIntensity: currentIntensity ?? this.currentIntensity,
      history: history ?? this.history,
      is511AlertActive: is511AlertActive ?? this.is511AlertActive,
    );
  }

  @override
  List<Object?> get props => [
        pregnancyId,
        userId,
        status,
        currentStartTime,
        lastEndTime,
        activeDurationSeconds,
        currentIntervalSeconds,
        currentIntensity,
        history,
        is511AlertActive,
      ];
}

class ContractionTimerSaving extends ContractionTimerState {}

class ContractionTimerSuccess extends ContractionTimerState {
  final List<ContractionEntity> history;
  const ContractionTimerSuccess(this.history);

  @override
  List<Object?> get props => [history];
}

class ContractionTimerError extends ContractionTimerState {
  final String message;
  const ContractionTimerError(this.message);

  @override
  List<Object?> get props => [message];
}
