import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class SignupUseCase {
  final AuthRepository repository;
  SignupUseCase(this.repository);

  Future<User> call({
    required String name,
    required String email,
    required String password,
    required String id,
  }) {
    return repository.signup(
      name: name,
      email: email,
      password: password,
      id: id,
    );
  }
} 