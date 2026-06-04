import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../common/error/failures.dart';
import '../../../../common/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPostDetailUseCase implements UseCase<Post, PostDetailParams> {
  final PostsRepository repository;

  GetPostDetailUseCase(this.repository);

  @override
  Future<Either<Failure, Post>> call(PostDetailParams params) async {
    return await repository.getPostDetail(params.id);
  }
}

class PostDetailParams extends Equatable {
  final int id;

  const PostDetailParams({required this.id});

  @override
  List<Object> get props => [id];
}
