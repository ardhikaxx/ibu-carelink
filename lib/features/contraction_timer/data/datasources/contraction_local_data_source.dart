import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/contraction_model.dart';

abstract class ContractionLocalDataSource {
  Future<void> cacheContractions(String pregnancyId, List<ContractionModel> contractions);
  Future<List<ContractionModel>> getCachedContractions(String pregnancyId);
}

class ContractionLocalDataSourceImpl implements ContractionLocalDataSource {
  final SharedPreferences sharedPreferences;
  ContractionLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheContractions(String pregnancyId, List<ContractionModel> contractions) async {
    try {
      final list = contractions.map((c) => c.toJson()).toList();
      await sharedPreferences.setString('CONTRACTIONS_$pregnancyId', json.encode(list));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<ContractionModel>> getCachedContractions(String pregnancyId) async {
    final str = sharedPreferences.getString('CONTRACTIONS_$pregnancyId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => ContractionModel.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
