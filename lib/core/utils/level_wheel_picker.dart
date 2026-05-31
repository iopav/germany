import 'dart:async';
import 'package:flutter/material.dart';

class LevelWheelPicker extends StatefulWidget {
  final List<String> levels;
  final String initialLevel;
  final Function(String) onLevelChanged;

  const LevelWheelPicker({
    super.key,
    required this.levels,
    required this.initialLevel,
    required this.onLevelChanged,
  });

  @override
  State<LevelWheelPicker> createState() => _LevelWheelPickerState();
}

class _LevelWheelPickerState extends State<LevelWheelPicker> {
  bool _isExpanded = false;
  late String _currentLevel;
  late FixedExtentScrollController _scrollController;
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.initialLevel;
    int initialIndex = widget.levels.indexOf(_currentLevel);
    if (initialIndex == -1) initialIndex = 0;
    _scrollController = FixedExtentScrollController(initialItem: initialIndex);
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    return Container(
      constraints: const BoxConstraints(
        minWidth: 70,  // 最小容纳下 A1 文本
        maxWidth: 90,  // 最大不超过 90，防止在 iPad 上被拉伸得很奇怪
      ),
     
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 确保收起时不占用额外高度
        crossAxisAlignment: CrossAxisAlignment.stretch, // 让内部组件填满 constraints 允许的宽度
        children: [
          // 1. 顶部的触发按钮
          GestureDetector(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
              if (_isExpanded) {
                final index = widget.levels.indexOf(_currentLevel);
                if (index != -1 && _scrollController.hasClients) {
                  _scrollController.jumpToItem(index);
                }
              }
            },
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isExpanded ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _currentLevel,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: _isExpanded ? Colors.blue : Colors.black87,
                ),
              ),
            ),
          ),

          // 2. 下方展开的滚轮区
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            height: _isExpanded ? 120 : 0, // 高度仅控制内部滚轮区
            child: _isExpanded
                ? ListWheelScrollView.useDelegate(
                    controller: _scrollController,
                    itemExtent: 40,
                    physics: const FixedExtentScrollPhysics(),
                    overAndUnderCenterOpacity: 0.3, // 让没选中的上下项变淡
                    onSelectedItemChanged: (index) {
                      setState(() => _currentLevel = widget.levels[index]);
                      widget.onLevelChanged(_currentLevel);
                      
                      _closeTimer?.cancel();
                      _closeTimer = Timer(const Duration(milliseconds: 500), () {
                        if (mounted) setState(() => _isExpanded = false);
                      });
                    },
                    childDelegate: ListWheelChildBuilderDelegate(
                      childCount: widget.levels.length,
                      builder: (context, index) {
                        final isSelected = _currentLevel == widget.levels[index];
                        return Center(
                          child: Text(
                            widget.levels[index],
                            style: TextStyle(
                              fontSize: isSelected ? 20 : 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.blue : Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}