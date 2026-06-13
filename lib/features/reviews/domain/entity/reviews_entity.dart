// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:germany/core/emus/app_enums.dart';

class ReviewEntity {
  final String id;
  final String sceneId;
  final String userId;
  final String objectLabel;
  final String lemma; //answer
  final Map<String, dynamic>? content;
  final CEFRLevel cefrLevel;
  final List<String>? sceneTags;
  final bool isReviewed;
  final bool isOfficial;
  final int generationCount;
  final DateTime? createdAt;

  ReviewEntity({
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

  factory ReviewEntity.fromMap(Map<String, dynamic> map) {
    return ReviewEntity(
      id: map['id'] as String,
      sceneId: map['sceneId'] as String,
      userId: map['userId'] as String,
      objectLabel: map['objectLabel'] as String,
      lemma: map['lemma'] as String,
      content: map['content'] != null
          ? Map<String, dynamic>.from(map['content'] as Map<String, dynamic>)
          : null,
      cefrLevel: CEFRLevel.fromJson(map['cefrLevel'] as String),
      sceneTags: map['sceneTags'] != null
          ? List<String>.from(map['sceneTags'] as List<String>)
          : null,
      isReviewed: map['isReviewed'] as bool,
      isOfficial: map['isOfficial'] as bool,
      generationCount: map['generationCount'] as int,
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReviewEntity.fromJson(String source) =>
      ReviewEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
