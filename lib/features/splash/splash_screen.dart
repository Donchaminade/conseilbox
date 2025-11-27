import 'dart:async';
import 'package:flutter/material.dart';
import 'package:conseilbox/config/app_colors.dart';
import 'package:conseilbox/features/login/login_screen.dart';
import 'package:conseilbox/shared/widgets/bgstyle.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _zoomAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _zoomAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastLinearToSlowEaseIn,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutExpo,
      ),
    );

    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          const GeometricBackground(),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                RotationTransition(
                  turns: _rotationAnimation,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            AppColors.cafe, //couleur du cercle autour du logo
                        width: 6,
                      ),
                    ),
                  ),
                ),
                ScaleTransition(
                  scale: _zoomAnimation, //animation du logo
                  child: Image.asset('assets/images/logo.png', width: 200),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
