import '../../domain/entities/employee.dart';
import '../../domain/repositories/employee_repository.dart';

class GetAllEmployeesUseCase {
  final EmployeeRepository repository;
  GetAllEmployeesUseCase(this.repository);

  Future<List<Employee>> call() {
    return repository.getAllEmployees();
  }
} 