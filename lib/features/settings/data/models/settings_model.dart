import 'package:germany/core/emus/app_enums.dart';

class UpdateUserRequestModel {
  final L1Language l1Language;
  final CEFRLevel targetLevel;

  const UpdateUserRequestModel({
    required this.l1Language,
    required this.targetLevel,
  });

  Map<String, dynamic> toJson() {
    return {'l1_language': l1Language.value, 'target_level': targetLevel.value};
  }
}
