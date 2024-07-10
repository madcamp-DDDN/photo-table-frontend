import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart' as AppUser;
import 'home_view.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _controller;
  late Animation<double> _buttonOpacityAnimation;
  bool _showLoginElements = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _buttonOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _showLoginElements = true;
        });
        _controller.forward();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    double getWidth(double x) => x / 430 * size.width;
    double getHeight(double y) => y / 932 * size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Container(
        color: Color(0xFF1E1E1E), // 배경색 설정
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: getWidth(_showLoginElements ? -170 : 22),
              top: getHeight(_showLoginElements ? 401 : 330),
              width: getWidth(271),
              height: getHeight(271),
              child: Image.asset('assets/yellow_gradient.png'),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: getWidth(_showLoginElements ? 324 : 180),
              top: getHeight(_showLoginElements ? 181 : 279),
              width: getWidth(271),
              height: getHeight(271),
              child: Image.asset('assets/blue_gradient.png'),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: getWidth(_showLoginElements ? -135 : 22),
              top: getHeight(_showLoginElements ? 150 : 227),
              width: getWidth(271),
              height: getHeight(271),
              child: Image.asset('assets/pink_gradient.png'),
            ),
            AnimatedPositioned(
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut,
              left: getWidth(_showLoginElements ? 67 : 63),
              top: getHeight(_showLoginElements ? 361 : 382),
              width: getWidth(304),
              height: getHeight(79),
              child: Image.asset('assets/logo.png'),
            ),
            if (_showLoginElements)
              Center(
                child: FadeTransition(
                  opacity: _buttonOpacityAnimation,
                  child: Container(
                    width: getWidth(311),
                    height: getHeight(52),
                    margin: EdgeInsets.only(top: getHeight(462)),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        AppUser.User? user = await _authService.loginWithKakao();
                        if (user != null) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomeView(user: user)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to login')),
                          );
                        }
                      },
                      child: Image.asset('assets/login_button.png', fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}