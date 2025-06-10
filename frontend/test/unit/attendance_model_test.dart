import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/models/attendance.dart';

void main() {
  group('Attendance Model', () {
    test('fromJson and toJson', () {
      final json = {
        'id': 1,
        'employeeId': 101,
        'employeeName': 'John Doe',
        'date': '2023-01-01T00:00:00.000Z',
        'checkIn': '2023-01-01T09:00:00.000Z',
        'checkOut': '2023-01-01T17:00:00.000Z',
        'status': 'present',
        'notes': 'On time',
      };
      final attendance = Attendance.fromJson(json);
      expect(attendance.id, 1);
      expect(attendance.employeeId, 101);
      expect(attendance.employeeName, 'John Doe');
      expect(attendance.date, DateTime.parse('2023-01-01T00:00:00.000Z'));
      expect(attendance.checkIn, DateTime.parse('2023-01-01T09:00:00.000Z'));
      expect(attendance.checkOut, DateTime.parse('2023-01-01T17:00:00.000Z'));
      expect(attendance.status, 'present');
      expect(attendance.notes, 'On time');
      expect(attendance.toJson(), json);
    });
  });
} 