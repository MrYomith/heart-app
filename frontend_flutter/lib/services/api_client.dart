import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Base URL of the FastAPI backend.
///
/// iOS simulator + macOS + web share the host network, so localhost works.
/// Android emulator maps the host to 10.0.2.2.
/// Live backend (EC2). Release builds (the APK/IPA) talk to this; debug builds
/// use the local dev server. Override at build time with
/// `--dart-define=API_BASE=https://your-host`.
const _prodApi = 'http://ec2-3-86-212-253.compute-1.amazonaws.com';

String _resolveBaseUrl() {
  const override = String.fromEnvironment('API_BASE');
  if (override.isNotEmpty) return override;
  if (kIsWeb) {
    // Release web (Netlify) → same-origin: a Netlify proxy forwards /api & /auth
    // to the EC2 backend server-side, avoiding HTTPS→HTTP mixed-content blocks.
    // Debug web → local dev server.
    return kReleaseMode ? '' : 'http://localhost:8000';
  }
  if (kReleaseMode) return _prodApi; // APK / release → live backend
  if (Platform.isAndroid) return 'http://10.0.2.2:8000'; // Android emulator → host
  return 'http://localhost:8000'; // iOS simulator, macOS
}

const _secureStorage = FlutterSecureStorage();
const _tokenKey = 'mioheart_access_token';

class TokenStore {
  static Future<void> save(String token) =>
      _secureStorage.write(key: _tokenKey, value: token);

  static Future<String?> read() => _secureStorage.read(key: _tokenKey);

  static Future<void> clear() => _secureStorage.delete(key: _tokenKey);
}

/// Singleton Dio configured with the base URL and a token interceptor that
/// attaches the bearer token to every request automatically.
class ApiClient {
  ApiClient._() {
    dio = Dio(
      BaseOptions(
        baseUrl: _resolveBaseUrl(),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
        // Don't throw on 4xx — let callers read the message.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStore.read();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  static final ApiClient instance = ApiClient._();
  late final Dio dio;

  /// Absolute base URL, for building media/file links (e.g. education videos).
  static String get baseUrl => _resolveBaseUrl();
}
