import '../entities/attendance.dart';

abstract class AttendanceRepository {
  Future<List<Attendance>> getAttendance(String employeeId);
  Future<void> clockIn(String employeeId, String shiftId);
  Future<void> clockOut(String employeeId, String shiftId);
} 