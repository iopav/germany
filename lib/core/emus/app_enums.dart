import 'package:freezed_annotation/freezed_annotation.dart';

/// CEFR 语言等级枚举
enum CEFRLevel {

  @JsonValue('A1')
  a1('A1', 'A1'),

  @JsonValue('A2')
  a2('A2', 'A2'),

  @JsonValue('B1')
  b1('B1', 'B1'),

  @JsonValue('B2')
  b2('B2', 'B2'),

  @JsonValue('C1')
  c1('C1', 'C1');

  // 后端真实值
  final String value;
  // 前端 UI 显示文本
  final String label;

  const CEFRLevel(this.value, this.label);
  
  static CEFRLevel fromJson(String value) {
    return CEFRLevel.values.firstWhere((e) => e.value == value, orElse: () => throw ArgumentError('Invalid CEFR level: $value'));
  }
}

enum L1Language {
  @JsonValue('zh')
  chinese('zh', '中文'),

  @JsonValue('en')
  english('en', 'English');

  final String value;
  final String label;

  const L1Language(this.value, this.label);

  static L1Language fromJson(String value) {
    return L1Language.values.firstWhere((e) => e.value == value, orElse: () => throw ArgumentError('Invalid L1 language: $value'));
  }
}

enum UserRole {
  @JsonValue('user')
  user('user', 'User'),

  @JsonValue('admin')
  admin('admin', 'Admin'),

  @JsonValue('reviewer')
  reviewer('reviewer', 'Reviewer');
  final String value;
  final String label;

  const UserRole(this.value, this.label);

  static UserRole fromJson(String value) {
    return UserRole.values.firstWhere((e) => e.value == value, orElse: () => throw ArgumentError('Invalid user role: $value'));
  }

}
