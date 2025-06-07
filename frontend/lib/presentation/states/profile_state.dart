import '../../domain/entities/employee.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final Employee? employee;
  final String? message;

  ProfileState({this.isLoading = false, this.error, this.employee, this.message});

  ProfileState copyWith({bool? isLoading, String? error, Employee? employee, String? message}) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      employee: employee ?? this.employee,
      message: message,
    );
  }

  factory ProfileState.initial() => ProfileState();
} 