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

  /// Metafora analogi buah 3D untuk ukuran janin berdasarkan usia minggu
  String get fetalSizeFruitAnalogy {
    final w = gestationalWeeks;
    if (w <= 4) return 'Biji Poppy (0.1 cm)';
    if (w <= 8) return 'Buah Rasberi (1.6 cm)';
    if (w <= 12) return 'Buah Jeruk Nipis (5.4 cm)';
    if (w <= 16) return 'Buah Alpukat (11.6 cm)';
    if (w <= 20) return 'Buah Pisang (25.6 cm)';
    if (w <= 24) return 'Buah Jagung (30.0 cm)';
    if (w <= 28) return 'Buah Terong Besar (37.6 cm)';
    if (w <= 32) return 'Buah Kelapa (42.4 cm)';
    if (w <= 36) return 'Buah Pepaya (47.4 cm)';
    return 'Buah Semangka (51.2 cm)';
  }

  @override
  List<Object?> get props => [id, userId, hpht, estimatedDueDate, prePregnancyWeight, isActive];
}
