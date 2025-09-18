import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/admin/admin_home_screen.dart';
import 'presentation/screens/employee_dashboard_screen.dart';
import 'presentation/screens/signup_screen.dart';
import 'presentation/screens/admin/admin_user_management_screen.dart';
import 'presentation/screens/admin/admin_shift_screen.dart';
import 'presentation/screens/admin/admin_attendance_screen.dart';
import 'presentation/screens/admin/admin_employee_screen.dart';
import 'presentation/screens/admin/employee_form.dart';
import 'presentation/screens/employee/employee_shift_screen.dart';
import 'presentation/screens/employee/employee_attendance_screen.dart';
import 'presentation/screens/employee/employee_home_screen.dart';
import 'presentation/screens/employee/employee_profile_screen.dart';
import 'presentation/screens/employee/employee_settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  runApp(
    const ProviderScope(
      child: ShiftMasterApp(),
    ),
  );
}

class ShiftMasterApp extends StatelessWidget {
  const ShiftMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShiftMaster - Employee Management',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialRoute: '/login',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/employee': (context) => const EmployeeHomeScreen(),
        // Employee routes
        '/employee/shifts': (context) => const EmployeeShiftScreen(),
        '/employee/attendance': (context) => const EmployeeAttendanceScreen(),
        '/employee/profile': (context) => const EmployeeProfileScreen(),
        '/employee/settings': (context) => const EmployeeSettingsScreen(),
        // Admin routes
        '/admin': (context) => const AdminHomeScreen(),
        '/admin/employees': (context) => const AdminEmployeeScreen(),
        '/admin/employees/add': (context) => const EmployeeForm(),
        '/admin/shifts': (context) => const AdminShiftScreen(),
        '/admin/attendance': (context) => const AdminAttendanceScreen(),
        '/admin/users': (context) => const AdminUserManagementScreen(),
        '/signup': (context) => const SignupScreen(),
      },
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}

