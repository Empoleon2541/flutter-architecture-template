import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import '../cache/cache_manager.dart';
import '../network/api_client.dart';
import 'package:requests_inspector/requests_inspector.dart';
import '../network/mock_interceptor.dart';
import '../network/network_info.dart';
import '../utils/app_constants.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/posts/data/datasources/posts_local_datasource.dart';
import '../../features/posts/data/datasources/posts_remote_datasource.dart';
import '../../features/posts/data/repositories/posts_repository_impl.dart';
import '../../features/posts/domain/repositories/posts_repository.dart';
import '../../features/posts/domain/usecases/get_post_detail_usecase.dart';
import '../../features/posts/domain/usecases/get_posts_usecase.dart';
import '../../features/posts/presentation/bloc/posts_bloc.dart';
import '../../features/realtime/data/datasources/mock_websocket_datasource.dart';
import '../../features/realtime/data/repositories/realtime_repository_impl.dart';
import '../../features/realtime/domain/repositories/realtime_repository.dart';
import '../../features/realtime/domain/usecases/subscribe_to_events_usecase.dart';
import '../../features/realtime/presentation/bloc/realtime_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // ========== Core ==========

  // Cache Manager
  final cacheManager = HiveCacheManager();
  await cacheManager.init();
  sl.registerSingleton<CacheManager>(cacheManager);

  // Network Info
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Mock Interceptor
  sl.registerLazySingleton<MockInterceptor>(() => MockInterceptor());

  // API Client — RequestsInspectorInterceptor is only added in debug builds
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(interceptors: [
      if (AppConstants.enableRequestsInspector) RequestsInspectorInterceptor(),
      sl<MockInterceptor>(),
    ]),
  );

  // ========== Auth Feature ==========

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => MockAuthRemoteDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => HiveAuthLocalDataSource(cacheManager: sl<CacheManager>()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => GetCurrentUserUseCase(sl<AuthRepository>()),
  );

  // BLoC (factory — new instance per creation)
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
    ),
  );

  // ========== Posts Feature ==========

  // Data Sources
  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => MockPostsRemoteDataSource(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<PostsLocalDataSource>(
    () => HivePostsLocalDataSource(cacheManager: sl<CacheManager>()),
  );

  // Repository
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(
      remoteDataSource: sl<PostsRemoteDataSource>(),
      localDataSource: sl<PostsLocalDataSource>(),
      networkInfo: sl<NetworkInfo>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetPostsUseCase(sl<PostsRepository>()));
  sl.registerLazySingleton(
    () => GetPostDetailUseCase(sl<PostsRepository>()),
  );

  // BLoC
  sl.registerFactory<PostsBloc>(
    () => PostsBloc(
      getPostsUseCase: sl<GetPostsUseCase>(),
      getPostDetailUseCase: sl<GetPostDetailUseCase>(),
    ),
  );

  // ========== Realtime Feature ==========

  // Data Source (singleton — maintains stream state)
  sl.registerLazySingleton<MockWebSocketDataSource>(
    () => MockWebSocketDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<RealtimeRepository>(
    () => RealtimeRepositoryImpl(dataSource: sl<MockWebSocketDataSource>()),
  );

  // Use Case
  sl.registerLazySingleton(
    () => SubscribeToEventsUseCase(sl<RealtimeRepository>()),
  );

  // BLoC
  sl.registerFactory<RealtimeBloc>(
    () => RealtimeBloc(
      subscribeToEventsUseCase: sl<SubscribeToEventsUseCase>(),
    ),
  );
}
