import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/entity/home_stats_entity.dart';
import '../../domain/interface/home_interface.dart';
import '../services/home_service.dart';

class HomeImplementation implements HomeInterface {
  final HomeService _homeService;

  HomeImplementation(this._homeService);

  @override
  Future<SceneEntity> createSceneFromImage({required XFile image}) async {
    final model = await _homeService.createSceneFromImage(image: image);
    return model.toEntity();
  }
}

final homeInterfaceProvider = Provider<HomeInterface>((ref) {
  final service = ref.read(homeServiceProvider);
  return HomeImplementation(service);
});
