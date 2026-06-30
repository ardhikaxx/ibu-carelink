import 'package:equatable/equatable.dart';

class KickSessionEntity extends Equatable {
  final String id;
  final String pregnancyId;
  final DateTime startTime;
  final int sessionDurationSeconds;
  final int totalKicks;
  final bool isCompleted;

  const KickSessionEntity({
    required this.id,
    required this.pregnancyId,
    required this.startTime,
    required this.sessionDurationSeconds,
    required this.totalKicks,
    required this.isCompleted,
  });

  bool get targetAchieved => totalKicks >= 10;

  @override
  List<Object?> get props => [id, pregnancyId, startTime, sessionDurationSeconds, totalKicks, isCompleted];
}
