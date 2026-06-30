import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/child_model.dart';
import '../models/growth_log_model.dart';

abstract class ChildLocalDataSource {
  Future<void> cacheChildren(String userId, List<ChildModel> children);
  Future<List<ChildModel>> getCachedChildren(String userId);
  Future<void> cacheGrowthLogs(String childId, List<GrowthLogModel> logs);
  Future<List<GrowthLogModel>> getCachedGrowthLogs(String childId);
}

class ChildLocalDataSourceImpl implements ChildLocalDataSource {
  final SharedPreferences sharedPreferences;
  ChildLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheChildren(String userId, List<ChildModel> children) async {
    try {
      final list = children.map((c) => c.toJson()).toList();
      await sharedPreferences.setString('CHILDREN_$userId', json.encode(list));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ChildModel>> getCachedChildren(String userId) async {
    final str = sharedPreferences.getString('CHILDREN_$userId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => ChildModel.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  @override
  Future<void> cacheGrowthLogs(String childId, List<GrowthLogModel> logs) async {
    try {
      final list = logs.map((l) => l.toJson()).toList();
      await sharedPreferences.setString('GROWTH_LOGS_$childId', json.encode(list));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<GrowthLogModel>> getCachedGrowthLogs(String childId) async {
    final str = sharedPreferences.getString('GROWTH_LOGS_$childId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => GrowthLogModel.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
