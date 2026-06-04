import 'package:hive_flutter/hive_flutter.dart';
import '../error/exceptions.dart';
import '../utils/app_constants.dart';

abstract class CacheManager {
  Future<void> put(String key, dynamic value);
  dynamic get(String key);
  Future<void> delete(String key);
  Future<void> clear();
  bool containsKey(String key);
}

class HiveCacheManager implements CacheManager {
  Box? _box;

  Future<void> init() async {
    _box = await Hive.openBox(AppConstants.appCacheBox);
  }

  Box get _openBox {
    if (_box == null || !_box!.isOpen) {
      throw const CacheException(message: 'Cache box is not open');
    }
    return _box!;
  }

  @override
  Future<void> put(String key, dynamic value) async {
    try {
      await _openBox.put(key, value);
    } catch (e) {
      throw CacheException(message: 'Failed to write cache: $e');
    }
  }

  @override
  dynamic get(String key) {
    try {
      return _openBox.get(key);
    } catch (e) {
      throw CacheException(message: 'Failed to read cache: $e');
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _openBox.delete(key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete cache key: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _openBox.clear();
    } catch (e) {
      throw CacheException(message: 'Failed to clear cache: $e');
    }
  }

  @override
  bool containsKey(String key) {
    try {
      return _openBox.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}
