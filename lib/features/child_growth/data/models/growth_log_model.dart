import '../../domain/entities/growth_log_entity.dart';
import '../../domain/entities/zscore_evaluation.dart';

class GrowthLogModel extends GrowthLogEntity {
  const GrowthLogModel({
    required super.id,
    required super.childId,
    required super.measurementDate,
    required super.weightKg,
    required super.heightCm,
    required super.headCircumferenceCm,
    super.evaluation,
  });

  factory GrowthLogModel.fromFirestore(Map<String, dynamic> map, String docId, String childId, {int? ageMonths, String? gender}) {
    final weight = (map['weightKg'] ?? 5.0).toDouble();
    final height = (map['heightCm'] ?? 60.0).toDouble();
    final head = (map['headCircumferenceCm'] ?? 38.0).toDouble();

    ZScoreEvaluation? eval;
    if (ageMonths != null && gender != null) {
      eval = ZScoreEvaluation.evaluate(
        ageMonths: ageMonths,
        gender: gender,
        weightKg: weight,
        heightCm: height,
      );
    }

    return GrowthLogModel(
      id: docId,
      childId: childId,
      measurementDate: map['measurementDate'] != null ? DateTime.tryParse(map['measurementDate'].toString()) ?? DateTime.now() : DateTime.now(),
      weightKg: weight,
      heightCm: height,
      headCircumferenceCm: head,
      evaluation: eval,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'measurementDate': measurementDate.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'headCircumferenceCm': headCircumferenceCm,
    };
  }

  factory GrowthLogModel.fromJson(Map<String, dynamic> map) {
    return GrowthLogModel(
      id: map['id'],
      childId: map['childId'],
      measurementDate: DateTime.parse(map['measurementDate']),
      weightKg: (map['weightKg'] ?? 5.0).toDouble(),
      heightCm: (map['heightCm'] ?? 60.0).toDouble(),
      headCircumferenceCm: (map['headCircumferenceCm'] ?? 38.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'measurementDate': measurementDate.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'headCircumferenceCm': headCircumferenceCm,
    };
  }
}
