import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:conseilbox/config/app_colors.dart';
import 'package:conseilbox/features/home/home_screen.dart'; // Import pour HomeScreen
import 'package:conseilbox/features/login/login_screen.dart';
import 'package:conseilbox/shared/widgets/bgstyle.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import pour SharedPreferences
import 'package:conseilbox/utils/constants.dart'; // Import pour Constants

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve:
            const Interval(0.0, 0.3, curve: Curves.easeIn), // Fade in quickly
      ),
    );

    

        _rotationAnimation = TweenSequence<double>([

    

          TweenSequenceItem(

    

            tween: Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeOutCubic)),

    

            weight: 0.5, // First half of the animation: 0 to 180 degrees

    

          ),

    

          TweenSequenceItem(

    

            tween: Tween<double>(begin: 0.5, end: 0.0).chain(CurveTween(curve: Curves.easeInCubic)),

    

            weight: 0.5, // Second half of the animation: 180 to 0 degrees

    

          ),

    

        ]).animate(_controller);

    _controller.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
        await Future.delayed(const Duration(seconds: 5)); // Keep splash screen visible for animation

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString(Constants.authTokenKey);

    if (authToken == Constants.correctLoginCode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
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
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RotationTransition(
                    turns: _rotationAnimation,
                    child: CustomPaint(
                      painter: _OpenCirclePainter(
                        borderColor: AppColors.cafe,
                        borderWidth: 6,
                      ),
                      size: const Size(250, 250), // Specify the size of the canvas
                    ),
                  ),
                  Image.asset('assets/images/logo.png', width: 200),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for an open circle
class _OpenCirclePainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double startAngle;
  final double sweepAngle;

  _OpenCirclePainter({
    required this.borderColor,
    required this.borderWidth,
    this.startAngle = -math.pi / 2, // Start from top center
    this.sweepAngle = math.pi * 1.5, // Draw 270 degrees
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Optional: round caps for the open ends

    final rect = Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2);

    canvas.drawArc(
      rect,
      startAngle, // Start angle (e.g., -math.pi / 2 for top)
      sweepAngle, // Sweep angle (e.g., math.pi * 1.5 for 270 degrees)
      false, // UseCenter
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false; // For simplicity, assume it doesn't need repaint
  }
}
