import 'package:equatable/equatable.dart';

class MilestoneEntity extends Equatable {
  final String id;
  final String childId;
  final String title;
  final String domain; // 'Motorik Kasar', 'Motorik Halus', 'Bicara & Bahasa', 'Sosialisasi'
  final String targetAgeBand; // '0-3 bln', '4-6 bln', '7-9 bln', '10-12 bln', '13-18 bln', '19-24 bln'
  final int maxMonthBand; // e.g. 3, 6, 9, 12, 18, 24
  final bool isAchieved;
  final DateTime? achievedDate;
  final String notes;

  const MilestoneEntity({
    required this.id,
    required this.childId,
    required this.title,
    required this.domain,
    required this.targetAgeBand,
    required this.maxMonthBand,
    required this.isAchieved,
    this.achievedDate,
    this.notes = '',
  });

  bool isRedFlagWarning(int currentChildAgeMonths) {
    if (isAchieved) return false;
    return currentChildAgeMonths > maxMonthBand + 1; // Terlewat batas usia band tanpa ketercapaian
  }

  @override
  List<Object?> get props => [id, childId, title, domain, targetAgeBand, maxMonthBand, isAchieved, achievedDate, notes];
}
