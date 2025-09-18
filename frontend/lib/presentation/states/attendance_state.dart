import '../../domain/entities/attendance.dart';

class AttendanceState {
  final bool isLoading;
  final String? error;
  final List<Attendance> records;
  final bool isClockedIn;

  AttendanceState({
    this.isLoading = false, 
    this.error, 
    this.records = const [],
    this.isClockedIn = false,
  });

  AttendanceState copyWith({
    bool? isLoading, 
    String? error, 
    List<Attendance>? records,
    bool? isClockedIn,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      records: records ?? this.records,
      isClockedIn: isClockedIn ?? this.isClockedIn,
    );
  }

  factory AttendanceState.initial() => AttendanceState();
}