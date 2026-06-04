import 'package:dartz/dartz.dart';
import '../../../../common/error/failures.dart';
import '../../../../common/usecases/usecase.dart';
import '../entities/post.dart';
import '../repositories/posts_repository.dart';

class GetPostsUseCase implements UseCase<List<Post>, NoParams> {
  final PostsRepository repository;

  GetPostsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Post>>> call(NoParams params) async {
    return await repository.getPosts();
  }
}
