import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart' as AppUser;
import 'home_view.dart';

class LoginView extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            AppUser.User? user = await _authService.loginWithKakao();
            if (user != null) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeView(user: user)),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to login')),
              );
            }
          },
          child: Text('Login with Kakao'),
        ),
      ),
    );
  }
}