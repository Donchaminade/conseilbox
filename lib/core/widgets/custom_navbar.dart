import 'package:flutter/material.dart';
import '../../config/app_colors.dart';

class CustomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavbar(
      {super.key, required this.currentIndex, required this.onTap});

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
          icon: Icon(Icons.home_outlined),
          label: "Accueil",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons
              .lightbulb), //     [interpreter_mode_sharp...> (micro a cote de icone de usersgroup)]
          label: "Conseils",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.public),
          label: "Tech pub",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favoris",
        ),
      ],
    );
  }
}
