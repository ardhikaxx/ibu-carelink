import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/milestone_model.dart';

abstract class MilestoneLocalDataSource {
  Future<void> cacheMilestones(String childId, List<MilestoneModel> list);
  Future<List<MilestoneModel>> getCachedMilestones(String childId);
}

class MilestoneLocalDataSourceImpl implements MilestoneLocalDataSource {
  final SharedPreferences sharedPreferences;
  MilestoneLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheMilestones(String childId, List<MilestoneModel> list) async {
    try {
      final jsonList = list.map((m) => m.toJson()).toList();
      await sharedPreferences.setString('MILESTONES_$childId', json.encode(jsonList));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<MilestoneModel>> getCachedMilestones(String childId) async {
    final str = sharedPreferences.getString('MILESTONES_$childId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((item) => MilestoneModel.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
