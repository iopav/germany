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
      id: map['id'] as String,
      sceneId: map['scene_id'] as String,
      userId: map['user_id'] as String,
      objectLabel: map['object_label'] as String,
      lemma: map['lemma'] as String,
      content:Map<String, dynamic>.from(map['content'] as Map<String, dynamic>),
      cefrLevel: CEFRLevel.fromJson(map['cefr_level'] as String),
      sceneTags: map['scene_tags'] != null
          ? List<String>.from(map['scene_tags'] as List)
          : null,
      isReviewed: map['is_reviewed'] as bool,
      isOfficial: map['is_official'] as bool,
      generationCount: map['generation_count'] as int,
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

  factory ReviewResponseModel.fromJson(String source) => ReviewResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}


class ReviewPostModel {
  final String cardId;
  final int rating;
  ReviewPostModel({
    required this.cardId,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'card_id': cardId,
      'rating': rating,
    };
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

  factory ReviewStateModel.fromJson(String source) => ReviewStateModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
