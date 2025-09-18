import '../../domain/entities/attendance.dart';

class AttendanceDto {
  final String actionType;
  final String time;
  final String date;
  final String status;
  final String id;
  final String employeeId;
  final String? clockInTime;
  final String? clockOutTime;
  final double totalHours;

  AttendanceDto({
    required this.actionType,
    required this.time,
    required this.date,
    required this.status,
    required this.id,
    required this.employeeId,
    this.clockInTime,
    this.clockOutTime,
    required this.totalHours,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> json) => AttendanceDto(
        actionType: json['actionType'] ?? '',
        time: json['time'] ?? '',
        date: json['date'] ?? '',
        status: json['status'] ?? '',
        id: json['id'] ?? '',
        employeeId: json['employeeId'] ?? '',
        clockInTime: json['clockInTime'],
        clockOutTime: json['clockOutTime'],
        totalHours: (json['totalHours'] ?? 0.0).toDouble(),
      );

  Attendance toDomain() => Attendance(
        id: id,
        employeeId: employeeId,
        date: date,
        clockInTime: clockInTime,
        clockOutTime: clockOutTime,
        totalHours: totalHours,
        status: status,
      );
}