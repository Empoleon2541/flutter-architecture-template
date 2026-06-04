import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../features/auth/presentation/bloc/auth_state.dart';
import '../route_names.dart';

abstract class RouteGuard {
  const RouteGuard();

  /// Returns a redirect path if the guard blocks navigation, null to allow.
  String? redirect(BuildContext context, GoRouterState state);
}

/// Chains multiple guards — first one that blocks wins.
class Guards {
  final List<RouteGuard> _guards;

  const Guards(this._guards);

  String? redirect(BuildContext context, GoRouterState state) {
    for (final guard in _guards) {
      final result = guard.redirect(context, state);
      if (result != null) return result;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// Built-in guards
// ---------------------------------------------------------------------------

/// Blocks unauthenticated users — redirects to login.
class AuthGuard extends RouteGuard {
  const AuthGuard();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) return null;
    return RouteNames.login;
  }
}

/// Blocks authenticated users — redirects to home (prevents back-to-login).
class GuestGuard extends RouteGuard {
  const GuestGuard();

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return RouteNames.posts;
  }
}
