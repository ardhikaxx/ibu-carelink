import 'package:equatable/equatable.dart';

class SymptomLogEntity extends Equatable {
  final String id;
  final String pregnancyId;
  final DateTime date;
  final int nauseaLevel; // 1-5
  final int fatigueLevel; // 1-5
  final String moodNote;
  final List<String> triggers;

  const SymptomLogEntity({
    required this.id,
    required this.pregnancyId,
    required this.date,
    required this.nauseaLevel,
    required this.fatigueLevel,
    required this.moodNote,
    required this.triggers,
  });

  @override
  List<Object?> get props => [id, pregnancyId, date, nauseaLevel, fatigueLevel, moodNote, triggers];
}
