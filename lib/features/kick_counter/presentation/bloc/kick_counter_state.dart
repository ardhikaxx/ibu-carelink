import 'package:equatable/equatable.dart';
import '../../domain/entities/kick_session_entity.dart';

abstract class KickCounterState extends Equatable {
  const KickCounterState();

  @override
  List<Object?> get props => [];
}

class KickCounterInitial extends KickCounterState {
  final List<KickSessionEntity> history;
  const KickCounterInitial({this.history = const []});

  @override
  List<Object?> get props => [history];
}

class KickCounterActive extends KickCounterState {
  final String pregnancyId;
  final String userId;
  final String sessionId;
  final DateTime startTime;
  final int elapsedSeconds;
  final int totalKicks;
  final List<KickSessionEntity> history;

  const KickCounterActive({
    required this.pregnancyId,
    required this.userId,
    required this.sessionId,
    required this.startTime,
    required this.elapsedSeconds,
    required this.totalKicks,
    this.history = const [],
  });

  bool get targetAchieved => totalKicks >= 10;
  bool get isTimeExceededWarning => elapsedSeconds >= 7200 && !targetAchieved; // > 2 jam & < 10 ketukan

  KickCounterActive copyWith({
    int? elapsedSeconds,
    int? totalKicks,
    List<KickSessionEntity>? history,
  }) {
    return KickCounterActive(
      pregnancyId: pregnancyId,
      userId: userId,
      sessionId: sessionId,
      startTime: startTime,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      totalKicks: totalKicks ?? this.totalKicks,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [pregnancyId, userId, sessionId, startTime, elapsedSeconds, totalKicks, history];
}

class KickCounterSaving extends KickCounterState {}

class KickCounterSuccess extends KickCounterState {
  final KickSessionEntity savedSession;
  final List<KickSessionEntity> history;
  const KickCounterSuccess({required this.savedSession, required this.history});

  @override
  List<Object?> get props => [savedSession, history];
}

class KickCounterError extends KickCounterState {
  final String message;
  const KickCounterError(this.message);

  @override
  List<Object?> get props => [message];
}
