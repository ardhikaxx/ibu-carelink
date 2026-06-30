import 'package:equatable/equatable.dart';
import 'zscore_evaluation.dart';

class GrowthLogEntity extends Equatable {
  final String id;
  final String childId;
  final DateTime measurementDate;
  final double weightKg;
  final double heightCm;
  final double headCircumferenceCm;
  final ZScoreEvaluation? evaluation;

  const GrowthLogEntity({
    required this.id,
    required this.childId,
    required this.measurementDate,
    required this.weightKg,
    required this.heightCm,
    required this.headCircumferenceCm,
    this.evaluation,
  });

  @override
  List<Object?> get props => [id, childId, measurementDate, weightKg, heightCm, headCircumferenceCm, evaluation];
}
