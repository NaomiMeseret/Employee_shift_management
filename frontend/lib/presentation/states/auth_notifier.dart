import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../infrastructure/repositories_impl/auth_repository_impl.dart';
import '../../application/use_cases/login_use_case.dart';
import '../../application/use_cases/signup_use_case.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());
  final _loginUseCase = LoginUseCase(AuthRepositoryImpl());
  final _signupUseCase = SignupUseCase(AuthRepositoryImpl());

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _loginUseCase(email: email, password: password);
      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signup(String name, String email, String password, String id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signupUseCase(
        name: name,
        email: email,
        password: password,
        id: id,
      );
      state = state.copyWith(isLoading: false, user: user, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void logout() {
    state = AuthState.initial();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier()); 