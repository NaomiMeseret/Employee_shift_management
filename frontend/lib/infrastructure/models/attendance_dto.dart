import '../../domain/entities/attendance.dart';

class AttendanceDto {
  final String actionType;
  final String time;
  final String date;
  final String status;

  AttendanceDto({
    required this.actionType,
    required this.time,
    required this.date,
    required this.status,
  });

  factory AttendanceDto.fromJson(Map<String, dynamic> json) => AttendanceDto(
        actionType: json['actionType'] ?? '',
        time: json['time'] ?? '',
        date: json['date'] ?? '',
        status: json['status'] ?? '',
      );

  Attendance toDomain() => Attendance(
        actionType: actionType,
        time: time,
        date: date,
        status: status,
      );
} 