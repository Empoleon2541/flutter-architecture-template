import 'package:dartz/dartz.dart';
import '../../../../common/error/exceptions.dart';
import '../../../../common/error/failures.dart';
import '../../../../common/network/network_info.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/posts_local_datasource.dart';
import '../datasources/posts_remote_datasource.dart';
import '../models/post_model.dart';

class PostsRepositoryImpl implements PostsRepository {
  final PostsRemoteDataSource remoteDataSource;
  final PostsLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  PostsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Post>>> getPosts() async {
    final isOnline = await networkInfo.isConnected;

    if (isOnline) {
      try {
        final posts = await remoteDataSource.getPosts();
        // Cache posts after successful fetch
        await localDataSource.cachePosts(posts);
        return Right(posts);
      } on ServerException catch (e) {
        // Try cache fallback on server error
        return _getCachedPostsOrFailure(e.message);
      } catch (e) {
        return _getCachedPostsOrFailure('Unexpected error: $e');
      }
    } else {
      return _getCachedPostsOrFailure('No internet connection');
    }
  }

  Future<Either<Failure, List<Post>>> _getCachedPostsOrFailure(
    String errorMessage,
  ) async {
    if (localDataSource.hasCachedPosts()) {
      try {
        final cachedPosts = await localDataSource.getCachedPosts();
        return Right(cachedPosts);
      } on CacheException catch (e) {
        return Left(CacheFailure(e.message));
      }
    }
    return Left(NetworkFailure(errorMessage));
  }

  @override
  Future<Either<Failure, Post>> getPostDetail(int id) async {
    try {
      final post = await remoteDataSource.getPostDetail(id);
      return Right(post);
    } on ServerException catch (e) {
      // Try to get from cached posts list
      if (localDataSource.hasCachedPosts()) {
        try {
          final cachedPosts = await localDataSource.getCachedPosts();
          final cachedPost = cachedPosts.where((p) => p.id == id).firstOrNull;
          if (cachedPost != null) {
            return Right(cachedPost);
          }
        } catch (_) {}
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to load post detail: $e'));
    }
  }
}
