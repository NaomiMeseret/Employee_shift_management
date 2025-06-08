class Shift {
  final String id;
  final int employeeId;
  final String? employeeName;
  final String shiftType;
  final String date;
  final String? status;
  final String? notes;

  Shift({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.shiftType,
    required this.date,
    this.status,
    this.notes,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      employeeId: json['employeeId'] is int
          ? json['employeeId']
          : int.tryParse(json['employeeId']?.toString() ?? '0') ?? 0,
      employeeName: json['employeeName'] as String?,
      shiftType: json['shiftType'] as String? ?? '',
      date: json['date'] as String? ?? '',
      status: json['status'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'shiftType': shiftType,
      'date': date,
      'status': status,
      'notes': notes,
    };
  }

  Shift copyWith({
    String? id,
    int? employeeId,
    String? employeeName,
    String? shiftType,
    String? date,
    String? status,
    String? notes,
  }) {
    return Shift(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      shiftType: shiftType ?? this.shiftType,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
} 