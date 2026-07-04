import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_web_willbefore/core/base/base_state.dart';
import 'package:flutter_web_willbefore/features/auth/data/repos/auth_repository_impl.dart';
import 'package:flutter_web_willbefore/features/auth/domain/models/user_model.dart';
import 'package:flutter_web_willbefore/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_web_willbefore/features/auth/domain/requests/login_request.dart';
import 'package:flutter_web_willbefore/features/auth/domain/usecases/login_use_case.dart';

/// Notifies GoRouter whenever auth state changes so the redirect re-runs.
final authRouterRefreshListenable = _AuthRefreshNotifier();

class _AuthRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

class AuthState extends BaseState {
  final UserModel? user;
  final bool isAuthenticated;
  final bool isInitialized;

  const AuthState({
    super.isLoading = false,
    super.errorMessage,
    this.user,
    this.isAuthenticated = false,
    this.isInitialized = false,
  });

  @override
  AuthState copyWith({
    bool? isLoading,
    String? errorMessage,
    UserModel? user,
    bool? isAuthenticated,
    bool? isInitialized,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

final authProvider = StateNotifierProvider<AuthProvider, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final loginUseCase = LoginUseCase(authRepository);

  return AuthProvider(loginUseCase, authRepository);
});

class AuthProvider extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;

  AuthProvider(this._loginUseCase, this._authRepository) : super(AuthState()) {
    _initializeAuthState();

    /// [Listen] to auth state changes — also marks auth as initialized so the
    /// router can react after Firebase restores a persisted web session.
    _authRepository.authStateChanges.listen((user) {
      state = state.copyWith(
        user: user,
        isAuthenticated: user != null,
        isInitialized: true,
      );
      authRouterRefreshListenable.notify();
    });
  }

  Future<void> _initializeAuthState() async {
    try {
      // On web, currentUser may be null here even for a logged-in user because
      // Firebase restores the persisted session asynchronously. Only set
      // isInitialized when we actually have a user; otherwise let the
      // authStateChanges listener handle it.
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final role = await _authRepository.getUserRole(currentUser.uid);
        if (role != 'admin') {
          await _authRepository.logout();
          state = state.copyWith(isAuthenticated: false, isInitialized: true);
          authRouterRefreshListenable.notify();
          return;
        }
        final userModel = UserModel.fromFirebase(currentUser);
        state = state.copyWith(
          user: userModel,
          isAuthenticated: true,
          isInitialized: true,
        );
        authRouterRefreshListenable.notify();
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isInitialized: true,
        errorMessage: e.toString(),
      );
      authRouterRefreshListenable.notify();
    }
  }

  Future<bool> login(LoginRequest request) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final userModel = await _loginUseCase.call(request);

      final role = await _authRepository.getUserRole(userModel.uid);
      if (role != 'admin') {
        await _authRepository.logout();
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Access denied. Only admins can log in.',
        );
        return false;
      }

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authRepository.logout();

      state = state.copyWith(
        user: null,
        isAuthenticated: false,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
