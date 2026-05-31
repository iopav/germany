import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// ==========================================
// 1. 数据模型 (支持多句文本)
// ==========================================
class PolygonItem {
  final List<Offset> normalizedPoints;
  final Map<String, String> localizedNames;
  final List<String> sentences; // 核心：多句文本数组

  PolygonItem({
    required this.normalizedPoints,
    required this.localizedNames,
    required this.sentences,
  });

  PolygonItem copyWith({
    List<Offset>? normalizedPoints,
    Map<String, String>? localizedNames,
    List<String>? sentences,
  }) {
    return PolygonItem(
      normalizedPoints: normalizedPoints ?? this.normalizedPoints,
      localizedNames: localizedNames ?? this.localizedNames,
      sentences: sentences ?? this.sentences,
    );
  }
}

// ==========================================
// 2. 状态类 (包含歌词交互所需的所有状态)
// ==========================================
class ScannerState {
  final XFile? image;
  final bool isAnalyzing;
  final List<PolygonItem> polygons;
  final PolygonItem? selectedPolygon;
  
  // 歌词交互专属状态
  final bool showSentences; 
  final int activeSentenceIndex;

  ScannerState({
    this.image,
    this.isAnalyzing = false,
    this.polygons = const [],
    this.selectedPolygon,
    this.showSentences = false,
    this.activeSentenceIndex = 0,
  });

  ScannerState copyWith({
    XFile? image,
    bool? isAnalyzing,
    List<PolygonItem>? polygons,
    PolygonItem? selectedPolygon,
    bool clearSelection = false,
    bool? showSentences,
    int? activeSentenceIndex,
  }) {
    return ScannerState(
      image: image ?? this.image,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      polygons: polygons ?? this.polygons,
      selectedPolygon: clearSelection ? null : (selectedPolygon ?? this.selectedPolygon),
      showSentences: showSentences ?? this.showSentences,
      activeSentenceIndex: activeSentenceIndex ?? this.activeSentenceIndex,
    );
  }
}

// ==========================================
// 3. 控制器核心逻辑 (Notifier)
// ==========================================
class ScannerNotifier extends Notifier<ScannerState> {
  final ImagePicker _picker = ImagePicker();

  @override
  ScannerState build() {
    return ScannerState();
  }

  // --- 基础功能：选图与识别 ---
  Future<void> pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      state = state.copyWith(image: pickedFile, isAnalyzing: true, polygons: [], clearSelection: true);

      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

      final toyData = [
        PolygonItem(
          normalizedPoints: const [Offset(0.2, 0.2), Offset(0.8, 0.2), Offset(0.5, 0.7)],
          localizedNames: {'A1': 'der Hund (狗)', 'A2': 'das Haustier (宠物)', 'B2': 'der Canidae (犬科)'},
          sentences: ['Das ist ein treuer Hund.', 'Er hat ein sehr weiches Fell.', 'Jeden Tag spielt er im Garten.'],
        ),
        PolygonItem(
          normalizedPoints: const [Offset(0.0, 0.7), Offset(1.0, 0.7), Offset(1.0, 1.0), Offset(0.0, 1.0)],
          localizedNames: {'A1': 'das Gras (草)', 'B1': 'der Rasen (草坪)', 'C1': 'die Grünfläche (绿地)'},
          sentences: ['Der Hund sitzt auf dem grünen Rasen.', 'Das Gras wächst im Frühling sehr schnell.'],
        ),
      ];

      state = state.copyWith(isAnalyzing: false, polygons: toyData);
    }
  }

  // 点击蒙版时：重置歌词状态
  void selectPolygon(PolygonItem item) {
    state = state.copyWith(
      selectedPolygon: item,
      showSentences: false, // 默认收起
      activeSentenceIndex: 0, // 默认高亮第一句
    );
  }

  // --- 歌词 UI 交互功能 ---
  void toggleSentences() {
    state = state.copyWith(showSentences: !state.showSentences);
  }

  void setActiveSentence(int index) {
    state = state.copyWith(activeSentenceIndex: index);
  }

  // ==========================================
  // 🎯 核心 AI 魔法：你一直找的这三个方法都在这里！
  // ==========================================

  // 魔法 1：重新生成【单句】
  Future<void> regenerateSentence(int sentenceIndex) async {
    final currentPolygon = state.selectedPolygon;
    if (currentPolygon == null) return;

    // 1. 制造加载状态
    final newSentences = List<String>.from(currentPolygon.sentences);
    newSentences[sentenceIndex] = "⏳ AI 正在重写此句...";
    _updatePolygonInState(currentPolygon, currentPolygon.copyWith(sentences: newSentences));

    // 2. 模拟大模型请求
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. 替换新句子
    newSentences[sentenceIndex] = "✨ (单句重写) Er springt fröhlich hin und her.";
    _updatePolygonInState(currentPolygon, currentPolygon.copyWith(sentences: newSentences));
  }

  // 魔法 2：从此往下【全部重写】
  Future<void> regenerateFrom(int startIndex) async {
    final currentPolygon = state.selectedPolygon;
    if (currentPolygon == null) return;

    final newSentences = List<String>.from(currentPolygon.sentences);
    
    // 1. 制造加载状态：把后面的全部变成沙漏
    for (int i = startIndex; i < newSentences.length; i++) {
      newSentences[i] = "⏳ AI 正在结合上下文延展剧情...";
    }
    _updatePolygonInState(currentPolygon, currentPolygon.copyWith(sentences: newSentences));

    // 2. 模拟大模型请求
    await Future.delayed(const Duration(seconds: 2));

    // 3. 替换新剧情
    for (int i = startIndex; i < newSentences.length; i++) {
      newSentences[i] = "✨ (全新剧情) 延展故事第 ${i + 1} 句。";
    }
    _updatePolygonInState(currentPolygon, currentPolygon.copyWith(sentences: newSentences));
  }

  // 内部辅助方法：负责把修改后的局部数据，安全地存回全局仓库
  void _updatePolygonInState(PolygonItem oldItem, PolygonItem newItem) {
    final newPolygons = state.polygons.map((p) => p == oldItem ? newItem : p).toList();
    state = state.copyWith(
      polygons: newPolygons,
      selectedPolygon: newItem, // 保持选中状态不掉
    );
  }
}

// ==========================================
// 4. 暴露给外部的 Provider
// ==========================================
final scannerProvider = NotifierProvider<ScannerNotifier, ScannerState>(() {
  return ScannerNotifier();
});