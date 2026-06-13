import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';
import 'package:germany/features/home/domain/entity/home_stats_entity.dart';

class SceneImageCache {
  const SceneImageCache._();

  static String resolveSceneImageUrl(SceneEntity? scene) {
    if (scene == null) {
      return '';
    }

    final raw = scene.raw;
    final candidates = [
      _readRawString(raw, ['original_image_url', 'originalImageUrl']),
      _readRawString(raw, ['uploaded_image_url', 'uploadedImageUrl']),
      _readRawString(raw, ['source_image_url', 'sourceImageUrl']),
      scene.sourceImageUrl,
      scene.annotatedImageUrl,
    ];

    for (final candidate in candidates) {
      final value = candidate.trim();
      if (value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }

  static List<String> resolveSceneImageUrls(SceneEntity? scene) {
    if (scene == null) {
      return const <String>[];
    }

    final raw = scene.raw;
    final candidates = [
      _readRawString(raw, ['original_image_url', 'originalImageUrl']),
      _readRawString(raw, ['uploaded_image_url', 'uploadedImageUrl']),
      _readRawString(raw, ['source_image_url', 'sourceImageUrl']),
      _readRawString(raw, ['annotated_image_url', 'annotatedImageUrl']),
      scene.sourceImageUrl,
      scene.annotatedImageUrl,
    ];

    final seen = <String>{};
    return [
      for (final candidate in candidates)
        if (candidate.trim().isNotEmpty && seen.add(candidate.trim()))
          candidate.trim(),
    ];
  }

  static ImageProvider provider(String imageUrl) {
    return CachedNetworkImageProvider(imageUrl);
  }

  static Future<void> precacheScene(
    BuildContext context,
    SceneEntity? scene,
  ) async {
    final urls = resolveSceneImageUrls(scene);
    for (final url in urls) {
      await precacheImage(provider(url), context);
    }
  }

  static String _readRawString(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }
}
