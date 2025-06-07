import 'package:dio/dio.dart';
import '../../domain/entities/shift.dart';
import '../../domain/repositories/shift_repository.dart';
import '../data_sources/remote/dio_client.dart';
import '../models/shift_dto.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final Dio _dio = DioClient().dio;

  @override
  Future<List<Shift>> getAssignedShifts(String employeeId) async {
  final numericId = int.parse(employeeId);
  final response = await _dio.get('/assignedShift/$numericId');

  final raw = response.data;

  Map<String, dynamic> dataMap;
  try {
    dataMap = Map<String, dynamic>.from(raw);
  } catch (e) {
    print('Failed to cast response to Map<String, dynamic>: $e');
    return [];
  }

  final shiftsJson = dataMap['shifts'];
  if (shiftsJson is! List) {
    print('Unexpected "shifts" type: ${shiftsJson.runtimeType}');
    return [];
  }

  final List<Shift> shifts = [];

  for (var item in shiftsJson) {
    if (item is Map<String, dynamic>) {
      try {
        final shift = ShiftDto.fromJson(item);
        shifts.add(shift.toDomain());
      } catch (e, stack) {
        print('==============================');
        print('Error parsing shift item: $e');
        print('Item: $item');
        print('Stack trace: $stack');
        print('==============================');
      }
    } else {
      print('Skipping non-map item: $item');
    }
  }

  return shifts;
}
}