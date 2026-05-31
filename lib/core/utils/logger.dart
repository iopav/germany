import 'package:logger/logger.dart';

class AppLogger {
  // 私有构造函数，防止被误实例化
  AppLogger._();

  // 配置 Logger 的输出样式
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 不打印方法堆栈（保持控制台清爽）
      errorMethodCount: 5, // 只有 Error 时才打印前 5 层堆栈，方便找 Bug
      lineLength: 80, // 分割线长度
      colors: true, // 开启控制台颜色
      printTime: true, // 打印时间戳
    ),
  );

  /// 调试日志 (Debug)：用于开发阶段查看变量值、临时逻辑
  static void d(dynamic message) {
    _logger.d(message);
  }

  /// 信息日志 (Info)：用于记录重要的系统流程（如：用户登录成功、路由跳转）
  static void i(dynamic message) {
    _logger.i(message);
  }

  ///  警告日志 (Warning)：用于记录非致命错误（如：网络重试、Token 即将过期）
  static void w(dynamic message) {
    _logger.w(message);
  }

  ///  错误日志 (Error)：用于记录极其严重的崩溃或 try-catch 捕获的异常
  /// 可以同时传入 error 对象和 stackTrace 堆栈追踪
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
    

  }
}