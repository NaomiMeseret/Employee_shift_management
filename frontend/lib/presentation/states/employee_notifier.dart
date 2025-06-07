import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories_impl/employee_repository_impl.dart';
import '../../application/use_cases/get_all_employees_use_case.dart';
import 'employee_state.dart';

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  EmployeeNotifier() : super(EmployeeState.initial());
  final _getAllEmployees = GetAllEmployeesUseCase(EmployeeRepositoryImpl());

  Future<void> fetchEmployees() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await _getAllEmployees();
      state = state.copyWith(isLoading: false, employees: employees, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final employeeProvider = StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) => EmployeeNotifier()); 