import 'package:flutter_test/flutter_test.dart';
import 'package:employee_shift_management/domain/models/employee.dart';

void main() {
  group('Employee Model', () {
    test('fromJson and toJson', () {
      final json = {
        'id': 1,
        'name': 'John Doe',
        'email': 'john@example.com',
        'phone': '1234567890',
        'position': 'Developer',
        'status': 'active',
        'isAdmin': true,
        'profilePicture': 'profile.png',
        'password': 'secret',
      };
      final employee = Employee.fromJson(json);
      expect(employee.id, 1);
      expect(employee.name, 'John Doe');
      expect(employee.email, 'john@example.com');
      expect(employee.phone, '1234567890');
      expect(employee.position, 'Developer');
      expect(employee.status, 'active');
      expect(employee.isAdmin, true);
      expect(employee.profilePicture, 'profile.png');
      expect(employee.password, 'secret');
      expect(employee.toJson(), json);
    });
  });
} 