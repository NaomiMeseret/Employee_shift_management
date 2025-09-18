class Attendance {
  final String id;
  final String employeeId;
  final String date;
  final String? clockInTime;
  final String? clockOutTime;
  final double totalHours;
  final String status;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    this.clockInTime,
    this.clockOutTime,
    required this.totalHours,
    required this.status,
  });

  Attendance copyWith({
    String? id,
    String? employeeId,
    String? date,
    String? clockInTime,
    String? clockOutTime,
    double? totalHours,
    String? status,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      totalHours: totalHours ?? this.totalHours,
      status: status ?? this.status,
    );
  }
} 