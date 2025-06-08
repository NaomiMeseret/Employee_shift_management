import '../../domain/repositories/employee_repository.dart';

class UpdateEmployeePasswordUseCase {
  final EmployeeRepository repository;
  UpdateEmployeePasswordUseCase(this.repository);

  Future<void> call(String id, String currentPassword, String newPassword) {
    return repository.updateEmployeePassword(id, currentPassword, newPassword);
  }
}
