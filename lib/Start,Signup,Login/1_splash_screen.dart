import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/home');
    });
    return Scaffold(
      backgroundColor: const Color(0xFFECF0F1),
      body: Center(
        child: Image.asset('assets/FiveStarsLaundromat.png', width: 400),
      ),
    );
  }
}
