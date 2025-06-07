import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../infrastructure/repositories_impl/employee_repository_impl.dart';
import '../../application/use_cases/get_employee_by_id_use_case.dart';
import '../../application/use_cases/update_employee_profile_use_case.dart';
import '../../application/use_cases/update_employee_password_use_case.dart';
import 'profile_state.dart';

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState.initial());
  final _getEmployeeById = GetEmployeeByIdUseCase(EmployeeRepositoryImpl());
  final _updateProfile = UpdateEmployeeProfileUseCase(EmployeeRepositoryImpl());
  final _updatePassword = UpdateEmployeePasswordUseCase(EmployeeRepositoryImpl());

  Future<void> fetchProfile(String id) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      final employee = await _getEmployeeById(id);
      state = state.copyWith(isLoading: false, employee: employee, error: null);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateProfile(String id, {String? name, String? phone, String? position}) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      await _updateProfile(id, name: name, phone: phone, position: position);
      state = state.copyWith(isLoading: false, message: 'Profile updated successfully');
      await fetchProfile(id);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updatePassword(String id, String currentPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null, message: null);
    try {
      await _updatePassword(id, currentPassword, newPassword);
      state = state.copyWith(isLoading: false, message: 'Password updated successfully');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clearMessage() {
    state = state.copyWith(message: null);
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) => ProfileNotifier()); 