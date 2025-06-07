import '../../domain/entities/shift.dart';

class ShiftState {
  final bool isLoading;
  final String? error;
  final List<Shift> shifts;

  ShiftState({this.isLoading = false, this.error, this.shifts = const []});

  ShiftState copyWith({bool? isLoading, String? error, List<Shift>? shifts}) {
    return ShiftState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      shifts: shifts ?? this.shifts,
    );
  }

  factory ShiftState.initial() => ShiftState();
} 