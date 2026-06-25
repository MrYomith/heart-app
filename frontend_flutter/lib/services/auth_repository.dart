import 'package:dio/dio.dart';

import '../models/auth_user.dart';
import 'api_client.dart';

/// Friendly error carrying the backend's message (the `detail` field).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

String _extractError(Response? res, Object fallbackErr) {
  if (res?.data is Map && (res!.data as Map)['detail'] != null) {
    return (res.data as Map)['detail'].toString();
  }
  return 'Could not reach the server. Check your connection and try again.';
}

class AuthRepository {
  final Dio _dio = ApiClient.instance.dio;

  Future<AuthUser> register({
    required String name,
    required String email,
    required String password,
    required bool consentAccepted,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'consent_accepted': consentAccepted,
      });
      if (res.statusCode == 201) {
        await TokenStore.save(res.data['access_token'] as String);
        return AuthUser.fromJson(res.data['user'] as Map<String, dynamic>);
      }
      throw ApiException(_extractError(res, ''));
    } on DioException catch (e) {
      throw ApiException(_extractError(e.response, e));
    }
  }

  Future<AuthUser> login({required String email, required String password}) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      if (res.statusCode == 200) {
        await TokenStore.save(res.data['access_token'] as String);
        return AuthUser.fromJson(res.data['user'] as Map<String, dynamic>);
      }
      throw ApiException(_extractError(res, ''));
    } on DioException catch (e) {
      throw ApiException(_extractError(e.response, e));
    }
  }

  /// Used on app start: if a stored token is still valid, return the user.
  Future<AuthUser?> currentUser() async {
    final token = await TokenStore.read();
    if (token == null || token.isEmpty) return null;
    try {
      final res = await _dio.get('/auth/me');
      if (res.statusCode == 200) {
        return AuthUser.fromJson(res.data as Map<String, dynamic>);
      }
      await TokenStore.clear();
      return null;
    } on DioException {
      return null; // offline: stay logged out gracefully
    }
  }

  Future<void> logout() => TokenStore.clear();
}
