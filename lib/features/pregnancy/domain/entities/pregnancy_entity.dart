import 'package:equatable/equatable.dart';
import '../../../../core/utils/date_helper.dart';

class PregnancyEntity extends Equatable {
  final String id;
  final String userId;
  final DateTime hpht;
  final DateTime estimatedDueDate;
  final double prePregnancyWeight;
  final bool isActive;

  const PregnancyEntity({
    required this.id,
    required this.userId,
    required this.hpht,
    required this.estimatedDueDate,
    required this.prePregnancyWeight,
    this.isActive = true,
  });

  int get gestationalWeeks => DateHelper.calculateGestationalWeeks(hpht);
  int get trimester => DateHelper.calculateTrimester(gestationalWeeks);

  /// Metafora analogi buah 3D untuk ukuran janin berdasarkan usia minggu (12 Tahapan Anatomi)
  String get fetalSizeFruitAnalogy {
    final w = gestationalWeeks;
    if (w <= 3) return 'Biji Selasih / Zigot (~0.1 cm)';
    if (w == 4) return 'Biji Poppy / Blastosis (~0.2 cm)';
    if (w == 5) return 'Biji Wijen / Embrio C (~0.3 cm)';
    if (w == 6) return 'Kacang Hijau / Tunas (~0.6 cm)';
    if (w == 7) return 'Buah Blueberry (~1.3 cm)';
    if (w <= 10) return 'Buah Stroberi (~2.5 cm)';
    if (w <= 13) return 'Jeruk Nipis (~6.0 cm)';
    if (w <= 18) return 'Buah Alpukat (~14.0 cm)';
    if (w <= 22) return 'Buah Pisang (~26.0 cm)';
    if (w <= 29) return 'Buah Jagung (~36.0 cm)';
    if (w <= 35) return 'Buah Nanas (~45.0 cm)';
    return 'Buah Semangka (~50.5 cm)';
  }

  @override
  List<Object?> get props => [id, userId, hpht, estimatedDueDate, prePregnancyWeight, isActive];
}
