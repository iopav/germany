class ApiConstants {
  ApiConstants._();

  // 1. 基础配置
  static const String baseDomain = 'https://api.mosaica.at';
  static const String apiPrefix = '/api/v1';
  static const String baseUrl = '$baseDomain$apiPrefix';

  // 2. HTTP Headers
  static const String headerContentType = 'Content-Type';
  static const String headerAccept = 'Accept';
  static const String headerAuthorization = 'Authorization';
  static const String jsonFormat = 'application/json';
  static const String multipartFormat = 'multipart/form-data';

  // 3. 通用参数键名
  static const String keyToken = 'access_token';
  static const String keyFile = 'file';

  // ==========================================
  // 4. 路由枚举 (Endpoints)
  // ==========================================

  // --- 认证模块 (Auth) ---
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authMe = '/auth/me';
  static const String authSendVerification = '/auth/send-verification';
  static const String authVerifyEmail = '/auth/verify-email';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authResetPassword = '/auth/reset-password';


  // --- 场景模块 (Scenes) ---
  static const String scenesBase = '/scenes/'; //post提交生成请求，get获取列表
  static const String scenesGenerateText = '/scenes/generate-text';
  static String sceneDetail(String id) => '/scenes/$id'; 
  static String deleteScene(String id) => '/scenes/$id';

  // --- 词卡模块 (Cards) ---
  static const String cardsDue = '/cards/due'; //待复习的词卡列表
  static const String cardsList = '/cards/';
  static String cardDetail(String id) => '/cards/$id';

  // --- 复习模块 (Reviews) ---
  static const String reviewsSubmit = '/reviews/'; //post提交复习结果
  static const String reviewsStats = '/reviews/stats'; //get获取复习统计

  // 5. 超时时间设置
  static const int defaultTimeoutSeconds = 15;
  static const int uploadTimeoutSeconds = 60; // 图像生成较慢
  static const int generateTextTimeoutSeconds = 90; // 纯文本生成最慢

  // white list
  static const List<String> whiteList = [
    authLogin,
    authRegister,
    authSendVerification,
    authVerifyEmail,
    authForgotPassword,
    authResetPassword,
  ];
}