import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // Enable the requests inspector in debug/profile builds only.
  // Swap this for an env check or feature flag in a real app.
  static const bool enableRequestsInspector = kDebugMode;

  // Base URL (mock — no real network calls)
  static const String baseUrl = 'https://mock.api.local';

  // Hive box names
  static const String appCacheBox = 'app_cache';
  static const String userBox = 'user_box';
  static const String postsBox = 'posts_box';

  // Cache keys
  static const String cachedUserKey = 'cached_user';
  static const String cachedPostsKey = 'cached_posts';
  static const String authTokenKey = 'auth_token';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  static const Duration sendTimeout = Duration(seconds: 10);

  // Realtime
  static const int maxRealtimeEvents = 50;
  static const Duration realtimeEventInterval = Duration(seconds: 3);

  // Pagination
  static const int defaultPageSize = 10;

  // Mock credentials (for demo login)
  static const String mockEmail = 'demo@example.com';
  static const String mockPassword = 'password123';
}
