class Shift {
  final String id;
  final String employeeId;
  final String date;
  final String shiftType;
  final List<dynamic>? attendance;

  Shift({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.shiftType,
    this.attendance,
  });
} 