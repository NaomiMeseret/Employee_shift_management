import 'package:dio/dio.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../data_sources/remote/dio_client.dart';
import '../models/attendance_dto.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<List<Attendance>> getAttendance(String employeeId) async {
    final numericId = int.parse(employeeId);
    final response = await _dio.get('/assignedShift/$numericId');
    final data = response.data;

    print('[AttendanceRepositoryImpl] Raw response: $data');

    if (data is! Map || data['shifts'] is! List) {
      print('Unexpected data format: ${data.runtimeType}');
      return [];
    }

    // Extract all attendance records from all shifts
    List<dynamic> allAttendanceRecords = [];
    for (var shift in data['shifts']) {
      if (shift['attendance'] is List) {
        allAttendanceRecords.addAll(shift['attendance']);
      }
    }

    print('[AttendanceRepositoryImpl] Total attendance records found: ${allAttendanceRecords.length}');

    final parsedRecords = allAttendanceRecords
        .whereType<Map<String, dynamic>>()
        .map((json) {
          print('[AttendanceRepositoryImpl] Parsing record: $json');
          return AttendanceDto.fromJson(json).toDomain();
        })
        .toList();
    
    print('[AttendanceRepositoryImpl] Successfully parsed ${parsedRecords.length} records');
    return parsedRecords;
  }

  @override
  Future<void> clockIn(String employeeId, String shiftId) async {
    try {
     final response = await _dio.post('/clockin/$employeeId', data: {
  'shiftId': shiftId,
});

      print('Clock in response: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Failed to clock in: ${response.statusMessage}');
      }
    } catch (e) {
      print('Clock in error details:');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response?.data}');
        print('DioError status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  @override
  Future<void> clockOut(String employeeId, String shiftId) async {
    try {
      final response = await _dio.post('/clockout/$employeeId', data: {
  'shiftId': shiftId,
});

      print('Clock out response: ${response.data}');
      if (response.statusCode != 200) {
        throw Exception('Failed to clock out: ${response.statusMessage}');
      }
    } catch (e) {
      print('Clock out error details:');
      if (e is DioException) {
        print('DioError type: ${e.type}');
        print('DioError message: ${e.message}');
        print('DioError response: ${e.response?.data}');
        print('DioError status code: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }
} 