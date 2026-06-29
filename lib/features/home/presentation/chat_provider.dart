import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/presentation/auth_provider.dart';
import '../../scenes/presentation/history_provider.dart';
import '../data/impl/home_impl.dart';
import '../data/models/home_models.dart';
import '../domain/entity/home_stats_entity.dart';
import '../domain/interface/home_interface.dart';

enum ChatMessageKind { userText, scenePending, sceneReady, error }

class ChatMessage {
  final String id;
  final ChatMessageKind kind;
  final String text;
  final String prompt;
  final SceneEntity? scene;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.kind,
    required this.text,
    required this.prompt,
    required this.createdAt,
    this.scene,
  });

  bool get isUser => kind == ChatMessageKind.userText;

  bool get isPending => kind == ChatMessageKind.scenePending;

  bool get isReady => kind == ChatMessageKind.sceneReady && scene != null;

  ChatMessage copyWith({
    ChatMessageKind? kind,
    String? text,
    String? prompt,
    SceneEntity? scene,
    DateTime? createdAt,
  }) {
    return ChatMessage(
      id: id,
      kind: kind ?? this.kind,
      text: text ?? this.text,
      prompt: prompt ?? this.prompt,
      scene: scene ?? this.scene,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind.name,
      'text': text,
      'prompt': prompt,
      'created_at': createdAt.toIso8601String(),
      if (scene != null) 'scene': scene!.raw,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final rawKind = json['kind']?.toString();
    final kind = ChatMessageKind.values.firstWhere(
      (item) => item.name == rawKind,
      orElse: () => ChatMessageKind.userText,
    );
    final rawScene = json['scene'];
    SceneEntity? scene;
    if (rawScene is Map) {
      scene = SceneResponseModel.fromJson(
        Map<String, dynamic>.from(rawScene),
      ).toEntity();
    }

    return ChatMessage(
      id: json['id']?.toString() ?? _newMessageId(),
      kind: kind,
      text: json['text']?.toString() ?? '',
      prompt: json['prompt']?.toString() ?? '',
      scene: scene,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}

class ChatState {
  final List<ChatMessage> messages;

  const ChatState({required this.messages});

  const ChatState.empty() : messages = const [];

  bool get hasPending => messages.any((message) => message.isPending);

  ChatState copyWith({List<ChatMessage>? messages}) {
    return ChatState(messages: messages ?? this.messages);
  }
}

class ChatMessageCache {
  ChatMessageCache._();

  static const int _maxMessages = 80;

  static String _key(String userId) => 'chat_messages_v1_$userId';

  static Future<List<ChatMessage>> load(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_key(userId)) ?? const <String>[];
    return encoded
        .map((item) {
          try {
            final decoded = jsonDecode(item);
            if (decoded is Map) {
              return ChatMessage.fromJson(Map<String, dynamic>.from(decoded));
            }
          } catch (_) {}
          return null;
        })
        .whereType<ChatMessage>()
        .toList();
  }

  static Future<void> save(String userId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final capped = messages.length > _maxMessages
        ? messages.sublist(messages.length - _maxMessages)
        : messages;
    await prefs.setStringList(
      _key(userId),
      capped.map((message) => jsonEncode(message.toJson())).toList(),
    );
  }
}

class ChatNotifier extends AsyncNotifier<ChatState> {
  String _userId = 'anonymous';

  @override
  Future<ChatState> build() async {
    final user = ref.watch(authProvider).value;
    _userId = user?.id.trim().isNotEmpty == true ? user!.id : 'anonymous';
    final messages = _dedupeMessages(await ChatMessageCache.load(_userId));
    await ChatMessageCache.save(_userId, messages);
    return ChatState(messages: messages);
  }

  Future<void> sendPrompt(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final current = state.value ?? const ChatState.empty();
    final hasSamePending = current.messages.any(
      (message) => message.isPending && message.prompt.trim() == trimmed,
    );
    if (hasSamePending) {
      return;
    }

    final userMessage = ChatMessage(
      id: _newMessageId(),
      kind: ChatMessageKind.userText,
      text: trimmed,
      prompt: trimmed,
      createdAt: DateTime.now(),
    );
    final pendingMessage = ChatMessage(
      id: _newMessageId(),
      kind: ChatMessageKind.scenePending,
      text: 'Generating your scene. You can keep using the app.',
      prompt: trimmed,
      createdAt: DateTime.now(),
    );

    final nextMessages = _dedupeMessages([
      ...current.messages,
      userMessage,
      pendingMessage,
    ]);
    state = AsyncData(current.copyWith(messages: nextMessages));
    await _persist(nextMessages);

    unawaited(_generateSceneForPending(pendingMessage.id, trimmed));
  }

  Future<void> retry(ChatMessage message) async {
    final prompt = message.prompt.trim();
    if (prompt.isEmpty) {
      return;
    }

    final current = state.value ?? const ChatState.empty();
    final pending = ChatMessage(
      id: _newMessageId(),
      kind: ChatMessageKind.scenePending,
      text: 'Generating your scene. You can keep using the app.',
      prompt: prompt,
      createdAt: DateTime.now(),
    );
    final nextMessages = _dedupeMessages([...current.messages, pending]);
    state = AsyncData(current.copyWith(messages: nextMessages));
    await _persist(nextMessages);

    unawaited(_generateSceneForPending(pending.id, prompt));
  }

  Future<void> cleanupDuplicates() async {
    final current = state.value ?? const ChatState.empty();
    final messages = _dedupeMessages(current.messages);
    if (messages.length == current.messages.length) {
      return;
    }
    state = AsyncData(current.copyWith(messages: messages));
    await _persist(messages);
  }

  Future<void> _generateSceneForPending(String pendingId, String prompt) async {
    try {
      final HomeInterface homeInterface = ref.read(homeInterfaceProvider);
      final scene = await homeInterface.createSceneFromText(prompt: prompt);
      unawaited(ref.read(sceneHistoryProvider.notifier).refresh());
      await _completePendingScene(
        pendingId: pendingId,
        prompt: prompt,
        scene: scene,
      );
    } catch (e) {
      final message = e.toString().replaceAll('Exception: ', '');
      await _replaceMessage(
        pendingId,
        (item) => item.copyWith(
          kind: ChatMessageKind.error,
          text: message.isEmpty ? 'Scene generation failed.' : message,
        ),
      );
    }
  }

  Future<void> _replaceMessage(
    String messageId,
    ChatMessage Function(ChatMessage message) replace,
  ) async {
    final current = state.value ?? const ChatState.empty();
    final messages = _dedupeMessages(
      current.messages
          .map(
            (message) => message.id == messageId ? replace(message) : message,
          )
          .toList(),
    );
    state = AsyncData(current.copyWith(messages: messages));
    await _persist(messages);
  }

  Future<void> _completePendingScene({
    required String pendingId,
    required String prompt,
    required SceneEntity scene,
  }) async {
    final current = state.value ?? const ChatState.empty();
    final sceneId = scene.id.trim();
    final normalizedPrompt = prompt.trim();
    final readyMessage = ChatMessage(
      id: pendingId,
      kind: ChatMessageKind.sceneReady,
      text: _sceneSummary(scene),
      prompt: normalizedPrompt,
      scene: scene,
      createdAt: DateTime.now(),
    );

    var replaced = false;
    final nextMessages = <ChatMessage>[];
    for (final message in current.messages) {
      final messageSceneId = message.scene?.id.trim() ?? '';
      final isSameSceneReady =
          message.kind == ChatMessageKind.sceneReady &&
          sceneId.isNotEmpty &&
          messageSceneId == sceneId;
      if (isSameSceneReady) {
        continue;
      }

      final isMatchingPending =
          message.isPending &&
          (message.id == pendingId ||
              message.prompt.trim() == normalizedPrompt);
      if (isMatchingPending) {
        if (!replaced) {
          nextMessages.add(readyMessage.copyWith(createdAt: message.createdAt));
          replaced = true;
        }
        continue;
      }

      nextMessages.add(message);
    }

    if (!replaced) {
      nextMessages.add(readyMessage);
    }

    final messages = _dedupeMessages(nextMessages);
    state = AsyncData(current.copyWith(messages: messages));
    await _persist(messages);
  }

  Future<void> _persist(List<ChatMessage> messages) {
    return ChatMessageCache.save(_userId, messages);
  }

  String _sceneSummary(SceneEntity scene) {
    final tags = <String>{
      for (final card in scene.cards)
        ...card.sceneTags.where((tag) => tag.trim().isNotEmpty),
    }.take(3).join(' | ');
    if (tags.isNotEmpty) {
      return tags;
    }
    if (scene.cards.isNotEmpty) {
      return '${scene.cards.length} vocabulary cards generated';
    }
    return 'Scene is ready';
  }

  List<ChatMessage> _dedupeMessages(List<ChatMessage> messages) {
    final seenSceneIds = <String>{};
    final readyPrompts = <String>{};
    final deduped = <ChatMessage>[];
    for (final message in messages.reversed) {
      final sceneId = message.scene?.id.trim() ?? '';
      if (message.kind == ChatMessageKind.sceneReady && sceneId.isNotEmpty) {
        if (!seenSceneIds.add(sceneId)) {
          continue;
        }
        final prompt = message.prompt.trim();
        if (prompt.isNotEmpty) {
          readyPrompts.add(prompt);
        }
      }
      if (message.isPending && readyPrompts.contains(message.prompt.trim())) {
        continue;
      }
      deduped.add(message);
    }
    return deduped.reversed.toList();
  }
}

String _newMessageId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

final chatProvider = AsyncNotifierProvider<ChatNotifier, ChatState>(
  ChatNotifier.new,
);
