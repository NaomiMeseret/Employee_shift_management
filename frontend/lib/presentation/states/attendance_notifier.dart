import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories_impl/attendance_repository_impl.dart';
import '../../application/use_cases/get_attendance_use_case.dart';
import '../../application/use_cases/clock_in_use_case.dart';
import '../../application/use_cases/clock_out_use_case.dart';
import 'attendance_state.dart';
import 'package:dio/dio.dart';

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(AttendanceState.initial());
  final _getAttendance = GetAttendanceUseCase(AttendanceRepositoryImpl());
  final _clockIn = ClockInUseCase(AttendanceRepositoryImpl());
  final _clockOut = ClockOutUseCase(AttendanceRepositoryImpl());

  Future<void> fetchAttendance(String employeeId) async {
    print('[AttendanceNotifier] fetchAttendance called for employeeId: $employeeId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _getAttendance(employeeId);
      print('[AttendanceNotifier] Records fetched: ${records.length}');
      for (var rec in records) {
        print('[AttendanceNotifier] Record: actionType=${rec.actionType}, status=${rec.status}, date=${rec.date}, time=${rec.time}');
      }
      state = state.copyWith(isLoading: false, records: records, error: null);
    } catch (e) {
      print('[AttendanceNotifier] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> clockIn(String employeeId, String shiftId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _clockIn(employeeId, shiftId);
      await fetchAttendance(employeeId);
    } catch (e) {
      String errorMsg = e.toString();
      if (e is DioException) {
        final msg = e.response?.data.toString().toLowerCase() ?? '';
        if (msg.contains('already clocked in')) {
          errorMsg = 'You have already clocked in for this shift.';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> clockOut(String employeeId, String shiftId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _clockOut(employeeId, shiftId);
      await fetchAttendance(employeeId);
    } catch (e) {
      String errorMsg = e.toString();
      if (e is DioException) {
        final msg = e.response?.data.toString().toLowerCase() ?? '';
        if (msg.contains('already clocked out')) {
          errorMsg = 'You have already clocked out for this shift.';
        }
      }
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) => AttendanceNotifier()); 