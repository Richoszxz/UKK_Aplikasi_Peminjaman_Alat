import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  Future<void> _cekSession() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');

    if (!mounted) return;

    if (role != null) {
      // ✅ Sudah login
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // ❌ Belum login
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _cekSession();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset('assets/images/logo_splash_screen.png'),
    );
  }
}