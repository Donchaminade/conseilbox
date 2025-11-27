import 'package:flutter/material.dart';

import '../../config/app_text_styles.dart';
import 'about_screen.dart';
import 'donate_screen.dart';
import 'service_request_screen.dart';
import 'support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_SettingItem>[
      _SettingItem(
        icon: Icons.info_outline,
        title: 'À propos',
        subtitle: 'Vision, mission et portrait du projet',
        builder: (_) => const AboutScreen(),
      ),
      _SettingItem(
        icon: Icons.local_cafe_outlined,
        title: 'Buy me a coffee',
        subtitle: 'Soutenir financièrement l’équipe',
        builder: (_) => const DonateScreen(),
      ),
      _SettingItem(
        icon: Icons.design_services_outlined,
        title: 'Demander un service',
        subtitle: 'Coaching, workshops, interventions',
        builder: (_) => const ServiceRequestScreen(),
      ),
      _SettingItem(
        icon: Icons.support_agent,
        title: 'Support & contact',
        subtitle: 'Email, WhatsApp, FAQ',
        builder: (_) => const SupportScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: Colors.brown.withValues(alpha: 0.12),
                child: Icon(item.icon, color: Colors.brown),
              ),
              title: Text(item.title, style: AppTextStyles.title),
              subtitle: Text(item.subtitle, style: AppTextStyles.small),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: item.builder),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SettingItem {
  _SettingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final WidgetBuilder builder;
}
