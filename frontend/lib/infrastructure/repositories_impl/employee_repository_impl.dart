import 'package:dio/dio.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';
import '../data_sources/remote/dio_client.dart';
import '../models/employee_dto.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<List<Employee>> getAllEmployees() async {
    final response = await _dio.get('/employees');
    final List<dynamic> employeesJson = response.data;
    return employeesJson.map((json) => EmployeeDto.fromJson(json).toDomain()).toList();
  }

  @override
  Future<Employee> getEmployeeById(String id) async {
    final response = await _dio.get('/employees/$id');
    return EmployeeDto.fromJson(response.data).toDomain();
  }

  @override
  Future<void> updateEmployeeProfile(String id, {String? name, String? phone, String? position}) async {
    await _dio.put('/updateEmployee/$id', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (position != null) 'position': position,
    });
  }

  @override
  Future<void> updateEmployeePassword(String id, String currentPassword, String newPassword) async {
    await _dio.post('/changePassword/$id', data: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }
} 