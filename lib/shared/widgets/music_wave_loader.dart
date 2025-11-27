import 'package:flutter/material.dart';
import 'package:conseilbox/config/app_colors.dart';

class MusicWaveLoader extends StatefulWidget {
  const MusicWaveLoader({super.key});

  @override
  _MusicWaveLoaderState createState() => _MusicWaveLoaderState();
}

class _MusicWaveLoaderState extends State<MusicWaveLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(5, (index) {
      final double start = index * 0.1;
      final double end = start + 0.4;
      return Tween<double>(begin: 5.0, end: 30.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: 10,
              height: _animations[index].value,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: AppColors.cafe,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          },
        );
      }),
    );
  }
}
