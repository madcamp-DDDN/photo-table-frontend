import 'package:flutter_dotenv/flutter_dotenv.dart';

class DotEnvConfig {
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000';
  static String get kakaoBackendRedirectUri => dotenv.env['KAKAO_REDIRECT_URI'] ?? 'http://localhost:5000/api/auth/kakao/callback';
  static String get kakaoFrontendRedirectUri => dotenv.env['KAKAO_FRONTEND_REDIRECT_URI'] ?? 'myapp://oauth';
  static String get kakaoRestApiKey => dotenv.env['KAKAO_REST_API_KEY'] ?? '';
  static String get kakaoNativeAppKey => dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '';
}