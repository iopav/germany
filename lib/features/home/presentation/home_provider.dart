import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/utils/logger.dart';
import '../data/impl/home_impl.dart';
import '../domain/entity/home_stats_entity.dart';
import '../domain/interface/home_interface.dart';

class HomeState {
  final XFile? selectedImage;
  final bool isGenerating;
  final String? errorMessage;
  final SceneEntity? latestScene;

  const HomeState({
    this.selectedImage,
    this.isGenerating = false,
    this.errorMessage,
    this.latestScene,
  });

  HomeState copyWith({
    XFile? selectedImage,
    bool? isGenerating,
    String? errorMessage,
    SceneEntity? latestScene,
    bool clearError = false,
  }) {
    return HomeState(
      selectedImage: selectedImage ?? this.selectedImage,
      isGenerating: isGenerating ?? this.isGenerating,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      latestScene: latestScene ?? this.latestScene,
    );
  }
}

class HomeNotifier extends Notifier<HomeState> {
  final ImagePicker _picker = ImagePicker();

  @override
  HomeState build() {
    return const HomeState();
  }

  Future<XFile?> pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) {
        state = state.copyWith(clearError: true);
        return null;
      }

      state = state.copyWith(selectedImage: pickedFile, clearError: true);
      return pickedFile;
    } catch (_) {
      state = state.copyWith(errorMessage: '选择图片失败，请检查权限后重试');
      return null;
    }
  }

  Future<String?> validateSelectedImage() async {
    final image = state.selectedImage;
    if (image == null) {
      return '请先选择图片';
    }

    const maxSizeInBytes = 10 * 1024 * 1024;
    final size = await image.length();
    if (size > maxSizeInBytes) {
      return '图片大小不能超过 10 MB';
    }

    final fileName = image.name.trim().isEmpty ? image.path : image.name;
    final parts = fileName.split('.');
    final extension = parts.length > 1 ? parts.last.toLowerCase() : '';
    const imageExtensions = {
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'bmp',
      'heic',
      'heif',
    };

    if (!imageExtensions.contains(extension)) {
      return '仅支持图片格式（jpg/png/webp/gif/bmp/heic）';
    }

    return null;
  }

  Future<SceneEntity> generateScene() async {
    final validationError = await validateSelectedImage();
    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      throw Exception(validationError);
    }

    final selectedImage = state.selectedImage!;
    state = state.copyWith(isGenerating: true, clearError: true);

    try {
      final HomeInterface homeInterface = ref.read(homeInterfaceProvider);
      final result = await homeInterface.createSceneFromImage(image: selectedImage);
      final llmCards = _readLlmCardsCount(result.llmResult);
      AppLogger.i(
        '[Home] detection_bbox_count=${result.detectionResult.length}, llm_result_cards_count=$llmCards',
      );

      state = state.copyWith(
        isGenerating: false,
        latestScene: result,
        clearError: true,
      );
      return result;
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isGenerating: false, errorMessage: message);
      throw Exception(message);
    }
  }
  Future<SceneEntity> generateFromText(String prompt) async {
    if (prompt.trim().isEmpty) {
      final error = '请输入描述文本';
      state = state.copyWith(errorMessage: error);
      throw Exception(error);
    }

    state = state.copyWith(isGenerating: true, clearError: true);

    try {
      final HomeInterface homeInterface = ref.read(homeInterfaceProvider);
      final result = await homeInterface.createSceneFromText(prompt: prompt);
      final llmCards = _readLlmCardsCount(result.llmResult);
      AppLogger.i(
        '[Home] LLM,llm_result_cards_count=$llmCards',
      );

      state = state.copyWith(
        isGenerating: false,
        latestScene: result,
        clearError: true,
      );
      return result;
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      state = state.copyWith(isGenerating: false, errorMessage: message);
      throw Exception(message);
    }
  }


  int _readLlmCardsCount(Map<String, dynamic> llmResult) {
    final cards = llmResult['cards'];
    if (cards is List) {
      return cards.length;
    }

    final vocabularyCards = llmResult['vocabulary_cards'];
    if (vocabularyCards is List) {
      return vocabularyCards.length;
    }

    final words = llmResult['words'];
    if (words is List) {
      return words.length;
    }

    return 0;
  }
}

final homeProvider = NotifierProvider<HomeNotifier, HomeState>(() {
  return HomeNotifier();
});
