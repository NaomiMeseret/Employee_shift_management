import '../entities/shift.dart';

abstract class ShiftRepository {
  Future<List<Shift>> getAssignedShifts(String employeeId);
} 