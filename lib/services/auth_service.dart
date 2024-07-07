import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../dot.dart';  // Import the dot.dart file
import 'api_service.dart';
import '../models/user_model.dart' as AppUser;

class AuthService {
  Future<AppUser.User?> loginWithKakao() async {
    try {
      final backendRedirectUri = DotEnvConfig.kakaoBackendRedirectUri;
      final frontendRedirectUri = DotEnvConfig.kakaoFrontendRedirectUri;

      print('Starting Kakao login process');
      print('Backend Redirect URI: $backendRedirectUri');
      print('Frontend Redirect URI: $frontendRedirectUri');

      final authCode = await AuthCodeClient.instance.authorize(
        clientId: DotEnvConfig.kakaoRestApiKey, // Use REST API Key as clientId
        redirectUri: backendRedirectUri,
        scopes: ['profile_nickname', 'profile_image'], // Request necessary scopes
      );

      print('Received authorization code: $authCode');

      // Simulate backend handling and returning the frontend redirect URI
      // In a real application, this would be handled by the backend
      final uri = Uri.parse(frontendRedirectUri);
      final userId = uri.queryParameters['user_id'];

      if (userId != null) {
        print('Successfully logged in with Kakao, user_id: $userId');
        return AppUser.User(id: userId, name: '');  // 실제로는 백엔드에서 사용자의 정보를 가져와야 합니다.
      } else {
        print('Failed to retrieve user_id from frontend redirect URI');
        return null;
      }
    } catch (error) {
      print('Failed to login with Kakao: $error');
      return null;
    }
  }
}