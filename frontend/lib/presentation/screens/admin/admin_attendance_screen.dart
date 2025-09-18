import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/admin_navigation_bar.dart';
import '../../widgets/admin_header.dart';
import '../../../domain/models/attendance.dart';

class AdminAttendanceScreen extends ConsumerWidget {
  const AdminAttendanceScreen({Key? key}) : super(key: key);

  @override
Widget build(BuildContext context, WidgetRef ref) {
  return WillPopScope(
    onWillPop: () async {
      Navigator.pushReplacementNamed(context, '/admin');
      return false;
    },
    child: Scaffold(
      appBar: const AdminHeader(title: 'Attendance Management'),
      body: Column(
        children: [
          const AdminNavigationBar(currentIndex: 3),
          Expanded(
            child: _buildAttendanceList(_dummyAttendanceRecords()),
          ),
        ],
      ),
    ),
  );
}
  List<Attendance> _dummyAttendanceRecords() {
    return [
      Attendance(
        id: 1,
        employeeId: 1234,
        employeeName: 'kk',
        date: DateTime.parse('2025-05-18T00:00:00.000'),
        checkIn: DateTime.parse('2025-05-18T09:00:00.000'),
        checkOut: DateTime.parse('2025-05-18T17:00:00.000'),
        status: 'Present',
        notes: 'On time',
      ),
      Attendance(
        id: 2,
        employeeId: 1234,
        employeeName: 'kk',
        date: DateTime.parse('2025-05-19T00:00:00.000'),
        checkIn: DateTime.parse('2025-05-19T09:15:00.000'),
        checkOut: DateTime.parse('2025-05-19T17:00:00.000'),
        status: 'Late',
        notes: 'Traffic delay',
      ),
      Attendance(
        id: 3,
        employeeId: 103,
        employeeName: 'dibo',
        date: DateTime.parse('2025-05-14T00:00:00.000'),
        checkIn: DateTime.parse('2025-05-14T09:00:00.000'),
        checkOut: DateTime.parse('2025-05-14T17:00:00.000'),
        status: 'Present',
        notes: '',
      ),
      Attendance(
        id: 4,
        employeeId: 103,
        employeeName: 'dibo',
        date: DateTime.parse('2025-05-13T00:00:00.000'),
        checkIn: DateTime.parse('2025-05-13T00:00:00.000'), // Absent, so no check-in
        checkOut: DateTime.parse('2025-05-13T00:00:00.000'),
        status: 'Absent',
        notes: 'Sick leave',
      ),
      Attendance(
        id: 5,
        employeeId: 104,
        employeeName: 'ruth',
        date: DateTime.parse('2025-05-12T00:00:00.000'),
        checkIn: DateTime.parse('2025-05-12T09:00:00.000'),
        checkOut: DateTime.parse('2025-05-12T17:00:00.000'),
        status: 'Present',
        notes: '',
      ),
    ];
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Start Date',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
              onTap: () {
                // TODO: Show date picker
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'End Date',
                suffixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              readOnly: true,
              onTap: () {
                // TODO: Show date picker
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(List<Attendance> attendanceRecords) {
    final grouped = groupAttendanceByDate(attendanceRecords);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: grouped.entries.map((entry) {
        final date = entry.key;
        final records = entry.value;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    date,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                SingleChildScrollView(
  scrollDirection: Axis.horizontal,
  child: DataTable(
                    columnSpacing: 16,
                    headingRowColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.blue[50]),
                    columns: const [
                      DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Shift', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List.generate(records.length, (i) {
                      final record = records[i];
                      return DataRow(
                        color: WidgetStateProperty.resolveWith<Color?>((states) => i % 2 == 0 ? Colors.grey[100] : Colors.white),
                        cells: [
                          DataCell(Text(record.employeeName)),
                          DataCell(Text(record.employeeId.toString())),
                          DataCell(Text(_getShiftLabel(record))),
                          DataCell(
                            Row(
                              children: [
                                Icon(
                                  record.status.toLowerCase() == 'present'
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: record.status.toLowerCase() == 'present'
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(record.status),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Map<String, List<Attendance>> groupAttendanceByDate(List<Attendance> records) {
    final Map<String, List<Attendance>> grouped = {};
    for (var record in records) {
      final dateStr = record.date.toIso8601String().split('T')[0];
      grouped.putIfAbsent(dateStr, () => []).add(record);
    }
    // Sort by date descending (latest first)
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    return {for (var k in sortedKeys) k: grouped[k]!};
  }

  String _getShiftLabel(Attendance record) {
    // Customize this logic if you have a shiftType field
    return '${record.checkIn.hour.toString().padLeft(2, '0')}:${record.checkIn.minute.toString().padLeft(2, '0')}';
  }

  void _showAttendanceOptions(BuildContext context, Attendance record) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Record'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    '/admin/attendance/edit',
                    arguments: record,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Record', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, record);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Attendance record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Attendance Record'),
          content: Text(
            'Are you sure you want to delete the attendance record for ${record.employeeName ?? 'Unknown'} on ${record.date}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Implement delete functionality
                Navigator.pop(context);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
} 