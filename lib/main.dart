import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart'; // For handling deep links
import 'dart:async';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; // Kakao SDK import
import 'dot.dart';
import 'views/login_view.dart';
import 'views/home_view.dart';
import 'views/friend_view.dart';
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
              _user = AppUser.User(
                id: userId,
                name: '', // 빈 문자열로 초기화
                profileImageUrl: '', // 빈 문자열로 초기화
              );
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
      debugShowCheckedModeBanner: false,
      title: 'Photo Table',
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // 배경 이미지 설정
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.transparent, // Scaffold 배경색을 투명으로 설정
          body: _user == null ? LoginView() : MainTabView(user: _user!),
        ),
      ),
    );
  }
}

class MainTabView extends StatefulWidget {
  final AppUser.User user;

  MainTabView({required this.user});

  @override
  _MainTabViewState createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions(AppUser.User user) => <Widget>[
    HomeView(user: user),
    FriendView(user: user),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent, // 배경색을 #212024로 지정
      body: Center(
        child: _widgetOptions(widget.user).elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0x80212024),
        // backgroundColor: Colors.transparent,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Friends'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFFEB702),
        unselectedItemColor: Color(0xFF8c8c8c),
        onTap: _onItemTapped,
      ),
    );
  }
}