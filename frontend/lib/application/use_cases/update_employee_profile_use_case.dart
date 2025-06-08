import '../../domain/repositories/employee_repository.dart';

class UpdateEmployeeProfileUseCase {
  final EmployeeRepository repository;
  UpdateEmployeeProfileUseCase(this.repository);

  Future<void> call(String id,
      {String? name, String? phone, String? position}) {
    return repository.updateEmployeeProfile(id,
        name: name, phone: phone, position: position);
  }
}
