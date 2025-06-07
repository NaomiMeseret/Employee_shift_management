import 'package:dio/dio.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/remote/dio_client.dart';
import '../models/login_request_dto.dart';
import '../models/signup_request_dto.dart';
import '../models/user_response_dto.dart';
import '../../config/app_config.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio = DioClient().dio;

  String _getDetailedErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Please check:\n'
               '1. Your internet connection\n'
               '2. The server is running\n'
               '3. The IP address is correct (${AppConfig.apiBaseUrl})';
      
      case DioExceptionType.receiveTimeout:
        return 'Server is taking too long to respond. Please check if the server is running properly.';
      
      case DioExceptionType.connectionError:
        return 'Cannot connect to the server. Please verify:\n'
               '1. Your phone and computer are on the same WiFi network\n'
               '2. The backend server is running\n'
               '3. The IP address in app_config.dart matches your computer\'s IP';
      
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return 'Invalid email or password';
        } else if (e.response?.statusCode == 404) {
          return 'Login endpoint not found. Please check if the server is running and the API routes are correct.';
        } else if (e.response?.statusCode == 500) {
          return 'Server error occurred. Please check the backend server logs.';
        }
        return 'Server returned error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      
      default:
        return 'Network error: ${e.message}';
    }
  }

  @override
  Future<User> login({required String email, required String password}) async {
    try {
      final dto = LoginRequestDto(email: email, password: password);
      final response = await _dio.post('/login', data: dto.toJson());
      final userDto = UserResponseDto.fromJson(response.data);
      return userDto.toDomain();
    } on DioException catch (e) {
      throw Exception(_getDetailedErrorMessage(e));
    } catch (e) {
      throw Exception('Unexpected error: $e\n'
          'Please check:\n'
          '1. The API URL is correct in app_config.dart\n'
          '2. The server is running\n'
          '3. Your phone and computer are on the same network');
    }
  }

  @override
  Future<User> signup({
    required String name,
    required String email,
    required String password,
    required String id,
  }) async {
    try {
      final dto = SignupRequestDto(
        name: name,
        email: email,
        password: password,
        id: id,
      );
      final response = await _dio.post('/register', data: dto.toJson());
      final userDto = UserResponseDto.fromJson(response.data);
      return userDto.toDomain();
    } on DioException catch (e) {
      throw Exception(_getDetailedErrorMessage(e));
    } catch (e) {
      throw Exception('Signup failed: $e');
    }
  }
} 