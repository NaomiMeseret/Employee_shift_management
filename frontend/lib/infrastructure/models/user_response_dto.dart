import '../../domain/entities/user.dart';

class UserResponseDto {
  final String id;
  final String name;
  final String email;
  final bool isAdmin;

  UserResponseDto({required this.id, required this.name, required this.email, required this.isAdmin});

  factory UserResponseDto.fromJson(Map<String, dynamic> json) => UserResponseDto(
        id: json['employee']['id']?.toString() ?? '',
        name: json['employee']['name'] ?? '',
        email: json['employee']['email'] ?? '',
        isAdmin: json['employee']['isAdmin'] ?? false,
      );

  User toDomain() => User(id: id, name: name, email: email, isAdmin: isAdmin);
} 