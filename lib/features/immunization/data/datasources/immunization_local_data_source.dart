import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/immunization_model.dart';

abstract class ImmunizationLocalDataSource {
  Future<void> cacheImmunizations(String childId, List<ImmunizationModel> list);
  Future<List<ImmunizationModel>> getCachedImmunizations(String childId);
}

class ImmunizationLocalDataSourceImpl implements ImmunizationLocalDataSource {
  final SharedPreferences sharedPreferences;
  ImmunizationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheImmunizations(String childId, List<ImmunizationModel> list) async {
    try {
      final jsonList = list.map((m) => m.toJson()).toList();
      await sharedPreferences.setString('IMMUNIZATION_$childId', json.encode(jsonList));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ImmunizationModel>> getCachedImmunizations(String childId) async {
    final str = sharedPreferences.getString('IMMUNIZATION_$childId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((item) => ImmunizationModel.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
