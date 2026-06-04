import 'package:dio/dio.dart';

class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final path = options.path;
    final method = options.method.toUpperCase();

    try {
      // Pass `true` so Dio continues through the response interceptor chain
      // after resolving. Without it, RequestsInspectorInterceptor.onResponse
      // is never called and mock requests are invisible to the inspector.
      if (method == 'GET' && path.contains('/auth/me')) {
        handler.resolve(_buildResponse(_mockUser(), options), true);
      } else if (method == 'POST' && path.contains('/auth/login')) {
        handler.resolve(_buildResponse(_mockUser(), options), true);
      } else if (method == 'POST' && path.contains('/auth/logout')) {
        handler.resolve(_buildResponse({'success': true, 'message': 'Logged out'}, options), true);
      } else if (method == 'GET' && RegExp(r'/posts/\d+$').hasMatch(path)) {
        final idStr = path.split('/').last;
        final id = int.tryParse(idStr) ?? 1;
        handler.resolve(_buildResponse(_mockPost(id), options), true);
      } else if (method == 'GET' && path.contains('/posts')) {
        handler.resolve(_buildResponse(_mockPosts(), options), true);
      } else {
        handler.resolve(_buildResponse({'message': 'Not found'}, options), true);
      }
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          message: 'Mock interceptor error: $e',
        ),
      );
    }
  }

  Response _buildResponse(dynamic data, RequestOptions options) {
    return Response(
      requestOptions: options,
      data: data,
      statusCode: 200,
      statusMessage: 'OK',
    );
  }

  Map<String, dynamic> _mockUser() {
    return {
      'id': 'usr_001',
      'name': 'Alex Johnson',
      'email': 'demo@example.com',
      'token': 'mock_jwt_token_eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
      'avatar': 'https://i.pravatar.cc/150?img=12',
    };
  }

  List<Map<String, dynamic>> _mockPosts() {
    return List.generate(10, (index) => _mockPost(index + 1));
  }

  Map<String, dynamic> _mockPost(int id) {
    final posts = [
      {
        'id': 1,
        'userId': 1,
        'title': 'Getting Started with Flutter Clean Architecture',
        'body':
            'Clean Architecture separates your app into layers: data, domain, and presentation. Each layer has a specific responsibility. The domain layer contains business logic and is framework-agnostic. The data layer handles all data operations. The presentation layer manages UI state.',
      },
      {
        'id': 2,
        'userId': 1,
        'title': 'BLoC Pattern: State Management Done Right',
        'body':
            'BLoC (Business Logic Component) separates business logic from UI. Events flow in, states flow out. This makes your code testable and predictable. BLoC uses streams under the hood, making it reactive by nature.',
      },
      {
        'id': 3,
        'userId': 2,
        'title': 'Dependency Injection with GetIt in Flutter',
        'body':
            'GetIt is a simple service locator that acts as a dependency injection container. Register your dependencies once, then access them anywhere. It supports factories, singletons, and lazy singletons.',
      },
      {
        'id': 4,
        'userId': 2,
        'title': 'Caching Strategies with Hive',
        'body':
            'Hive is a lightweight, blazing-fast key-value database for Flutter. It is pure Dart, so it works on all platforms without native dependencies. Use it to cache API responses and reduce network calls.',
      },
      {
        'id': 5,
        'userId': 3,
        'title': 'Error Handling with dartz Either',
        'body':
            'The Either type from dartz represents a value of one of two possible types. Left typically represents failure, Right represents success. This eliminates null checks and makes error handling explicit.',
      },
      {
        'id': 6,
        'userId': 3,
        'title': 'Real-Time Features with WebSockets in Flutter',
        'body':
            'WebSockets provide full-duplex communication over a single TCP connection. In Flutter, you can use the web_socket_channel package or simulate real-time events with StreamControllers for testing.',
      },
      {
        'id': 7,
        'userId': 4,
        'title': 'Navigation with GoRouter',
        'body':
            'GoRouter is the official routing package for Flutter. It supports deep linking, redirects, and nested navigation. It uses a declarative API that integrates well with the widget tree.',
      },
      {
        'id': 8,
        'userId': 4,
        'title': 'Feature Modularization Best Practices',
        'body':
            'Organizing your Flutter app by features (auth, posts, settings) rather than by layer (models, views, controllers) improves maintainability. Each feature folder contains its own data, domain, and presentation layers.',
      },
      {
        'id': 9,
        'userId': 5,
        'title': 'Testing BLoC with flutter_test',
        'body':
            'Testing BLoC components is straightforward. Use bloc_test package to verify state transitions. Mock your repositories and inject them into the BLoC under test. Write tests for each event and its expected states.',
      },
      {
        'id': 10,
        'userId': 5,
        'title': 'Offline-First Architecture Patterns',
        'body':
            'An offline-first app works without internet connectivity. Cache data locally on first load. Show cached data when offline. Sync when connection is restored. This pattern significantly improves user experience.',
      },
    ];

    final index = (id - 1) % posts.length;
    final post = Map<String, dynamic>.from(posts[index]);
    post['id'] = id;
    return post;
  }
}
