import 'package:pizzeria/models/user_profile.dart';

class UserMapper {
  static UserProfile fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? '',
      role: map['role']?.toString() ?? 'comprador',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  static Map<String, dynamic> toMap(UserProfile user) {
    return {
      'id': user.id,
      'email': user.email,
      'full_name': user.fullName,
      'role': user.role,
      'created_at': user.createdAt.toIso8601String(),
    };
  }
}
