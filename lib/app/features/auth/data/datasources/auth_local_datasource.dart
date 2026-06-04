import 'dart:convert';
import '../../../../common/cache/cache_manager.dart';
import '../../../../common/error/exceptions.dart';
import '../../../../common/utils/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel> getCachedUser();
  Future<void> clearUser();
  bool hasUser();
}

class HiveAuthLocalDataSource implements AuthLocalDataSource {
  final CacheManager cacheManager;

  HiveAuthLocalDataSource({required this.cacheManager});

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await cacheManager.put(AppConstants.cachedUserKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to cache user: $e');
    }
  }

  @override
  Future<UserModel> getCachedUser() async {
    try {
      final jsonString = cacheManager.get(AppConstants.cachedUserKey);
      if (jsonString == null) {
        throw const CacheException(message: 'No cached user found');
      }
      final jsonMap = jsonDecode(jsonString as String) as Map<String, dynamic>;
      return UserModel.fromJson(jsonMap);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to retrieve cached user: $e');
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      await cacheManager.delete(AppConstants.cachedUserKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear cached user: $e');
    }
  }

  @override
  bool hasUser() {
    return cacheManager.containsKey(AppConstants.cachedUserKey);
  }
}
