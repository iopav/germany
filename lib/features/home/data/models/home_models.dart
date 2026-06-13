import '../../domain/entity/home_stats_entity.dart';

class SceneResponseModel {
  final String id;
  final String userId;
  final String sourceType;
  final String sourceImageUrl;
  final String annotatedImageUrl;
  final String status;
  final String errorMessage;
  final List<SceneDetectionEntity> detectionResult;
  final Map<String, dynamic> llmResult;
  final bool needsReview;
  final List<SceneCardModel> cards;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  SceneResponseModel({
    required this.id,
    required this.userId,
    required this.sourceType,
    required this.sourceImageUrl,
    required this.annotatedImageUrl,
    required this.status,
    required this.errorMessage,
    required this.detectionResult,
    required this.llmResult,
    required this.needsReview,
    required this.cards,
    required this.createdAt,
    required this.raw,
  });

  factory SceneResponseModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : Map<String, dynamic>.from(json);

    return SceneResponseModel(
      id: _readString(payload, ['id', 'scene_id']),
      userId: _readString(payload, ['user_id', 'userId']),
      sourceType: _readString(payload, ['source_type', 'sourceType']),
      sourceImageUrl: _readString(payload, [
        'source_image_url',
        'sourceImageUrl',
      ]),
      annotatedImageUrl: _readString(payload, [
        'annotated_image_url',
        'annotatedImageUrl',
      ]),
      status: _readString(payload, ['status']),
      errorMessage: _readString(payload, ['error_message', 'errorMessage']),
      detectionResult: _readDetectionList(payload['detection_result']),
      llmResult: _readMap(payload['llm_result']),
      needsReview: _readBool(payload['needs_review']),
      cards: _readCards(payload)
          .whereType<Map>()
          .map(
            (item) => SceneCardModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      createdAt: _readDateTime(payload['created_at']),
      raw: Map<String, dynamic>.from(payload),
    );
  }

  SceneEntity toEntity() {
    return SceneEntity(
      id: id,
      userId: userId,
      sourceType: sourceType,
      sourceImageUrl: sourceImageUrl,
      annotatedImageUrl: annotatedImageUrl,
      status: status,
      errorMessage: errorMessage,
      detectionResult: detectionResult,
      llmResult: llmResult,
      needsReview: needsReview,
      cards: cards.map((item) => item.toEntity()).toList(),
      createdAt: createdAt,
      raw: raw,
    );
  }
}

List<dynamic> _readCards(Map<String, dynamic> payload) {
  final directCards = _readList(payload['cards']);
  if (directCards.isNotEmpty) {
    return directCards;
  }

  final llmResult = _readMap(payload['llm_result']);
  final llmCards = _readList(llmResult['cards']);
  if (llmCards.isNotEmpty) {
    return llmCards;
  }

  final vocabularyCards = _readList(llmResult['vocabulary_cards']);
  if (vocabularyCards.isNotEmpty) {
    return vocabularyCards;
  }

  final words = _readList(llmResult['words']);
  if (words.isNotEmpty) {
    return words;
  }

  return const [];
}

class SceneDetectionModel {
  final int id;
  final List<double> bbox;
  final String label;
  final double confidence;

  SceneDetectionModel({
    required this.id,
    required this.bbox,
    required this.label,
    required this.confidence,
  });

  factory SceneDetectionModel.fromJson(Map<String, dynamic> json) {
    return SceneDetectionModel(
      id: _readInt(json['id']),
      bbox: _readDoubleList(json['bbox']),
      label: _readString(json, ['label']),
      confidence: _readDouble(json['confidence']),
    );
  }

  SceneDetectionEntity toEntity() {
    return SceneDetectionEntity(
      id: id,
      bbox: bbox,
      label: label,
      confidence: confidence,
    );
  }
}

class SceneCardModel {
  final String id;
  final String sceneId;
  final String userId;
  final String objectLabel;
  final String lemma;
  final int objectId;
  final String word;
  final String article;
  final String plural;
  final String ipa;
  final Map<String, dynamic> content;
  final String cefrLevel;
  final String translationL1;
  final Map<String, dynamic> exampleSentence;
  final List<String> commonErrors;
  final List<String> grammarNotes;
  final List<String> relatedWords;
  final List<String> sceneTags;
  final bool isReviewed;
  final bool isOfficial;
  final int generationCount;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  SceneCardModel({
    required this.id,
    required this.sceneId,
    required this.userId,
    required this.objectLabel,
    required this.lemma,
    required this.objectId,
    required this.word,
    required this.article,
    required this.plural,
    required this.ipa,
    required this.content,
    required this.cefrLevel,
    required this.translationL1,
    required this.exampleSentence,
    required this.commonErrors,
    required this.grammarNotes,
    required this.relatedWords,
    required this.sceneTags,
    required this.isReviewed,
    required this.isOfficial,
    required this.generationCount,
    required this.createdAt,
    required this.raw,
  });

  factory SceneCardModel.fromJson(Map<String, dynamic> json) {
    return SceneCardModel(
      id: _readString(json, ['id']),
      sceneId: _readString(json, ['scene_id']),
      userId: _readString(json, ['user_id']),
      objectLabel: _readString(json, ['object_label', 'word']),
      lemma: _readString(json, ['lemma', 'word']),
      objectId: _readInt(json['object_id']),
      word: _readString(json, ['word', 'lemma', 'object_label']),
      article: _readString(json, ['article']),
      plural: _readString(json, ['plural']),
      ipa: _readString(json, ['ipa']),
      content: _readMap(json['content']),
      cefrLevel: _readString(json, ['cefr_level']),
      translationL1: _readString(json, ['translation_l1']),
      exampleSentence: _readMap(json['example_sentence']),
      commonErrors: _readStringList(json['common_errors']),
      grammarNotes: _readStringList(json['grammar_notes']),
      relatedWords: _readStringList(json['related_words']),
      sceneTags: _readStringList(json['scene_tags']),
      isReviewed: _readBool(json['is_reviewed']),
      isOfficial: _readBool(json['is_official']),
      generationCount: _readInt(json['generation_count']),
      createdAt: _readDateTime(json['created_at']),
      raw: Map<String, dynamic>.from(json),
    );
  }

  SceneCardEntity toEntity() {
    return SceneCardEntity(
      id: id,
      sceneId: sceneId,
      userId: userId,
      objectLabel: objectLabel,
      lemma: lemma,
      objectId: objectId,
      word: word,
      article: article,
      plural: plural,
      ipa: ipa,
      content: content,
      cefrLevel: cefrLevel,
      translationL1: translationL1,
      exampleSentence: exampleSentence,
      commonErrors: commonErrors,
      grammarNotes: grammarNotes,
      relatedWords: relatedWords,
      sceneTags: sceneTags,
      isReviewed: isReviewed,
      isOfficial: isOfficial,
      generationCount: generationCount,
      createdAt: createdAt,
      raw: raw,
    );
  }
}

String _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
  }
  return '';
}

List<dynamic> _readList(dynamic value) {
  if (value is List<dynamic>) {
    return value;
  }
  return const [];
}

List<String> _readStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return const [];
}

List<SceneDetectionEntity> _readDetectionList(dynamic value) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map(
          (item) => SceneDetectionModel.fromJson(
            Map<String, dynamic>.from(item),
          ).toEntity(),
        )
        .toList();
  }
  return const [];
}

List<double> _readDoubleList(dynamic value) {
  if (value is List) {
    return value
        .map(
          (item) => item is num
              ? item.toDouble()
              : double.tryParse(item.toString()) ?? 0,
        )
        .toList();
  }
  return const [];
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

bool _readBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  return false;
}

int _readInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return 0;
}

double _readDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _readDateTime(dynamic value) {
  if (value is String && value.isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
