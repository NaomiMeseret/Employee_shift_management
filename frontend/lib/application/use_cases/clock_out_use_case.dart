import '../../domain/repositories/attendance_repository.dart';

class ClockOutUseCase {
  final AttendanceRepository repository;
  ClockOutUseCase(this.repository);

  Future<void> call(String employeeId, String shiftId) {
    return repository.clockOut(employeeId, shiftId);
  }
}
