import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart'; // For handling deep links
import 'dart:async';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // Kakao SDK import
import 'dot.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'models/user_model.dart' as AppUser;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  KakaoSdk.init(nativeAppKey: DotEnvConfig.kakaoNativeAppKey); // Kakao SDK 초기화
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _sub;
  AppUser.User? _user;

  @override
  void initState() {
    super.initState();
    _sub = getUriLinksStream().listen((Uri? uri) {
      if (uri != null) {
        // Handle deep link here
        if (uri.scheme == 'myapp' && uri.host == 'oauth') {
          print("hello");
          final userId = uri.queryParameters['user_id'];
          if (userId != null) {
            setState(() {
              _user = AppUser.User(id: userId, name: ''); // 실제로는 백엔드에서 사용자 정보를 가져와야 합니다.
            });
          }
        }
      }
    }, onError: (err) {
      // Handle error here
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Table',
      home: _user == null ? LoginView() : HomeView(user: _user!),
    );
  }
}