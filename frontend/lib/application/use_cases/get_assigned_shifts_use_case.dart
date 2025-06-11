import '../../domain/entities/shift.dart';
import '../../domain/repositories/shift_repository.dart';

class GetAssignedShiftsUseCase {
  final ShiftRepository repository;
  GetAssignedShiftsUseCase(this.repository);

  Future<List<Shift>> call(String employeeId) {
    return repository.getAssignedShifts(employeeId);
  }
} 