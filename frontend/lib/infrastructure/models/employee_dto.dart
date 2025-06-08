import '../../domain/entities/employee.dart';

class EmployeeDto {
  final String name;
  final String email;
  final String id;
  final String profilePicture;
  final String phone;
  final String position;
  final String status;
  final bool isAdmin;

  EmployeeDto({
    required this.name,
    required this.email,
    required this.id,
    required this.profilePicture,
    required this.phone,
    required this.position,
    required this.status,
    required this.isAdmin,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic> json) => EmployeeDto(
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        id: json['id'].toString(),
        profilePicture: json['profilePicture'] ?? '',
        phone: json['phone'] ?? '',
        position: json['position'] ?? '',
        status: json['status'] ?? '',
        isAdmin: json['isAdmin'] ?? false,
      );

  Employee toDomain() => Employee(
        name: name,
        email: email,
        id: id,
        profilePicture: profilePicture,
        phone: phone,
        position: position,
        status: status,
        isAdmin: isAdmin,
      );
} 