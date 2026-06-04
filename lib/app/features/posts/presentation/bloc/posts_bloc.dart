import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/usecases/usecase.dart';
import '../../domain/usecases/get_post_detail_usecase.dart';
import '../../domain/usecases/get_posts_usecase.dart';
import 'posts_event.dart';
import 'posts_state.dart';

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  final GetPostsUseCase getPostsUseCase;
  final GetPostDetailUseCase getPostDetailUseCase;

  PostsBloc({
    required this.getPostsUseCase,
    required this.getPostDetailUseCase,
  }) : super(const PostsInitial()) {
    on<PostsLoadRequested>(_onPostsLoadRequested);
    on<PostDetailLoadRequested>(_onPostDetailLoadRequested);
  }

  Future<void> _onPostsLoadRequested(
    PostsLoadRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final result = await getPostsUseCase(NoParams());

    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (posts) => emit(PostsLoaded(posts)),
    );
  }

  Future<void> _onPostDetailLoadRequested(
    PostDetailLoadRequested event,
    Emitter<PostsState> emit,
  ) async {
    emit(const PostsLoading());

    final result = await getPostDetailUseCase(PostDetailParams(id: event.id));

    result.fold(
      (failure) => emit(PostsError(failure.message)),
      (post) => emit(PostDetailLoaded(post)),
    );
  }
}
