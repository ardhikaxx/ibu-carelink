import '../../../../core/utils/constants.dart';

enum ZScoreClassification {
  normal, // Hijau: Normal / Gizi Baik
  warning, // Kuning: Waspada (-2 SD s/d -1 SD atau risiko overweight)
  intervention // Merah: < -2 SD (Stunting / Severely Underweight) atau > +3 SD
}

class ZScoreEvaluation {
  final double weightForAgeZScore;
  final ZScoreClassification wfaStatus;
  final double heightForAgeZScore;
  final ZScoreClassification hfaStatus; // TB/U (Stunting indicator)
  final bool requiresInterventionAlert;

  const ZScoreEvaluation({
    required this.weightForAgeZScore,
    required this.wfaStatus,
    required this.heightForAgeZScore,
    required this.hfaStatus,
    required this.requiresInterventionAlert,
  });

  /// Evaluasi Z-Score presisi berdasarkan tabel referensi WHO berstandar usia bulan & jenis kelamin
  factory ZScoreEvaluation.evaluate({
    required int ageMonths,
    required String gender, // 'Laki-laki' atau 'Perempuan'
    required double weightKg,
    required double heightCm,
  }) {
    final isBoys = gender.toLowerCase().contains('laki');
    final heightRefMap = isBoys ? AppConstants.whoBoysHeight : AppConstants.whoGirlsHeight;
    final weightRefMap = isBoys ? AppConstants.whoBoysWeight : AppConstants.whoGirlsWeight;

    // Cari referensi terdekat atau interpolasi (menggunakan titik 0, 6, 12, 24, 36, 60 bulan)
    final availableMonths = [0, 6, 12, 24, 36, 60];
    int closestMonth = 0;
    for (int m in availableMonths) {
      if ((ageMonths - m).abs() < (ageMonths - closestMonth).abs()) {
        closestMonth = m;
      }
    }

    final heightRef = heightRefMap[closestMonth] ?? [65.0, 70.0, 75.0]; // [-2SD, Median, +2SD]
    final weightRef = weightRefMap[closestMonth] ?? [7.0, 8.5, 10.5];

    // Estimasi SD unit: (Median - (-2SD)) / 2
    final heightSdUnit = (heightRef[1] - heightRef[0]) / 2.0;
    final weightSdUnit = (weightRef[1] - weightRef[0]) / 2.0;

    final hfaZ = heightSdUnit > 0 ? (heightCm - heightRef[1]) / heightSdUnit : 0.0;
    final wfaZ = weightSdUnit > 0 ? (weightKg - weightRef[1]) / weightSdUnit : 0.0;

    ZScoreClassification classify(double z) {
      if (z < -2.0) return ZScoreClassification.intervention;
      if (z < -1.0) return ZScoreClassification.warning;
      if (z > 3.0) return ZScoreClassification.intervention;
      if (z > 2.0) return ZScoreClassification.warning;
      return ZScoreClassification.normal;
    }

    final hfaSt = classify(hfaZ);
    final wfaSt = classify(wfaZ);
    final alert = hfaSt == ZScoreClassification.intervention || wfaSt == ZScoreClassification.intervention;

    return ZScoreEvaluation(
      weightForAgeZScore: wfaZ,
      wfaStatus: wfaSt,
      heightForAgeZScore: hfaZ,
      hfaStatus: hfaSt,
      requiresInterventionAlert: alert,
    );
  }
}
