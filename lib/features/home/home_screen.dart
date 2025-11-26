import 'package:flutter/material.dart';
import '../../config/app_text_styles.dart';
import '../../core/widgets/custom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    Widget body;
    switch (index) {
      case 1:
        body = const Center(child: Text('Liste complète des conseils'));
        break;
      case 2:
        body = const Center(child: Text('Formulaire pour ajouter un conseil'));
        break;
      case 3:
        body = const Center(child: Text('Profil de l\'utilisateur'));
        break;
      default:
        body = ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nom Auteur #\$i', style: AppTextStyles.title),
                    const SizedBox(height: 6),
                    Text('Un conseil inspirant pour vous aider aujourd\'hui. Voici un extrait...', style: AppTextStyles.body),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Togo • 2025-11-26', style: AppTextStyles.small),
                        Row(children: const [Icon(Icons.share), SizedBox(width:8), Icon(Icons.favorite_border)])
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ConseilBox'),
      ),
      body: body,
      bottomNavigationBar: CustomNavbar(
        currentIndex: index,
        onTap: (value) => setState(() => index = value),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => index = 2);
        },
        backgroundColor: const Color(0xFF7B3F00),
        child: const Icon(Icons.add),
      ),
    );
  }
}