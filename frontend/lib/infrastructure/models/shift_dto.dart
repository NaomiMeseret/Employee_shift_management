import '../../domain/entities/shift.dart';

class ShiftDto {
  final String id;
  final String employeeId;
  final String date;
  final String shiftType;
  final List<dynamic>? attendance;

  ShiftDto({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.shiftType,
    this.attendance,
  });

  factory ShiftDto.fromJson(Map<String, dynamic> json) => ShiftDto(
        id: json['id']?.toString() ?? '',
        employeeId: json['employeeId']?.toString() ?? '',
        date: json['date'] ?? '',
        shiftType: json['shiftType'] ?? '',
        attendance: json['attendance'] is List
            ? json['attendance']
            : (json['attendance'] is Map
                ? (json['attendance'] as Map).values.toList()
                : []),
      );

  Shift toDomain() => Shift(
        id: id,
        employeeId: employeeId,
        date: date,
        shiftType: shiftType,
        attendance: attendance,
      );
} 