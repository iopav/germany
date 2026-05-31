import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/level_color_constants.dart';
import '../../../core/utils/logger.dart';
import '../domain/entity/home_stats_entity.dart';

class VocabularyItem {
  final String word;
  final String article;
  final String plural;
  final String ipa;
  final String de;
  final String en;
  final String sentenceDe;
  final String sentenceEn;
  final String imageUrl;
  final String level;
  final String gender;
  final String type;
  final String translationL1;
  final List<String> commonErrors;
  final List<String> grammarNotes;
  final List<String> relatedWords;
  final Map<String, dynamic> exampleSentence;
  final int objectId;
  final SceneDetectionEntity? detection;

  VocabularyItem({
    required this.word,
    required this.article,
    required this.plural,
    required this.ipa,
    required this.de,
    required this.en,
    required this.sentenceDe,
    required this.sentenceEn,
    required this.imageUrl,
    required this.level,
    required this.gender,
    required this.type,
    required this.translationL1,
    required this.commonErrors,
    required this.grammarNotes,
    required this.relatedWords,
    required this.exampleSentence,
    required this.objectId,
    required this.detection,
  });
}

class ImmersiveScreen extends StatefulWidget {
  final SceneEntity? scene;
  const ImmersiveScreen({super.key, this.scene});
  @override
  State<ImmersiveScreen> createState() => _ImmersiveScreenState();
}

class _ImmersiveScreenState extends State<ImmersiveScreen> {
  VocabularyItem? selectedItem;
  bool isSceneSummaryCollapsed = false;
  late final List<VocabularyItem> vocabularyList;
  late final String backgroundImageUrl;
  late final String sceneDescription;
  late final bool needsReview;
  late final List<String> sceneTags;

  static const String _fallbackBackgroundImageUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuDxa4FIj_YmMOGYMjla67PSAs_V0tVIPNaFaia4dThy7Tle_xF7K8klAQ27VCh5OGm4G6X_-y6iKff6I9CCbhprlYOrTCPKzYdTXs2ys0hzaZe2Jknt4AF3F9Kr1ltxDR6arT2HLBZzM-U7nrFtiVEIsM2SCEdvBor8nEjZI7lXLV5RhwgnO2Lqmvprrfw0xMh_VAH0wYoUMoHP-LYKtM-vF1yn7ZmqUdCNtGLxUSNZ2BYbx6H-gqsNR0ICmPU0qaF9BPGtHvQq-CPr';

  @override
  void initState() {
    super.initState();

    final scene = widget.scene;
    final resolvedBackgroundImageUrl = _resolveBackgroundImageUrl(scene);

    final detections = scene?.detectionResult ?? const <SceneDetectionEntity>[];
    final cards = scene?.cards ?? const <SceneCardEntity>[];
    final usedDetectionIndexes = <int>{};
    final mappedVocabulary = cards
        .asMap()
        .entries
        .map(
          (entry) {
            final matchedDetection = _findDetectionForCard(
              entry.value,
              detections,
              usedDetectionIndexes,
              cardIndex: entry.key,
            );

            return _cardToVocabularyItem(
              entry.value,
              resolvedBackgroundImageUrl,
              matchedDetection,
            );
          },
        )
        .toList();

    AppLogger.i(
      '[Immersive] detection_count=${detections.length}, cards_count=${cards.length}, rendered_vocabulary_count=${mappedVocabulary.length}',
    );

    vocabularyList = mappedVocabulary;
    backgroundImageUrl = resolvedBackgroundImageUrl;
    sceneDescription = _extractSceneDescription(scene);
    needsReview = scene?.needsReview ?? false;
    sceneTags = _extractSceneTags(scene);
  }

  String _extractSceneDescription(SceneEntity? scene) {
    final llmScene = scene?.llmResult['scene'];
    if (llmScene is Map) {
      final description = llmScene['description_de']?.toString() ?? '';
      if (description.trim().isNotEmpty) {
        return description;
      }
    }
    return 'Generate a descriptive scene description in German based on the image content.';
  }

  List<String> _extractSceneTags(SceneEntity? scene) {
    final llmScene = scene?.llmResult['scene'];
    if (llmScene is Map) {
      final tags = llmScene['scene_tags'];
      if (tags is List) {
        return tags.map((item) => item.toString()).toList();
      }
    }
    return const [];
  }

  String _resolveBackgroundImageUrl(SceneEntity? scene) {
    if (scene == null) {
      return _fallbackBackgroundImageUrl;
    }

    final raw = scene.raw;
    final rawOriginalImage = _readString([
      _readRawString(raw, ['original_image_url', 'originalImageUrl']),
      _readRawString(raw, ['uploaded_image_url', 'uploadedImageUrl']),
      _readRawString(raw, ['upload_image_url', 'uploadImageUrl']),
      _readRawString(raw, ['source_image_url', 'sourceImageUrl']),
    ]);

    return _readString([
      rawOriginalImage,
      scene.sourceImageUrl,
      scene.annotatedImageUrl,
      _fallbackBackgroundImageUrl,
    ]);
  }

  String _readRawString(Map<String, dynamic> raw, List<String> keys) {
    for (final key in keys) {
      final value = raw[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  VocabularyItem _cardToVocabularyItem(
    SceneCardEntity card,
    String defaultImageUrl,
    SceneDetectionEntity? matchedDetection,
  ) {
    final content = card.content;
    final exampleSentence = card.exampleSentence.isNotEmpty
        ? card.exampleSentence
        : _readMap(content['example_sentence']);
    final exampleDe = _readString([
      exampleSentence['de']?.toString() ?? '',
      content['sentence_de']?.toString() ?? '',
      content['example_de']?.toString() ?? '',
      content['sentence']?.toString() ?? '',
    ]);
    final exampleEn = _readString([
      exampleSentence['l1']?.toString() ?? '',
      content['sentence_en']?.toString() ?? '',
      content['example_en']?.toString() ?? '',
      content['sentence_translation']?.toString() ?? '',
    ]);

    return VocabularyItem(
      word: _readString([
        card.word,
        content['word']?.toString() ?? '',
        card.objectLabel,
        card.lemma,
      ]),
      article: _readString([
        card.article,
        content['article']?.toString() ?? '',
      ]),
      plural: _readString([
        card.plural,
        content['plural']?.toString() ?? '',
      ]),
      ipa: _readString([
        card.ipa,
        content['ipa']?.toString() ?? '',
      ]),
      de: _readString([
        content['word']?.toString() ?? '',
        card.objectLabel,
        card.lemma,
        content['de']?.toString() ?? '',
        content['word_de']?.toString() ?? '',
        content['german']?.toString() ?? '',
      ]),
      en: _readString([
        content['translation_l1']?.toString() ?? '',
        content['en']?.toString() ?? '',
        content['word_en']?.toString() ?? '',
        content['english']?.toString() ?? '',
        card.lemma,
      ]),
      sentenceDe: _readString([
        exampleDe,
        content['sentence_de']?.toString() ?? '',
        content['example_de']?.toString() ?? '',
        content['sentence']?.toString() ?? '',
      ]),
      sentenceEn: _readString([
        exampleEn,
        content['sentence_en']?.toString() ?? '',
        content['example_en']?.toString() ?? '',
        content['sentence_translation']?.toString() ?? '',
      ]),
      imageUrl: defaultImageUrl,
      level: card.cefrLevel.isNotEmpty ? card.cefrLevel : 'A1',
      gender: _readString([content['gender']?.toString() ?? '']),
      type: _readString([
        content['type']?.toString() ?? '',
        content['word_type']?.toString() ?? '',
        content['part_of_speech']?.toString() ?? '',
      ]),
      translationL1: _readString([
        card.translationL1,
        content['translation_l1']?.toString() ?? '',
      ]),
      commonErrors: _mergeStringLists([
        card.commonErrors,
        _readStringListDynamic(content['common_errors']),
        _readStringListDynamic(content['commonErrors']),
      ]),
      grammarNotes: _mergeStringLists([
        card.grammarNotes,
        _readStringListDynamic(content['grammar_notes']),
        _readStringListDynamic(content['grammarNotes']),
      ]),
      relatedWords: _mergeStringLists([
        card.relatedWords,
        _readStringListDynamic(content['related_words']),
        _readStringListDynamic(content['relatedWords']),
      ]),
      exampleSentence: exampleSentence,
      objectId: card.objectId,
      detection: matchedDetection,
    );
  }

  SceneDetectionEntity? _findDetectionForCard(
    SceneCardEntity card,
    List<SceneDetectionEntity> detections,
    Set<int> usedDetectionIndexes,
    {
    required int cardIndex,
  }) {
    for (var index = 0; index < detections.length; index++) {
      final detection = detections[index];
      if (
          !usedDetectionIndexes.contains(index) &&
          card.objectId > 0 &&
          detection.id == card.objectId) {
        usedDetectionIndexes.add(index);
        return detection;
      }
    }

    final normalizedCardLabels = {
      card.lemma.toLowerCase(),
      card.word.toLowerCase(),
      card.objectLabel.toLowerCase(),
    }.where((label) => label.trim().isNotEmpty).toSet();

    for (var index = 0; index < detections.length; index++) {
      final detection = detections[index];
      if (usedDetectionIndexes.contains(index)) {
        continue;
      }
      if (normalizedCardLabels.contains(detection.label.toLowerCase())) {
        usedDetectionIndexes.add(index);
        return detection;
      }
    }

    if (
        cardIndex >= 0 &&
        cardIndex < detections.length &&
        !usedDetectionIndexes.contains(cardIndex)) {
      usedDetectionIndexes.add(cardIndex);
      return detections[cardIndex];
    }

    for (var index = 0; index < detections.length; index++) {
      if (!usedDetectionIndexes.contains(index)) {
        usedDetectionIndexes.add(index);
        return detections[index];
      }
    }

    return null;
  }

  Map<String, dynamic> _readMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }

  String _readString(List<String> candidates) {
    for (final value in candidates) {
      if (value.trim().isNotEmpty) {
        return value;
      }
    }
    return '';
  }

  List<String> _readStringListDynamic(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return [value];
    }
    return const [];
  }

  List<String> _mergeStringLists(List<List<String>> groups) {
    final merged = <String>[];
    final seen = <String>{};

    for (final list in groups) {
      for (final value in list) {
        final trimmed = value.trim();
        if (trimmed.isEmpty) {
          continue;
        }
        final normalized = trimmed.toLowerCase();
        if (seen.add(normalized)) {
          merged.add(trimmed);
        }
      }
    }

    return merged;
  }

  void _toggleSceneSummary() {
    setState(() {
      isSceneSummaryCollapsed = !isSceneSummaryCollapsed;
    });
  }

  Widget _buildSceneSummaryBody() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            sceneDescription,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (needsReview) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.16),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.4),
                ),
              ),
              child: const Text(
                'AI may make mistakes. Please review the results.',
                style: TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          if (sceneTags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sceneTags
                  .take(4)
                  .map(
                    (tag) => _buildTag(
                      tag,
                      Colors.white10,
                      Colors.white70,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Image.network(
                backgroundImageUrl,
                fit: BoxFit.contain,
                width: screenSize.width,
                height: screenSize.height,
                alignment: Alignment.center,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.15)),
          ),
          Positioned.fill(
            child: _SceneDetectionOverlay(
              imageUrl: backgroundImageUrl,
              items: vocabularyList,
              onItemTap: (item) => setState(() => selectedItem = item),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 76,
            left: 24,
            right: 24,
            child: GlassContainer(
              borderRadius: BorderRadius.circular(24),
              blur: 18,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _toggleSceneSummary,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                'Scene Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _toggleSceneSummary,
                          splashRadius: 18,
                          icon: Icon(
                            isSceneSummaryCollapsed
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: _buildSceneSummaryBody(),
                      crossFadeState: isSceneSummaryCollapsed
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: const Duration(milliseconds: 220),
                      sizeCurve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGlassButton(
                  icon: Icons.arrow_back,
                  label: 'Home',
                  onTap: () => Navigator.pop(context),
                ),
                _buildGlassPill('IMMERSION MODE'),
                _buildGlassButton(icon: Icons.edit_square, onTap: () {}),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSlide(
                  offset: selectedItem != null
                      ? Offset.zero
                      : const Offset(0, 1.2),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: AnimatedOpacity(
                    opacity: selectedItem != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: selectedItem != null
                          ? _buildDetailPanel(selectedItem!)
                          : const SizedBox(height: 180),
                    ),
                  ),
                ),
                GlassContainer(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  blur: 30,
                  child: Container(
                    height: 160,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    // 底部小卡缩略图横条：这里按横向列表渲染每张 vocabulary 缩略卡。
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      scrollDirection: Axis.horizontal,
                      itemCount: vocabularyList.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final item = vocabularyList[index];
                        final isActive = selectedItem == item;
                        return _buildVocabularyCard(item, isActive);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required IconData icon,
    String? label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: label != null ? 16 : 12,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              if (label != null) ...[
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassPill(String text) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel(VocabularyItem item) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      borderOpacity: 0.3,
      blur: 20,
      // 详情面板：这里展示完整词条信息。
      // 从上到下依次是：词头 / IPA / 翻译、标签、语法说明、常见错误、相关词、例句。
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.article.isNotEmpty ? '${item.article} ${item.word}' : item.word,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.ipa.isNotEmpty)
                      Text(
                        '[${item.ipa}]',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    Text(
                      item.translationL1.isNotEmpty ? item.translationL1 : item.en,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => setState(() => selectedItem = null),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTag(item.level, Colors.white24, Colors.white),
                const SizedBox(width: 8),
                _buildTag(
                  item.article,//change
                  Colors.blue.withOpacity(0.3),
                  Colors.blue.shade200,
                ),
                const SizedBox(width: 8),
                // _buildTag(item.type, Colors.white10, Colors.white70),
              ],
            ),
            if (item.plural.isNotEmpty || item.objectId > 0) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (item.plural.isNotEmpty)
                    _buildTag(
                      'Plural: ${item.plural}',
                      Colors.white10,
                      Colors.white70,
                    ),
                  if (item.objectId > 0)
                    _buildTag(
                      'ID: ${item.objectId}',
                      Colors.white10,
                      Colors.white70,
                    ),
                ],
              ),
            ],
            if (item.grammarNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Grammar Notes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...item.grammarNotes.map(
                      (note) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $note',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (item.commonErrors.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Common Errors',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...item.commonErrors.map(
                      (errorText) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '• $errorText',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.78),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.sentenceDe,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.sentenceEn,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (item.relatedWords.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: item.relatedWords
                    .map(
                      (relatedWord) => _buildTag(
                        relatedWord,
                        Colors.white10,
                        Colors.white70,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(VocabularyItem item, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => selectedItem = item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 140,
        transform: Matrix4.translationValues(0, isActive ? -4 : 0, 0),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(16),
          borderOpacity: isActive ? 0.8 : 0.1,
          bgColor: isActive
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: _DetectionCropPreview(
                        item.imageUrl,
                        detection: item.detection,
                      ),
                    ),
                    if (item.article.isNotEmpty)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              item.article,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    // 小卡片：这里只放最核心的信息。
                    // 图片按 detection_result 的 bbox 裁剪，卡片正文显示：词头、复数、翻译。
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            item.level,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (item.ipa.isNotEmpty)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              '[${item.ipa}]',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        item.article.isNotEmpty ? '${item.article} ${item.word}' : item.word,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.translationL1.isNotEmpty ? item.translationL1 : item.en,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneDetectionOverlay extends StatefulWidget {
  final String imageUrl;
  final List<VocabularyItem> items;
  final ValueChanged<VocabularyItem>? onItemTap;

  const _SceneDetectionOverlay({
    required this.imageUrl,
    required this.items,
    this.onItemTap,
  });

  @override
  State<_SceneDetectionOverlay> createState() => _SceneDetectionOverlayState();
}

class _SceneDetectionOverlayState extends State<_SceneDetectionOverlay> {
  static const double _chipHorizontalPadding = 16;
  static const double _chipTopPadding = 16;
  static const double _chipBottomReservedHeight = 190;
  static const double _chipMinSpacing = 52;

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ImageInfo? _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _SceneDetectionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.items != widget.items) {
      _detachImageListener();
      _resolveImage();
    }
  }

  void _resolveImage() {
    if (widget.imageUrl.isEmpty) {
      return;
    }

    final provider = NetworkImage(widget.imageUrl);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    _imageStreamListener = ImageStreamListener(
      (info, _) {
        if (!mounted) {
          return;
        }
        setState(() {
          _imageInfo = info;
        });
      },
      onError: (_, __) {},
    );
    stream.addListener(_imageStreamListener!);
    _imageStream = stream;
  }

  void _detachImageListener() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
    _imageInfo = null;
  }

  @override
  void dispose() {
    _detachImageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imageInfo = _imageInfo;
    if (imageInfo == null || widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
          final viewportSize = Size(constraints.maxWidth, constraints.maxHeight);
          final imageSize = Size(
            imageInfo.image.width.toDouble(),
            imageInfo.image.height.toDouble(),
          );
          final bottomInset = MediaQuery.of(context).padding.bottom;
          final maxVisibleTop =
              (viewportSize.height - _chipBottomReservedHeight - bottomInset)
                  .clamp(_chipTopPadding, viewportSize.height - _chipTopPadding)
                  .toDouble();
          final placedPositions = <Offset>[];
          final chips = <Widget>[];

          for (final entry in widget.items.asMap().entries) {
            final item = entry.value;
            final detection = item.detection;
            Offset position;

            if (detection != null && detection.bbox.length >= 4) {
              position = _detectionCenterToViewport(
                detection,
                viewportSize,
                imageSize,
              );
            } else {
              position = _fallbackChipPosition(
                itemIndex: entry.key,
                itemCount: widget.items.length,
                viewportSize: viewportSize,
              );
            }

            final clamped = Offset(
              position.dx.clamp(
                _chipHorizontalPadding,
                viewportSize.width - _chipHorizontalPadding,
              ),
              position.dy.clamp(_chipTopPadding, maxVisibleTop),
            );

            final resolved = _resolveChipCollision(
              candidate: clamped,
              placed: placedPositions,
              viewportSize: viewportSize,
              maxVisibleTop: maxVisibleTop,
            );
            placedPositions.add(resolved);

            chips.add(
              Positioned(
                left: resolved.dx,
                top: resolved.dy,
                child: FractionalTranslation(
                  translation: const Offset(-0.5, -0.5),
                  child: Builder(
                    builder: (context) {
                      final label = item.word.isNotEmpty ? item.word : item.de;
                      final dotColor = LevelColorConstants.forLevel(item.level);
                      return _PressableDiscoveryChip(
                        text: label,
                        dotColor: dotColor,
                        onTap: () => widget.onItemTap?.call(item),
                      );
                    },
                  ),
                ),
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            children: chips,
          );
      },
    );
  }

  Offset _resolveChipCollision({
    required Offset candidate,
    required List<Offset> placed,
    required Size viewportSize,
    required double maxVisibleTop,
  }) {
    var resolved = candidate;
    var attempts = 0;

    bool hasCollision(Offset point) {
      for (final other in placed) {
        if ((other - point).distance < _chipMinSpacing) {
          return true;
        }
      }
      return false;
    }

    while (hasCollision(resolved) && attempts < 10) {
      final row = (attempts ~/ 2) + 1;
      final direction = attempts.isEven ? 1.0 : -1.0;
      resolved = Offset(
        (candidate.dx + direction * row * 22).clamp(
          _chipHorizontalPadding,
          viewportSize.width - _chipHorizontalPadding,
        ),
        (candidate.dy - row * 18).clamp(_chipTopPadding, maxVisibleTop),
      );
      attempts++;
    }

    return resolved;
  }
}

Offset _fallbackChipPosition({
  required int itemIndex,
  required int itemCount,
  required Size viewportSize,
}) {
  if (itemCount <= 0) {
    return Offset(viewportSize.width / 2, viewportSize.height / 2);
  }

  final y = viewportSize.height * 0.22;
  final spacing = viewportSize.width / (itemCount + 1);
  final x = spacing * (itemIndex + 1);

  return Offset(x, y);
}

Widget _buildDiscoveryChip(String text, Color dotColor) {
  return GlassContainer(
    borderRadius: BorderRadius.circular(30),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ),
  );
}

class _PressableDiscoveryChip extends StatefulWidget {
  final String text;
  final Color dotColor;
  final VoidCallback? onTap;

  const _PressableDiscoveryChip({
    required this.text,
    required this.dotColor,
    this.onTap,
  });

  @override
  State<_PressableDiscoveryChip> createState() => _PressableDiscoveryChipState();
}

class _PressableDiscoveryChipState extends State<_PressableDiscoveryChip> {
  bool _pressed = false;
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isActive = _pressed || _hovered;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 90),
          scale: _pressed ? 0.97 : 1,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 90),
            opacity: _pressed ? 0.86 : 1,
            child: GlassContainer(
              borderRadius: BorderRadius.circular(30),
              bgColor: isActive
                  ? const Color(0x26FFFFFF)
                  : const Color(0x1AFFFFFF),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: widget.dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Offset _detectionCenterToViewport(
  SceneDetectionEntity detection,
  Size viewportSize,
  Size imageSize,
) {
  final imageWidth = imageSize.width;
  final imageHeight = imageSize.height;
  final scale = mathMin(
    viewportSize.width / imageWidth,
    viewportSize.height / imageHeight,
  );
  final displayedWidth = imageWidth * scale;
  final displayedHeight = imageHeight * scale;
  final offsetX = (viewportSize.width - displayedWidth) / 2;
  final offsetY = (viewportSize.height - displayedHeight) / 2;
  final centerX = (detection.left + detection.right) / 2;
  final centerY = (detection.top + detection.bottom) / 2;

  return Offset(
    offsetX + centerX * scale,
    offsetY + centerY * scale,
  );
}

double mathMin(double a, double b) => a < b ? a : b;
double mathMax(double a, double b) => a > b ? a : b;

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderOpacity;
  final Color bgColor;
  final BorderRadius borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 12.0,
    this.borderOpacity = 0.2,
    this.bgColor = const Color(0x1AFFFFFF),
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: Colors.white.withOpacity(borderOpacity),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DetectionCropPreview extends StatefulWidget {
  final String imageUrl;
  final SceneDetectionEntity? detection;

  const _DetectionCropPreview(
    this.imageUrl, {
    this.detection,
  });

  @override
  State<_DetectionCropPreview> createState() => _DetectionCropPreviewState();
}

class _DetectionCropPreviewState extends State<_DetectionCropPreview> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  ImageInfo? _imageInfo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _DetectionCropPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl || oldWidget.detection != widget.detection) {
      _detachImageListener();
      _resolveImage();
    }
  }

  void _resolveImage() {
    if (widget.detection == null || widget.imageUrl.isEmpty) {
      return;
    }

    final provider = NetworkImage(widget.imageUrl);
    final stream = provider.resolve(createLocalImageConfiguration(context));
    _imageStreamListener = ImageStreamListener(
      (info, _) {
        if (!mounted) {
          return;
        }
        setState(() {
          _imageInfo = info;
        });
      },
      onError: (_, __) {},
    );
    stream.addListener(_imageStreamListener!);
    _imageStream = stream;
  }

  void _detachImageListener() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
    _imageStream = null;
    _imageStreamListener = null;
    _imageInfo = null;
  }

  @override
  void dispose() {
    _detachImageListener();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detection = widget.detection;
    if (detection == null || detection.bbox.length < 4) {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
      );
    }

    final imageInfo = _imageInfo;
    if (imageInfo == null) {
      return Image.network(
        widget.imageUrl,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.black12),
      );
    }

    final imageWidth = imageInfo.image.width.toDouble();
    final imageHeight = imageInfo.image.height.toDouble();

    final left = detection.left.clamp(0.0, imageWidth);
    final top = detection.top.clamp(0.0, imageHeight);
    final cropWidth = detection.width <= 0
        ? imageWidth
        : detection.width.clamp(1.0, imageWidth - left);
    final cropHeight = detection.height <= 0
        ? imageHeight
        : detection.height.clamp(1.0, imageHeight - top);

    return ColoredBox(
      color: Colors.black12,
      child: ClipRect(
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.center,
          child: SizedBox(
            width: cropWidth,
            height: cropHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -left,
                  top: -top,
                  child: SizedBox(
                    width: imageWidth,
                    height: imageHeight,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                        color: Colors.black12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
