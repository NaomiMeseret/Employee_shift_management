import '../../domain/entities/attendance.dart';

class AttendanceState {
  final bool isLoading;
  final String? error;
  final List<Attendance> records;

  AttendanceState({this.isLoading = false, this.error, this.records = const []});

  AttendanceState copyWith({bool? isLoading, String? error, List<Attendance>? records}) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      records: records ?? this.records,
    );
  }

  factory AttendanceState.initial() => AttendanceState();
} 