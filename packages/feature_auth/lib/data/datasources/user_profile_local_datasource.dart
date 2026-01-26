import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile_dto.dart';

/// Custom exception for cache operations
class CacheException implements Exception {
  final String message;
  CacheException(this.message);
}

/// Local data source for user profile (caching)
abstract class UserProfileLocalDataSource {
  Future<UserProfileDTO?> getCachedProfile(String userId);
  Future<void> cacheProfile(String userId, UserProfileDTO profile);
  Future<void> clearProfile(String userId);
}

class UserProfileLocalDataSourceImpl implements UserProfileLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _profileKeyPrefix = 'USER_PROFILE_';
  static const String _timestampKeyPrefix = 'USER_PROFILE_TIMESTAMP_';
  static const Duration _cacheExpiration = Duration(minutes: 5);

  UserProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserProfileDTO?> getCachedProfile(String userId) async {
    try {
      final key = _profileKeyPrefix + userId;
      final timestampKey = _timestampKeyPrefix + userId;

      // Check if cache exists
      final jsonString = sharedPreferences.getString(key);
      if (jsonString == null) return null;

      // Check if cache is expired
      final timestamp = sharedPreferences.getInt(timestampKey);
      if (timestamp != null) {
        final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();

        if (now.difference(cacheTime) > _cacheExpiration) {
          // Cache expired, remove it
          await clearProfile(userId);
          return null;
        }
      }

      // Parse cached profile
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserProfileDTO.fromJson(json);
    } catch (e) {
      throw CacheException('Failed to get cached profile: $e');
    }
  }

  @override
  Future<void> cacheProfile(String userId, UserProfileDTO profile) async {
    try {
      final key = _profileKeyPrefix + userId;
      final timestampKey = _timestampKeyPrefix + userId;

      // Save profile
      final jsonString = jsonEncode(profile.toJson());
      await sharedPreferences.setString(key, jsonString);

      // Save timestamp
      await sharedPreferences.setInt(
        timestampKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      throw CacheException('Failed to cache profile: $e');
    }
  }

  @override
  Future<void> clearProfile(String userId) async {
    try {
      final key = _profileKeyPrefix + userId;
      final timestampKey = _timestampKeyPrefix + userId;

      await sharedPreferences.remove(key);
      await sharedPreferences.remove(timestampKey);
    } catch (e) {
      throw CacheException('Failed to clear profile: $e');
    }
  }
}
