import '../../domain/entity/user_entity.dart';
import 'package:germany/core/emus/app_enums.dart';

// --- User 的 Model ---
class UserModel {
  final String id;
  final String email;
  final L1Language l1Language;
  final CEFRLevel targetLevel;
  final UserRole role;
  final bool isVerified;
  final bool isTest;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.l1Language,
    required this.targetLevel,
    required this.role,
    required this.isVerified,
    required this.isTest,
    required this.createdAt,
  });


  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      l1Language: L1Language.fromJson(json['l1_language'] as String),
      targetLevel: CEFRLevel.fromJson(json['target_level'] as String),
      role: UserRole.fromJson(json['role'] as String),
      isVerified: json['is_verified'] as bool,
      isTest: json['is_test'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),    
    );
  }
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      targetLevel: targetLevel,
      role: role,
    );
  }
}


class AuthResponseModel {
  final String accessToken;
  final String tokenType;
  final UserModel user;

  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  
  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,    
      tokenType: json['token_type'] as String,        
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      accessToken: accessToken,
      user: UserEntity(
        id: user.id,
        email: user.email,
        role: user.role,
        targetLevel: user.targetLevel,
      ),
    );
  }
}
