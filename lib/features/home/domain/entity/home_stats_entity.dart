class SceneEntity {
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
  final List<SceneCardEntity> cards;
  final DateTime? createdAt;
  final Map<String, dynamic> raw;

  SceneEntity({
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
}

class SceneDetectionEntity {
  final int id;
  final List<double> bbox;
  final String label;
  final double confidence;

  SceneDetectionEntity({
    required this.id,
    required this.bbox,
    required this.label,
    required this.confidence,
  });

  double get left => bbox.isNotEmpty ? bbox[0] : 0;
  double get top => bbox.length > 1 ? bbox[1] : 0;
  double get right => bbox.length > 2 ? bbox[2] : 0;
  double get bottom => bbox.length > 3 ? bbox[3] : 0;
  double get width => (right - left).clamp(0, double.infinity);
  double get height => (bottom - top).clamp(0, double.infinity);
}

class SceneCardEntity {
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

  SceneCardEntity({
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
}
