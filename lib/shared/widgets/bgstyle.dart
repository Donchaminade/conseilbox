import 'dart:math';
import 'package:flutter/material.dart';
import 'package:conseilbox/config/app_colors.dart';

class GeometricBackground extends StatelessWidget {
  const GeometricBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.blanc, // Ajout d'une couleur de fond solide
      child: Stack(
        children: [
          // Ajout d'un dégradé subtil en arrière-plan
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.chocolat.withOpacity(0.05),
                  AppColors.cafe.withOpacity(0.05),
                ],
              ),
            ),
          ),
          Positioned(
            top: -120,
            left: -120,
            child: Transform.rotate(
              angle: -pi / 4,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.cafe.withOpacity(
                      0.2), // Opacité réduite
                  borderRadius: BorderRadius.circular(60),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: CircleAvatar(
              radius: 180,
              backgroundColor: AppColors.chocolat.withOpacity(
                  0.1), // Opacité réduite
            ),
          ),
          Positioned(
            top: 200,
            right: -50,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.cafe
                  .withOpacity(0.15), // Opacité réduite
            ),
          ),
          Positioned(
            top: 100,
            left: -40,
            child: Transform.rotate(
              angle: pi / 6,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.chocolat.withOpacity(0.3), // Opacité réduite
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -40,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.cafe
                  .withOpacity(0.2), // Opacité réduite
            ),
          ),
        ],
      ),
    );
  }
}