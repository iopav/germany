import 'package:image_picker/image_picker.dart';

import '../entity/home_stats_entity.dart';

abstract class HomeInterface {
  Future<SceneEntity> createSceneFromImage({required XFile image});
}
