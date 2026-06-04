import '../../../../common/error/exceptions.dart';
import '../../../../common/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<void> logout();
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final ApiClient apiClient;

  MockAuthRemoteDataSource({required this.apiClient});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Validate mock credentials
    if (email.isEmpty || password.isEmpty) {
      throw const AuthException(message: 'Email and password are required');
    }

    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data as Map<String, dynamic>;
      return UserModel.fromJson(data);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      await apiClient.post('/auth/logout');
    } catch (e) {
      throw ServerException(message: 'Logout failed: $e');
    }
  }
}
