class Shift {
  final String id;
  final String employeeId;
  final String date;
  final String shiftType;
  final String startTime;
  final String endTime;
  final String status;
  final List<dynamic>? attendance;

  Shift({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.shiftType,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.attendance,
  });
} 