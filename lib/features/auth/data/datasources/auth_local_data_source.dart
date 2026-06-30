import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _cachedUserKey = 'CACHED_USER_PROFILE';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode({
        'uid': user.uid,
        'email': user.email,
        'name': user.name,
        'role': user.role,
        'createdAt': user.createdAt?.toIso8601String(),
      });
      await sharedPreferences.setString(_cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException('Gagal menyimpan cache pengguna lokal');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = sharedPreferences.getString(_cachedUserKey);
    if (jsonString != null) {
      try {
        final map = json.decode(jsonString);
        return UserModel(
          uid: map['uid'],
          email: map['email'],
          name: map['name'],
          role: map['role'] ?? 'pending',
          createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_cachedUserKey);
  }
}
