import 'package:flutter/material.dart';

class AppTheme {
  // 定义应用的主色调
  static const primaryColor = Colors.deepPurple;
  static const secondaryColor = Colors.amber;

  // 组装成全局的主题数据 (ThemeData)
  static ThemeData get lightTheme {
    return ThemeData(
      // 1. 基础配色方案
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        secondary: secondaryColor,
      ),
      useMaterial3: true, // 开启谷歌最新的 UI 设计规范

      // 2. 全局 AppBar (顶部导航栏) 样式
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white, // 文字颜色
        elevation: 0, // 去掉阴影
      ),

      // 3. 全局 ElevatedButton (主按钮) 样式
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // 全局统一的按钮圆角
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),

      // 4. 全局卡片 (Card) 样式
      cardTheme: const CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
    );
  }
}