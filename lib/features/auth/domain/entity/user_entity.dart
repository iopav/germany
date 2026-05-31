// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:germany/core/emus/app_enums.dart';


// 认证结果
class AuthEntity {
  final String accessToken;
  final UserEntity user;

  AuthEntity({
    required this.accessToken,
    required this.user,
  });
}

//用户信息结构
class UserEntity {
  final String id;
  final String email;
  final UserRole role;
  final CEFRLevel targetLevel;

  UserEntity({
    required this.id,
    required this.email,
    required this.role,
    required this.targetLevel,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    UserRole? role,
    CEFRLevel? targetLevel,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      targetLevel: targetLevel ?? this.targetLevel,
    );
  }

}
