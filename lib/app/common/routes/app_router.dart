import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/posts/presentation/pages/post_detail_page.dart';
import '../../features/posts/presentation/pages/posts_page.dart';
import '../../features/realtime/presentation/bloc/realtime_bloc.dart';
import '../../features/realtime/presentation/pages/realtime_page.dart';
import 'guards/route_guard.dart';
import 'shell/main_shell.dart';

class AppRouter {
  const AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _postsNavKey    = GlobalKey<NavigatorState>();
  static final _realtimeNavKey = GlobalKey<NavigatorState>();
  static final _profileNavKey  = GlobalKey<NavigatorState>();

  /// Access the root navigator context from anywhere in the app.
  static BuildContext? get globalContext =>
      rootNavigatorKey.currentState?.overlay?.context;

  static GoRouter createRouter({
    required AuthBloc authBloc,
    required PostsBloc postsBloc,
    required RealtimeBloc realtimeBloc,
  }) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: PostsPage.path,
      debugLogDiagnostics: true,
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.uri}')),
      ),
      refreshListenable: _AuthChangeNotifier(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoginPage = state.matchedLocation == LoginPage.path;

        if (authState is AuthInitial) return LoginPage.path;
        if (authState is AuthAuthenticated && isLoginPage) return PostsPage.path;
        if (authState is AuthUnauthenticated && !isLoginPage) return LoginPage.path;
        return null;
      },
      routes: [
        // ======================================================================
        // Authenticated shell — StatefulShellRoute preserves tab state.
        // PostsBloc and RealtimeBloc are provided HERE (inside the shell builder)
        // so they are reachable from within each branch's Navigator context.
        // Providing them above MaterialApp.router is not reliable with
        // StatefulShellBranch separate navigator keys.
        // ======================================================================
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) => MultiBlocProvider(
            providers: [
              BlocProvider<PostsBloc>.value(value: postsBloc),
              BlocProvider<RealtimeBloc>.value(value: realtimeBloc),
            ],
            child: MainShell(navigationShell: navigationShell),
          ),
          branches: [
            // Posts tab
            StatefulShellBranch(
              navigatorKey: _postsNavKey,
              routes: [
                GoRoute(
                  path: PostsPage.path,
                  name: PostsPage.name,
                  redirect: const Guards([AuthGuard()]).redirect,
                  builder: (context, state) => const PostsPage(),
                  routes: [
                    GoRoute(
                      path: ':id',
                      name: PostDetailPage.name,
                      builder: (context, state) {
                        final id =
                            int.tryParse(state.pathParameters['id'] ?? '') ?? 1;
                        return PostDetailPage(postId: id);
                      },
                    ),
                  ],
                ),
              ],
            ),

            // Real-Time tab
            StatefulShellBranch(
              navigatorKey: _realtimeNavKey,
              routes: [
                GoRoute(
                  path: RealtimePage.path,
                  name: RealtimePage.name,
                  redirect: const Guards([AuthGuard()]).redirect,
                  builder: (context, state) => const RealtimePage(),
                ),
              ],
            ),

            // Profile tab
            StatefulShellBranch(
              navigatorKey: _profileNavKey,
              routes: [
                GoRoute(
                  path: ProfilePage.path,
                  name: ProfilePage.name,
                  redirect: const Guards([AuthGuard()]).redirect,
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),

        // ======================================================================
        // Guest routes — unauthenticated only
        // ======================================================================
        GoRoute(
          path: LoginPage.path,
          name: LoginPage.name,
          redirect: const Guards([GuestGuard()]).redirect,
          builder: (context, state) => const LoginPage(),
        ),
      ],
    );
  }
}

class _AuthChangeNotifier extends ChangeNotifier {
  late final StreamSubscription<dynamic> _sub;

  _AuthChangeNotifier(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
