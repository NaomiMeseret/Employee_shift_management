import '../../domain/entities/employee.dart';

class EmployeeState {
  final bool isLoading;
  final String? error;
  final List<Employee> employees;

  EmployeeState({this.isLoading = false, this.error, this.employees = const []});

  EmployeeState copyWith({bool? isLoading, String? error, List<Employee>? employees}) {
    return EmployeeState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      employees: employees ?? this.employees,
    );
  }

  factory EmployeeState.initial() => EmployeeState();
} 