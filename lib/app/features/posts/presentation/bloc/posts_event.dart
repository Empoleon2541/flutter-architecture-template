import 'package:equatable/equatable.dart';

abstract class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object> get props => [];
}

class PostsLoadRequested extends PostsEvent {
  const PostsLoadRequested();
}

class PostDetailLoadRequested extends PostsEvent {
  final int id;

  const PostDetailLoadRequested({required this.id});

  @override
  List<Object> get props => [id];
}
