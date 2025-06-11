import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';

class GetAttendanceUseCase {
  final AttendanceRepository repository;
  GetAttendanceUseCase(this.repository);

  Future<List<Attendance>> call(String employeeId) {
    return repository.getAttendance(employeeId);
  }
} 