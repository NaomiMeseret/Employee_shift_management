import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/attendance.dart';
import 'attendance_state.dart';

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(AttendanceState.initial());

  Future<void> fetchAttendanceRecords(String employeeId) async {
    print('[AttendanceNotifier] fetchAttendanceRecords called for employeeId: $employeeId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Mock data for now - replace with actual API call
      final records = await _getMockAttendanceRecords(employeeId);
      print('[AttendanceNotifier] Records fetched: ${records.length}');
      state = state.copyWith(isLoading: false, records: records, error: null);
    } catch (e) {
      print('[AttendanceNotifier] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> checkCurrentStatus(String employeeId) async {
    try {
      // Check if user is currently clocked in
      final today = DateTime.now();
      Attendance? todayRecord;
      try {
        todayRecord = state.records.firstWhere((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.year == today.year &&
                 recordDate.month == today.month &&
                 recordDate.day == today.day;
        });
      } catch (e) {
        todayRecord = null;
      }

      final isClockedIn = todayRecord?.clockInTime != null && todayRecord?.clockOutTime == null;
      state = state.copyWith(isClockedIn: isClockedIn);
    } catch (e) {
      print('[AttendanceNotifier] Error checking status: $e');
    }
  }

  Future<void> clockIn(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Find or create today's record
      final existingRecords = List<Attendance>.from(state.records);
      final todayRecordIndex = existingRecords.indexWhere((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.year == today.year &&
               recordDate.month == today.month &&
               recordDate.day == today.day;
      });

      Attendance todayRecord;
      if (todayRecordIndex >= 0) {
        todayRecord = existingRecords[todayRecordIndex];
        if (todayRecord.clockInTime != null) {
          throw Exception('Already clocked in today');
        }
        todayRecord = todayRecord.copyWith(clockInTime: now.toIso8601String());
        existingRecords[todayRecordIndex] = todayRecord;
      } else {
        final todayRecord = Attendance(
          id: 'att_${now.millisecondsSinceEpoch}',
          employeeId: employeeId,
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
          clockInTime: now.toIso8601String(),
          clockOutTime: null,
          totalHours: 0.0,
          status: 'active',
        );
        existingRecords.insert(0, todayRecord);
      }

      state = state.copyWith(
        isLoading: false, 
        records: existingRecords, 
        isClockedIn: true,
        error: null
      );
    } catch (e) {
      String errorMsg = 'Failed to clock in';
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<void> clockOut(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Find today's record
      final existingRecords = List<Attendance>.from(state.records);
      final todayRecordIndex = existingRecords.indexWhere((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.year == today.year &&
               recordDate.month == today.month &&
               recordDate.day == today.day;
      });

      if (todayRecordIndex < 0) {
        throw Exception('No clock in record found for today');
      }

      final todayRecord = existingRecords[todayRecordIndex];
      if (todayRecord.clockInTime == null) {
        throw Exception('Must clock in first');
      }
      if (todayRecord.clockOutTime != null) {
        throw Exception('Already clocked out today');
      }

      final clockInTime = _parseTimeString(todayRecord.clockInTime!);
      if (clockInTime == null) {
        throw Exception('Invalid clock in time format');
      }
      final totalHours = now.difference(clockInTime).inMinutes / 60.0;

      final updatedRecord = todayRecord.copyWith(
        clockOutTime: now.toIso8601String(),
        totalHours: totalHours,
      );
      existingRecords[todayRecordIndex] = updatedRecord;

      state = state.copyWith(
        isLoading: false, 
        records: existingRecords, 
        isClockedIn: false,
        error: null
      );
    } catch (e) {
      String errorMsg = 'You have already clocked out today.';
      state = state.copyWith(isLoading: false, error: errorMsg);
    }
  }

  Future<List<Attendance>> _getMockAttendanceRecords(String employeeId) async {
    // Mock data for demonstration - replace with actual API call
    await Future.delayed(const Duration(milliseconds: 500));
    
    List<Attendance> generateMockAttendanceData() {
      final attendanceList = <Attendance>[];
      final random = Random();
      final now = DateTime.now();
      
      // Generate attendance for the last 30 days
      for (int i = 1; i <= 30; i++) {
        final date = now.subtract(Duration(days: i));
        
        // Skip weekends mostly (90% chance)
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          if (random.nextDouble() > 0.1) continue;
        }
        
        // Skip some weekdays randomly (sick days, vacation, etc.) - 10% chance
        if (random.nextDouble() > 0.9) continue;
        
        // Generate realistic clock in/out times based on shift patterns
        final shiftTypes = ['Morning', 'Afternoon', 'Evening'];
        final shiftType = shiftTypes[random.nextInt(shiftTypes.length)];
        
        DateTime clockInTime, clockOutTime;
        
        switch (shiftType) {
          case 'Morning':
            // 6:00 AM ± 15 minutes
            clockInTime = DateTime(date.year, date.month, date.day, 6, 0)
                .add(Duration(minutes: random.nextInt(30) - 15));
            clockOutTime = clockInTime.add(Duration(hours: 8, minutes: random.nextInt(30) - 15));
            break;
          case 'Afternoon':
            // 2:00 PM ± 15 minutes
            clockInTime = DateTime(date.year, date.month, date.day, 14, 0)
                .add(Duration(minutes: random.nextInt(30) - 15));
            clockOutTime = clockInTime.add(Duration(hours: 8, minutes: random.nextInt(30) - 15));
            break;
          case 'Evening':
            // 6:00 PM ± 15 minutes
            clockInTime = DateTime(date.year, date.month, date.day, 18, 0)
                .add(Duration(minutes: random.nextInt(30) - 15));
            clockOutTime = clockInTime.add(Duration(hours: 8, minutes: random.nextInt(30) - 15));
            break;
          default:
            // Standard 9-5 with variation
            clockInTime = DateTime(date.year, date.month, date.day, 9, 0)
                .add(Duration(minutes: random.nextInt(30) - 15));
            clockOutTime = clockInTime.add(Duration(hours: 8, minutes: random.nextInt(60) - 30));
        }
        
        final totalHours = clockOutTime.difference(clockInTime).inMinutes / 60.0;
        
        String status;
        if (totalHours >= 8) {
          status = 'present';
        } else if (totalHours >= 4) {
          status = 'partial';
        } else {
          status = 'absent';
        }
        
        attendanceList.add(Attendance(
          id: 'ATT${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${random.nextInt(999).toString().padLeft(3, '0')}',
          employeeId: 'emp_001',
          date: DateFormat('yyyy-MM-dd').format(date),
          clockInTime: clockInTime.toIso8601String(),
          clockOutTime: clockOutTime.toIso8601String(),
          totalHours: double.parse(totalHours.toStringAsFixed(2)),
          status: status,
        ));
      }
      
      return attendanceList..sort((a, b) => b.date.compareTo(a.date));
    }
    
    return generateMockAttendanceData();
  }

  DateTime? _parseTimeString(String timeString) {
    try {
      // Handle different time formats
      if (timeString.contains('T')) {
        // ISO format like "2025-01-17T14:30:00"
        return DateTime.parse(timeString);
      } else if (timeString.contains(':')) {
        // Time only format like "14:30"
        final now = DateTime.now();
        final parts = timeString.split(':');
        if (parts.length >= 2) {
          final hour = int.tryParse(parts[0]) ?? 0;
          final minute = int.tryParse(parts[1]) ?? 0;
          return DateTime(now.year, now.month, now.day, hour, minute);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) => AttendanceNotifier());