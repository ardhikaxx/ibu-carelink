import 'package:equatable/equatable.dart';
import '../../../../core/utils/date_helper.dart';

class ChildEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String gender; // 'Laki-laki' atau 'Perempuan'
  final DateTime dateOfBirth;
  final double birthWeightKg;
  final double birthLengthCm;
  final int childOrder;

  const ChildEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.birthWeightKg,
    required this.birthLengthCm,
    this.childOrder = 1,
  });

  int get ageInMonths => DateHelper.calculateAgeInMonths(dateOfBirth);
  String get formattedAge => DateHelper.formatAgeText(dateOfBirth);

  @override
  List<Object?> get props => [id, userId, name, gender, dateOfBirth, birthWeightKg, birthLengthCm, childOrder];
}
