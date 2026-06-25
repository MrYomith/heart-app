import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_user.dart';
import '../services/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  const AuthState(this.status, [this.user]);

  const AuthState.unknown() : this(AuthStatus.unknown, null);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repo) : super(const AuthState.unknown()) {
    _bootstrap();
  }

  final AuthRepository _repo;

  /// On launch, restore a session from a stored token if it's still valid.
  Future<void> _bootstrap() async {
    final user = await _repo.currentUser();
    state = user != null
        ? AuthState(AuthStatus.authenticated, user)
        : const AuthState(AuthStatus.unauthenticated);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required bool consentAccepted,
  }) async {
    final user = await _repo.register(
      name: name,
      email: email,
      password: password,
      consentAccepted: consentAccepted,
    );
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> login({required String email, required String password}) async {
    final user = await _repo.login(email: email, password: password);
    state = AuthState(AuthStatus.authenticated, user);
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(AuthStatus.unauthenticated);
  }

  /// Re-fetch the profile from /auth/me (e.g. after onboarding completes) so the
  /// app re-routes from the wizard to the home experience.
  Future<void> refreshUser() async {
    final user = await _repo.currentUser();
    if (user != null) {
      state = AuthState(AuthStatus.authenticated, user);
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
