import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories_impl/shift_repository_impl.dart';
import '../../application/use_cases/get_assigned_shifts_use_case.dart';
import 'shift_state.dart';

class ShiftNotifier extends StateNotifier<ShiftState> {
  ShiftNotifier() : super(ShiftState.initial());
  final _getAssignedShifts = GetAssignedShiftsUseCase(ShiftRepositoryImpl());

  Future<void> fetchShifts(String employeeId) async {
    print('[ShiftNotifier] fetchShifts called for employeeId: $employeeId');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final shifts = await _getAssignedShifts(employeeId);
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
}

final shiftProvider = StateNotifierProvider<ShiftNotifier, ShiftState>((ref) => ShiftNotifier()); 