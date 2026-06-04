import 'dart:convert';
import '../../../../common/cache/cache_manager.dart';
import '../../../../common/error/exceptions.dart';
import '../../../../common/utils/app_constants.dart';
import '../models/post_model.dart';

abstract class PostsLocalDataSource {
  Future<void> cachePosts(List<PostModel> posts);
  Future<List<PostModel>> getCachedPosts();
  bool hasCachedPosts();
}

class HivePostsLocalDataSource implements PostsLocalDataSource {
  final CacheManager cacheManager;

  HivePostsLocalDataSource({required this.cacheManager});

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    try {
      final jsonList = posts.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      await cacheManager.put(AppConstants.cachedPostsKey, jsonString);
    } catch (e) {
      throw CacheException(message: 'Failed to cache posts: $e');
    }
  }

  @override
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final jsonString = cacheManager.get(AppConstants.cachedPostsKey);
      if (jsonString == null) {
        throw const CacheException(message: 'No cached posts found');
      }
      final jsonList = jsonDecode(jsonString as String) as List<dynamic>;
      return jsonList
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to retrieve cached posts: $e');
    }
  }

  @override
  bool hasCachedPosts() {
    return cacheManager.containsKey(AppConstants.cachedPostsKey);
  }
}
