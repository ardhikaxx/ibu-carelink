import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/kick_session_model.dart';

abstract class KickCounterLocalDataSource {
  Future<void> cacheSessions(String pregnancyId, List<KickSessionModel> sessions);
  Future<List<KickSessionModel>> getCachedSessions(String pregnancyId);
}

class KickCounterLocalDataSourceImpl implements KickCounterLocalDataSource {
  final SharedPreferences sharedPreferences;
  KickCounterLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheSessions(String pregnancyId, List<KickSessionModel> sessions) async {
    try {
      final listJson = sessions.map((s) => s.toJson()).toList();
      await sharedPreferences.setString('KICK_SESSIONS_$pregnancyId', json.encode(listJson));
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<KickSessionModel>> getCachedSessions(String pregnancyId) async {
    final str = sharedPreferences.getString('KICK_SESSIONS_$pregnancyId');
    if (str != null) {
      try {
        final List list = json.decode(str);
        return list.map((e) => KickSessionModel.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
