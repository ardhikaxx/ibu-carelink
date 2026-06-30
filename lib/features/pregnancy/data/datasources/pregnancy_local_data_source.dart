import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/pregnancy_model.dart';
import '../models/symptom_log_model.dart';

abstract class PregnancyLocalDataSource {
  Future<void> cacheActivePregnancy(PregnancyModel pregnancy);
  Future<PregnancyModel?> getCachedActivePregnancy(String userId);
  Future<void> cacheSymptomLogs(String pregnancyId, List<SymptomLogModel> logs);
  Future<List<SymptomLogModel>> getCachedSymptomLogs(String pregnancyId);
}

class PregnancyLocalDataSourceImpl implements PregnancyLocalDataSource {
  final SharedPreferences sharedPreferences;
  PregnancyLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheActivePregnancy(PregnancyModel pregnancy) async {
    try {
      await sharedPreferences.setString('PREGNANCY_${pregnancy.userId}', json.encode(pregnancy.toJson()));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<PregnancyModel?> getCachedActivePregnancy(String userId) async {
    if (userId.isNotEmpty) {
      final str = sharedPreferences.getString('PREGNANCY_$userId');
      if (str != null) {
        try {
          return PregnancyModel.fromJson(json.decode(str));
        } catch (_) {
          // Abaikan kesalahan parsing dan lanjutkan pencarian prefix
        }
      }
    }
    for (final key in sharedPreferences.getKeys()) {
      if (key.startsWith('PREGNANCY_')) {
        final str = sharedPreferences.getString(key);
        if (str != null) {
          try {
            return PregnancyModel.fromJson(json.decode(str));
          } catch (_) {
            // Abaikan kesalahan parsing pada item korup
          }
        }
      }
    }
    return null;
  }

  @override
  Future<void> cacheSymptomLogs(String pregnancyId, List<SymptomLogModel> logs) async {
    try {
      final listJson = logs.map((l) => l.toJson()).toList();
      await sharedPreferences.setString('SYMPTOMS_$pregnancyId', json.encode(listJson));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<SymptomLogModel>> getCachedSymptomLogs(String pregnancyId) async {
    final str = sharedPreferences.getString('SYMPTOMS_$pregnancyId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((item) => SymptomLogModel.fromJson(item)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
