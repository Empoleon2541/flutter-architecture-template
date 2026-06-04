import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/posts_bloc.dart';
import '../bloc/posts_event.dart';
import '../bloc/posts_state.dart';
import '../widgets/post_card.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  static const path = '/posts';
  static const name = 'posts';

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  @override
  void initState() {
    super.initState();
    // addPostFrameCallback ensures the context is fully attached to the
    // StatefulShellBranch provider tree before reading the BLoC.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PostsBloc>().add(const PostsLoadRequested());
    });
  }

  Future<void> _onRefresh() async {
    context.read<PostsBloc>().add(const PostsLoadRequested());
    // Wait for the bloc to finish processing
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<PostsBloc, PostsState>(
      builder: (context, state) {
        if (state is PostsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading posts...'),
              ],
            ),
          );
        }

        if (state is PostsError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to Load Posts',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PostsBloc>().add(const PostsLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PostsLoaded) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.article_outlined,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${state.posts.length} Posts',
                          style: theme.textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Chip(
                          label: const Text('Mock API'),
                          avatar: const Icon(Icons.cloud_off, size: 14),
                          backgroundColor:
                              theme.colorScheme.secondary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = state.posts[index];
                      return PostCard(
                        post: post,
                        onTap: () => context.push('/posts/${post.id}'),
                      );
                    },
                    childCount: state.posts.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        }

        // PostsInitial
        return const Center(
          child: Text('Pull down to load posts'),
        );
      },
    );
  }
}
