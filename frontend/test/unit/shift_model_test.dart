import 'package:flutter_test/flutter_test.dart';
import '../../lib/domain/models/shift.dart';

void main() {
  group('Shift Model', () {
    test('fromJson and toJson', () {
      final json = {
        'id': '1',
        'employeeId': 101,
        'employeeName': 'John Doe',
        'shiftType': 'Morning',
        'date': '2023-01-01',
        'status': 'scheduled',
        'notes': 'Regular shift',
      };
      final shift = Shift.fromJson(json);
      expect(shift.id, '1');
      expect(shift.employeeId, 101);
      expect(shift.employeeName, 'John Doe');
      expect(shift.shiftType, 'Morning');
      expect(shift.date, '2023-01-01');
      expect(shift.status, 'scheduled');
      expect(shift.notes, 'Regular shift');
      expect(shift.toJson(), json);
    });
  });
} 