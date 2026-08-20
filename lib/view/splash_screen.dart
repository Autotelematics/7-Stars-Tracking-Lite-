import 'package:autotelematic_new_app/res/apptheme.dart';
import 'package:autotelematic_new_app/res/usersession.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final UserSessions userSessions = UserSessions();

  @override
  void initState() {
    super.initState();
    _initAndGo();
  }

  Future<void> _initAndGo() async {
    // (Optional) Request notification permission for best UX
    // You may move this to login or keep here
    // await FirebaseMessaging.instance.requestPermission();

    // Wait a bit for splash effect, then go!
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      await userSessions.checkUserSession(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Image(image: AssetImage(AppTheme.logoPath)),
        ),
      ),
    );
  }
}
