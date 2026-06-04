import 'package:dartz/dartz.dart';
import '../../../../common/error/failures.dart';
import '../entities/post.dart';

abstract class PostsRepository {
  Future<Either<Failure, List<Post>>> getPosts();
  Future<Either<Failure, Post>> getPostDetail(int id);
}
