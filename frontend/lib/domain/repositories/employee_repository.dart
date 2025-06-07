import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<List<Employee>> getAllEmployees();
  Future<Employee> getEmployeeById(String id);
  Future<void> updateEmployeeProfile(String id, {String? name, String? phone, String? position});
  Future<void> updateEmployeePassword(String id, String currentPassword, String newPassword);
} 