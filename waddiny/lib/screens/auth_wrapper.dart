import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'user_main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Adjust key if needed
    setState(() {
      isLoggedIn = token != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return isLoggedIn! ? const UserMainScreen() : const LoginScreen();
  }
}
