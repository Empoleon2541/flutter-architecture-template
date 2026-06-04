import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'app/common/di/injection_container.dart';
import 'app/common/network/inspector/app_requests_inspector.dart';
import 'app/common/routes/app_router.dart';
import 'app/common/utils/app_theme.dart';
import 'app/features/auth/presentation/bloc/auth_bloc.dart';
import 'app/features/auth/presentation/bloc/auth_event.dart';
import 'app/features/posts/presentation/bloc/posts_bloc.dart';
import 'app/features/realtime/presentation/bloc/realtime_bloc.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final AuthBloc _authBloc;
  late final PostsBloc _postsBloc;
  late final RealtimeBloc _realtimeBloc;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authBloc = sl<AuthBloc>()..add(const AuthCheckStatusRequested());
    _postsBloc = sl<PostsBloc>();
    _realtimeBloc = sl<RealtimeBloc>();

    // Router is created once — calling createRouter in build() would reset
    // navigation state on every App rebuild (e.g. on auth state changes).
    _router = AppRouter.createRouter(
      authBloc: _authBloc,
      postsBloc: _postsBloc,
      realtimeBloc: _realtimeBloc,
    );
  }

  @override
  void dispose() {
    _authBloc.close();
    _postsBloc.close();
    _realtimeBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Only AuthBloc is provided here — it is needed by route guards which run
    // before any shell or page widget is built. PostsBloc and RealtimeBloc are
    // provided inside the StatefulShellRoute builder in AppRouter so they are
    // accessible from within the branch navigators.
    return AppRequestsInspector(
      child: BlocProvider<AuthBloc>.value(
        value: _authBloc,
        child: MaterialApp.router(
          title: 'Architecture Starter Kit',
          theme: AppTheme.lightTheme,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
