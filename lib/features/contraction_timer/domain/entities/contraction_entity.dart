import 'package:equatable/equatable.dart';

class ContractionEntity extends Equatable {
  final String id;
  final String pregnancyId;
  final DateTime startTime;
  final DateTime endTime;
  final int durationSeconds;
  final int intervalSeconds; // Jarak dari permulaan kontraksi sebelumnya
  final String intensityLevel; // 'ringan', 'sedang', 'kuat'

  const ContractionEntity({
    required this.id,
    required this.pregnancyId,
    required this.startTime,
    required this.endTime,
    required this.durationSeconds,
    required this.intervalSeconds,
    this.intensityLevel = 'sedang',
  });

  @override
  List<Object?> get props => [id, pregnancyId, startTime, endTime, durationSeconds, intervalSeconds, intensityLevel];
}
