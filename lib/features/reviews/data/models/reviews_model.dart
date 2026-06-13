// ignore_for_file: public_member_api_docs, sort_constructors_first

// Response Get Due Cards Api V1 Cards Due GetCollapse allarray<object>
// ItemsCollapse allobject
// idstringuuid
// scene_idExpand all(string | null)
// user_idExpand all(string | null)
// object_labelstring
// lemmastring
// contentExpand all(object | null)
// cefr_levelExpand allstring
// scene_tagsExpand all(array<string> | null)
// is_reviewedboolean
// is_officialboolean
// generation_countinteger
// created_atstring
import 'dart:convert';

import 'package:germany/core/emus/app_enums.dart';
import '../../domain/entity/reviews_entity.dart';

class ReviewResponseModel {
  final String id;
  final String sceneId;
  final String userId;
  final String objectLabel;
  final String lemma;
  final Map<String, dynamic>? content;
  final CEFRLevel cefrLevel;
  final List<String>? sceneTags;
  final bool isReviewed;
  final bool isOfficial;
  final int generationCount;
  final DateTime? createdAt;

  ReviewResponseModel({
    required this.id,
    required this.sceneId,
    required this.userId,
    required this.objectLabel,
    required this.lemma,
    this.content,
    required this.cefrLevel,
    this.sceneTags,
    required this.isReviewed,
    required this.isOfficial,
    required this.generationCount,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'sceneId': sceneId,
      'userId': userId,
      'objectLabel': objectLabel,
      'lemma': lemma,
      'content': content,
      'cefrLevel': cefrLevel.value,
      'sceneTags': sceneTags,
      'isReviewed': isReviewed,
      'isOfficial': isOfficial,
      'generationCount': generationCount,
      'createdAt': createdAt?.millisecondsSinceEpoch,
    };
  }

  factory ReviewResponseModel.fromMap(Map<String, dynamic> map) {
    final createdAtValue = map['createdAt'] ?? map['created_at'];

    return ReviewResponseModel(
      id: _readString(map, ['id']),
      sceneId: _readString(map, ['scene_id', 'sceneId']),
      userId: _readString(map, ['user_id', 'userId']),
      objectLabel: _readString(map, ['object_label', 'objectLabel', 'word']),
      lemma: _readString(map, ['lemma', 'word', 'object_label']),
      content: _readMap(map['content']),
      cefrLevel: _readCefrLevel(map['cefr_level'] ?? map['cefrLevel']),
      sceneTags: _readStringList(map['scene_tags'] ?? map['sceneTags']),
      isReviewed: _readBool(map['is_reviewed'] ?? map['isReviewed']),
      isOfficial: _readBool(map['is_official'] ?? map['isOfficial']),
      generationCount: _readInt(
        map['generation_count'] ?? map['generationCount'],
      ),
      createdAt: createdAtValue is String
          ? DateTime.tryParse(createdAtValue)
          : createdAtValue is int
          ? DateTime.fromMillisecondsSinceEpoch(createdAtValue)
          : null,
    );
  }

  ReviewEntity toEntity() {
    return ReviewEntity(
      id: id,
      sceneId: sceneId,
      userId: userId,
      objectLabel: objectLabel,
      lemma: lemma,
      content: content,
      cefrLevel: cefrLevel,
      sceneTags: sceneTags,
      isReviewed: isReviewed,
      isOfficial: isOfficial,
      generationCount: generationCount,
      createdAt: createdAt,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewResponseModel.fromJson(String source) =>
      ReviewResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class ReviewPostModel {
  final String cardId;
  final int rating;
  ReviewPostModel({required this.cardId, required this.rating});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'card_id': cardId, 'rating': rating};
  }

  String toJson() => json.encode(toMap());
}
// {
//   "reviewed_today": 0,
//   "due_count": 0,
//   "total_cards": 0
// }

class ReviewStateModel {
  final int reviewedToday;
  final int dueCount;
  final int totalCards;

  ReviewStateModel({
    required this.reviewedToday,
    required this.dueCount,
    required this.totalCards,
  });

  factory ReviewStateModel.fromMap(Map<String, dynamic> map) {
    return ReviewStateModel(
      reviewedToday: map['reviewed_today'] as int,
      dueCount: map['due_count'] as int,
      totalCards: map['total_cards'] as int,
    );
  }

  String toJson() => json.encode({
    'reviewed_today': reviewedToday,
    'due_count': dueCount,
    'total_cards': totalCards,
  });

  factory ReviewStateModel.fromJson(String source) =>
      ReviewStateModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

String _readString(
  Map<String, dynamic> json,
  List<String> keys, {
  String fallback = '',
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return fallback;
}

Map<String, dynamic>? _readMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<String>? _readStringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  return null;
}

bool _readBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    return value.toLowerCase() == 'true' || value == '1';
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
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

CEFRLevel _readCefrLevel(dynamic value) {
  final text = value?.toString().trim().toUpperCase() ?? '';
  return CEFRLevel.values.firstWhere(
    (level) => level.value == text,
    orElse: () => CEFRLevel.a1,
  );
}
