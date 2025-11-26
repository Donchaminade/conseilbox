import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.cafe,
      selectedItemColor: AppColors.blanc,
      unselectedItemColor: AppColors.chocolat,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Accueil",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb),
          label: "Conseils",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add),
          label: "Ajouter",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Profil",
        ),
      ],
    );
  }
}