import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String email, required String password});
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    required String id,
  });
} 