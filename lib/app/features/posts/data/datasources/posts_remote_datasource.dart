import '../../../../common/error/exceptions.dart';
import '../../../../common/network/api_client.dart';
import '../models/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> getPosts();
  Future<PostModel> getPostDetail(int id);
}

class MockPostsRemoteDataSource implements PostsRemoteDataSource {
  final ApiClient apiClient;

  MockPostsRemoteDataSource({required this.apiClient});

  @override
  Future<List<PostModel>> getPosts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    try {
      final response = await apiClient.get('/posts');
      final data = response.data as List<dynamic>;
      return data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch posts: $e');
    }
  }

  @override
  Future<PostModel> getPostDetail(int id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    try {
      final response = await apiClient.get('/posts/$id');
      final data = response.data as Map<String, dynamic>;
      return PostModel.fromJson(data);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch post detail: $e');
    }
  }
}
