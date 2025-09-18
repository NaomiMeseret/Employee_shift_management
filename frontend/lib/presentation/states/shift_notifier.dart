import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/shift.dart';
import 'shift_state.dart';

class ShiftNotifier extends StateNotifier<ShiftState> {
  ShiftNotifier() : super(ShiftState.initial());

  Future<void> fetchShifts(String employeeId) async {
    print('[ShiftNotifier] fetchShifts called for employeeId: $employeeId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Use mock data for now - replace with actual API call
      final shifts = await _getMockShifts(employeeId);
      print('[ShiftNotifier] Shifts fetched: ${shifts.length}');
      for (var shift in shifts) {
        print('[ShiftNotifier] Shift: date=${shift.date}, type=${shift.shiftType}');
      }
      state = state.copyWith(isLoading: false, shifts: shifts, error: null);
    } catch (e) {
      print('[ShiftNotifier] Error fetching shifts: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<Shift>> _getMockShifts(String employeeId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Return realistic shift data with proper IDs
    final shifts = <Shift>[];
    final now = DateTime.now();
    
    // Today's shift
    shifts.add(Shift(
      id: 'shift_001',
      employeeId: employeeId,
      date: DateFormat('yyyy-MM-dd').format(now),
      shiftType: 'Morning',
      startTime: '06:00',
      endTime: '14:00',
      status: 'active',
    ));
    
    // Tomorrow's shift
    final tomorrow = now.add(const Duration(days: 1));
    shifts.add(Shift(
      id: 'shift_002',
      employeeId: employeeId,
      date: DateFormat('yyyy-MM-dd').format(tomorrow),
      shiftType: 'Morning',
      startTime: '06:00',
      endTime: '14:00',
      status: 'scheduled',
    ));
    
    // Day after tomorrow's shift
    final dayAfter = now.add(const Duration(days: 2));
    shifts.add(Shift(
      id: 'shift_003',
      employeeId: employeeId,
      date: DateFormat('yyyy-MM-dd').format(dayAfter),
      shiftType: 'Morning',
      startTime: '06:00',
      endTime: '14:00',
      status: 'scheduled',
    ));
    
    return shifts;
  }

  List<Shift> _generateMockShifts() {
    final shifts = <Shift>[];
    final random = Random();
    final now = DateTime.now();
    
    // Generate shifts for the last 30 days and next 30 days
    for (int i = -30; i <= 30; i++) {
      final date = now.add(Duration(days: i));
      
      // Skip weekends and some random days to make it more realistic
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        if (random.nextDouble() > 0.3) continue; 
      }
      
      // Skip some weekdays randomly (sick days, vacation, etc.)
      if (random.nextDouble() > 0.85) continue; 
      
      final shiftTypes = ['Morning', 'Afternoon', 'Evening', 'Night'];
      final weights = [0.4, 0.3, 0.2, 0.1]; 
      
      String shiftType = _getWeightedRandomShiftType(shiftTypes, weights, random);
      
      String startTime, endTime;
      switch (shiftType) {
        case 'Morning':
          startTime = '06:00';
          endTime = '14:00';
          break;
        case 'Afternoon':
          startTime = '14:00';
          endTime = '22:00';
          break;
        case 'Evening':
          startTime = '18:00';
          endTime = '02:00';
          break;
        case 'Night':
          startTime = '22:00';
          endTime = '06:00';
          break;
        default:
          startTime = '09:00';
          endTime = '17:00';
      }
      
      String status;
      if (i < -1) {
        status = 'completed';
      } else if (i == -1 || i == 0) {
        status = 'active';
      } else {
        status = 'assigned';
      }
      
      shifts.add(Shift(
        id: 'SH${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}_${random.nextInt(999).toString().padLeft(3, '0')}',
        employeeId: 'emp_001',
        date: DateFormat('yyyy-MM-dd').format(date),
        shiftType: shiftType,
        startTime: startTime,
        endTime: endTime,
        status: status,
        attendance: [],
      ));
    }
    
    return shifts..sort((a, b) => a.date.compareTo(b.date));
  }

  String _getWeightedRandomShiftType(List<String> types, List<double> weights, Random random) {
    double totalWeight = weights.reduce((a, b) => a + b);
    double randomValue = random.nextDouble() * totalWeight;
    
    double currentWeight = 0;
    for (int i = 0; i < types.length; i++) {
      currentWeight += weights[i];
      if (randomValue <= currentWeight) {
        return types[i];
      }
    }
    return types.first;
  }

  String _getEndTime(String shiftType) {
    switch (shiftType.toLowerCase()) {
      case 'morning':
        return '14:00';
      case 'afternoon':
        return '22:00';
      case 'evening':
        return '02:00';
      case 'night':
        return '06:00';
      default:
        return '17:00';
    }
  }
}

final shiftProvider = StateNotifierProvider<ShiftNotifier, ShiftState>((ref) => ShiftNotifier());