import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

class GetEmployeeByIdUseCase {
  final EmployeeRepository repository;
  GetEmployeeByIdUseCase(this.repository);

  Future<Employee> call(String id) {
    return repository.getEmployeeById(id);
  }
} 