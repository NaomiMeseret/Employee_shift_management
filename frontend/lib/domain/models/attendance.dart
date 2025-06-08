class Attendance {
  final int id;
  final int employeeId;
  final String employeeName;
  final DateTime date;
  final DateTime checkIn;
  final DateTime? checkOut;
  final String status;
  final String? notes;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    this.checkOut,
    required this.status,
    this.notes,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0,
      employeeId: json['employeeId'] != null ? int.tryParse(json['employeeId'].toString()) ?? 0 : 0,
      employeeName: json['employeeName']?.toString() ?? 'Unknown',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime(1970),
      checkIn: DateTime.tryParse(json['checkIn']?.toString() ?? '') ?? DateTime(1970),
      checkOut: json['checkOut'] != null ? DateTime.tryParse(json['checkOut'].toString()) : null,
      status: json['status']?.toString() ?? '',
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'date': date.toIso8601String(),
      'checkIn': checkIn.toIso8601String(),
      'checkOut': checkOut?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }

  Attendance copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    DateTime? date,
    DateTime? checkIn,
    DateTime? checkOut,
    String? status,
    String? notes,
  }) {
    return Attendance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
} 