# Flutter Architecture Starter Kit

A production-ready Flutter starter kit demonstrating **Clean Architecture**, **BLoC state management**, **modular feature structure**, **mock APIs**, and a **real-time WebSocket simulation**.

---

## Tech Stack

| Concern | Package |
|---|---|
| State management | `flutter_bloc` + `bloc` |
| Dependency injection | `get_it` |
| Navigation | `go_router` |
| Networking | `dio` (mock interceptor — no real HTTP) |
| Local cache | `hive` + `hive_flutter` |
| Functional error handling | `dartz` |
| Equality | `equatable` |
| Connectivity | `connectivity_plus` |
| Network inspector | `requests_inspector` |

---

## Project Structure

```
lib/
├── main.dart                          # Hive init + DI setup + runApp
├── app.dart                           # BlocProvider + MaterialApp.router
│
└── app/
    ├── common/                        # Shared infrastructure
    │   ├── cache/
    │   │   └── cache_manager.dart         # Hive box wrapper
    │   ├── di/
    │   │   └── injection_container.dart   # GetIt registrations
    │   ├── error/
    │   │   ├── exceptions.dart            # ServerException, CacheException, NetworkException
    │   │   └── failures.dart              # Failure sealed hierarchy (dartz)
    │   ├── extension/
    │   │   └── string_extension.dart
    │   ├── network/
    │   │   ├── api_client.dart            # Dio wrapper
    │   │   ├── mock_interceptor.dart      # Intercepts requests, returns hardcoded JSON
    │   │   ├── network_info.dart          # Connectivity check
    │   │   └── inspector/
    │   │       └── app_requests_inspector.dart  # requests_inspector wrapper (debug only)
    │   ├── routes/
    │   │   ├── app_router.dart            # GoRouter config
    │   │   ├── route_names.dart           # Route name constants
    │   │   ├── guards/
    │   │   │   └── route_guard.dart       # AuthGuard, GuestGuard, Guards combinator
    │   │   └── shell/
    │   │       └── main_shell.dart        # StatefulNavigationShell + BottomNavigationBar
    │   ├── usecases/
    │   │   └── usecase.dart               # Abstract UseCase<Type, Params> + NoParams
    │   └── utils/
    │       ├── app_constants.dart
    │       └── app_theme.dart
    │
    └── features/                      # Feature modules
        ├── auth/                      # Login, logout, session persistence
        ├── posts/                     # Post list + detail, offline cache
        └── realtime/                  # Simulated WebSocket event stream
```

Each feature follows the same three-layer structure:

```
feature/
├── data/
│   ├── datasources/     # Mock remote + Hive local implementations
│   ├── models/          # Extend domain entities; add fromJson/toJson
│   └── repositories/    # Implements domain repository; handles cache fallback
├── domain/
│   ├── entities/        # Pure Dart classes (no Flutter/framework deps)
│   ├── repositories/    # Abstract contracts
│   └── usecases/        # Single-responsibility business operations
└── presentation/
    ├── bloc/            # Event → State via on<Event>() handlers
    ├── pages/           # Screens (hold path/name route constants)
    └── widgets/         # Extracted UI components
```

---

## Routing

Routing lives entirely in `lib/app/common/routes/`.

### AppRouter

```dart
// lib/app/common/routes/app_router.dart
class AppRouter {
  const AppRouter._();

  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get globalContext =>
      rootNavigatorKey.currentState?.overlay?.context;

  static GoRouter createRouter({
    required AuthBloc authBloc,
    required PostsBloc postsBloc,
    required RealtimeBloc realtimeBloc,
  }) => GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: PostsPage.path,
    refreshListenable: _AuthChangeNotifier(authBloc.stream),
    redirect: ...,   // global auth guard
    routes: [...],
  );
}
```

### Route tree

```
/posts            → PostsPage        ┐
/posts/:id        → PostDetailPage   │ StatefulShellRoute.indexedStack
/realtime         → RealtimePage     │ (tab state preserved across switches)
/profile          → ProfilePage      ┘
/login            → LoginPage          (guest only)
```

### Route constants

Every page owns its own `path` and `name` — no magic strings in the router:

```dart
class PostsPage extends StatefulWidget {
  static const path = '/posts';
  static const name = 'posts';
  ...
}
```

Navigate by name to avoid hardcoded path strings:

```dart
context.goNamed(PostsPage.name);
context.goNamed(PostDetailPage.name, pathParameters: {'id': '3'});
```

### Guards

Guards are composable and live in `lib/app/common/routes/guards/route_guard.dart`:

```dart
abstract class RouteGuard {
  String? redirect(BuildContext context, GoRouterState state);
}

// Combine guards — first one that blocks wins
class Guards {
  const Guards(this._guards);
  String? redirect(BuildContext context, GoRouterState state) { ... }
}
```

Available guards:

| Guard | Blocks | Redirects to |
|---|---|---|
| `AuthGuard` | Unauthenticated users | `/login` |
| `GuestGuard` | Already-authenticated users | `/posts` |

Apply per-route:

```dart
GoRoute(
  path: PostsPage.path,
  name: PostsPage.name,
  redirect: const Guards([AuthGuard()]).redirect,
  builder: (context, state) => const PostsPage(),
),
```

### Shell & tab state

`StatefulShellRoute.indexedStack` is used so each tab preserves its own navigation stack. `PostsBloc` and `RealtimeBloc` are provided inside the shell builder — not above `MaterialApp.router` — so they are reachable from within each branch's Navigator context.

### Auth redirect flow

`_AuthChangeNotifier` converts `AuthBloc.stream` into a `ChangeNotifier`. GoRouter's `refreshListenable` watches it and re-evaluates the global `redirect` on every auth state change — no manual `context.go()` needed after login/logout.

```
AuthBloc emits AuthAuthenticated
  → _AuthChangeNotifier.notifyListeners()
    → GoRouter re-evaluates redirect
      → GuestGuard blocks /login → sends to /posts
```

---

## Mock APIs

`MockInterceptor` (a Dio `Interceptor`) intercepts all outgoing requests and resolves them with in-memory data — zero real network calls:

```dart
// app/common/network/mock_interceptor.dart
@override
void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
  if (method == 'POST' && path.contains('/auth/login')) {
    handler.resolve(_buildResponse(_mockUser(), options), true);
  } else if (method == 'GET' && path.contains('/posts')) {
    handler.resolve(_buildResponse(_mockPosts(), options), true);
  }
  ...
}
```

The second argument `true` tells Dio to continue through the response interceptor chain, which allows `RequestsInspectorInterceptor` to capture mock responses.

Simulated latencies are added in the datasource layer (`await Future.delayed(...)`), keeping the interceptor stateless.

---

## Network Inspector

`AppRequestsInspector` wraps the app with `RequestsInspector` from the `requests_inspector` package in debug builds only. Long-press anywhere (or shake on mobile) to open the inspector UI.

```dart
// app/common/network/inspector/app_requests_inspector.dart
class AppRequestsInspector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!AppConstants.enableRequestsInspector) return child;
    return RequestsInspector(
      hideInspectorBanner: true,
      showInspectorOn: ShowInspectorOn.Both,
      child: child,
    );
  }
}
```

Mock WebSocket events are also reported to the inspector via `InspectorController().addNewRequest(...)` so real-time traffic is visible alongside REST calls.

---

## Real-Time Module

`MockWebSocketDataSourceImpl` uses a `StreamController.broadcast()` and a `Timer.periodic` to emit events every 3 seconds — no actual WebSocket server required:

```dart
void connect() {
  _controller = StreamController<RealtimeEventModel>.broadcast();
  _timer = Timer.periodic(const Duration(seconds: 3), (_) => _emitEvent());
}
```

Event types rotate through: `notification`, `price_update`, `chat_message`.

`RealtimeBloc` holds a running list of the last 50 events and cancels its `StreamSubscription` in `close()` to prevent leaks.

---

## Caching

Repository implementations follow a **remote-first, cache-fallback** strategy:

```dart
final result = await remoteDataSource.getPosts();
// success → write to cache, return data
// NetworkFailure → read from cache, return cached data
```

Hive stores complex objects as JSON strings (no TypeAdapter needed). Cache keys are centralised in `AppConstants`.

---

## Dependency Injection

All dependencies are registered in `lib/app/common/di/injection_container.dart` with `get_it`:

| Type | Registration |
|---|---|
| Infrastructure (cache, network) | `registerSingleton` / `registerLazySingleton` |
| Repositories & use cases | `registerLazySingleton` |
| BLoCs | `registerFactory` (fresh instance per creation) |

---

## Getting Started

```bash
# If using FVM
fvm use 3.x.x

# Install dependencies
flutter pub get

# Run
flutter run
```

**Demo credentials** — any email / any password (mock auth accepts everything):

```
Email:    demo@example.com
Password: password123
```

---

## Adding a New Feature

1. Create `lib/app/features/<name>/` with `data/`, `domain/`, `presentation/` sub-folders.
2. Define your entity in `domain/entities/`.
3. Define the repository contract in `domain/repositories/`.
4. Implement use cases in `domain/usecases/`.
5. Add a mock datasource in `data/datasources/`.
6. Implement the repository in `data/repositories/`.
7. Create BLoC events, states, and bloc in `presentation/bloc/`.
8. Add `static const path` and `name` to your page widget.
9. Register all new classes in `lib/app/common/di/injection_container.dart`.
10. Add a `GoRoute` with guards to `AppRouter`.
