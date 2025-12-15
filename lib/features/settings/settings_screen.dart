import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
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
        subtitle: 'Coaching, workshops, interventions, Gestion, Conception',
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.chocolat.withValues(alpha: 0.08),
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              children: [
                const _SettingsHeroCard(),
                const SizedBox(height: 20),
                ...items.map((item) => _SettingTile(item: item)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeroCard extends StatelessWidget {
  const _SettingsHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [AppColors.chocolat, AppColors.cafe],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.chocolat.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Espace Paramètres',
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Centralisez vos actions communautaires, vos soutiens et vos demandes de services.',
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({required this.item});

  final _SettingItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: item.builder),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.chocolat.withValues(alpha: 0.08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.chocolat.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: AppColors.chocolat),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: AppTextStyles.title),
                      const SizedBox(height: 4),
                      Text(item.subtitle, style: AppTextStyles.small),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
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
