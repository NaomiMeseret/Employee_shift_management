import '../../domain/repositories/attendance_repository.dart';

class ClockInUseCase {
  final AttendanceRepository repository;
  ClockInUseCase(this.repository);

  Future<void> call(String employeeId, String shiftId) {
    return repository.clockIn(employeeId, shiftId);
  }
}
