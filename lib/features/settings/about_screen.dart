import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/app_colors.dart';
import '../../config/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final socials = [
      (
        Icons.business_center,
        'LinkedIn',
        'https://www.linkedin.com/in/ireneamedji/'
      ),
      (
        Icons.play_circle_outline,
        'YouTube',
        'https://youtube.com/@ireneamedji?si=cj0MALV7wx0_0Pul'
      ),
      (Icons.menu_book_outlined, 'Medium', 'https://medium.com/@ireneamedji'),
      (
        Icons.camera_alt_outlined,
        'Instagram',
        'https://www.instagram.com/ireneamedji?igsh=MTdpYmx3Z3NvdzQ1MA=='
      ),
      (
        Icons.videocam_outlined,
        'TikTok',
        'https://www.tiktok.com/@ireneamedji?_r=1&_t=ZM-92IP6QXFgT5'
      ),
      (Icons.flag_circle, 'X', 'https://x.com/IAmedji'),
      (
        Icons.facebook,
        'Facebook',
        'https://www.facebook.com/profile.php?id=100089122070484'
      ),
      (Icons.hub, 'Github', 'https://github.com/IrouKaizen'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('À propos'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/kaizen.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.65),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ConseilBox',
                  style: AppTextStyles.title.copyWith(
                    color: Colors.white,
                    fontSize: 32,
                  ),
                ),
                const SizedBox(height: 12),
                const _NarrativeCard(),
                const SizedBox(height: 32),
                const Center(child: _FounderCard()),
                const SizedBox(height: 32),
                Text(
                  'Réseaux sociaux',
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final social in socials)
                      ActionChip(
                        avatar: Icon(
                          social.$1,
                          color: AppColors.blanc,
                          size: 18,
                        ),
                        label: Text(
                          social.$2,
                          style: const TextStyle(color: AppColors.blanc),
                        ),
                        backgroundColor:
                            AppColors.chocolat.withValues(alpha: 0.4),
                        onPressed: () => _openLink(social.$3),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _NarrativeCard extends StatelessWidget {
  const _NarrativeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plateforme communautaire',
            style: AppTextStyles.title.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'ConseilBox met en lumière les parcours, conseils et idées venues des quatre coins de l’Afrique créative. '
            'Chaque témoignage est modéré par l’équipe Kaizen afin de garantir authenticité, bienveillance et transmission. '
            'Le projet vise à connecter les voix locales, inspirer les diasporas et faciliter l’entraide.',
            style: AppTextStyles.body.copyWith(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Fonctionnalités clés :',
            style: AppTextStyles.body.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _Bullet(text: 'Fil éditorial avec carrousel de publicités tech.'),
              _Bullet(
                  text:
                      'Soumission de conseils en un clic, suivi des statuts.'),
              _Bullet(
                  text:
                      'Favoris, partages sociaux et espace pubs contextualisé.'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FounderCard extends StatelessWidget {
  const _FounderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/irokou.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Irene Amedji',
            style: AppTextStyles.title.copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Project Manager • Quantum Enthusiast\nCommunity Manager',
            textAlign: TextAlign.center,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Colors.white)),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// import '../../config/app_colors.dart';
// import '../../config/app_text_styles.dart';

// class AboutScreen extends StatelessWidget {
//   const AboutScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final socials = [
//       (Icons.business_center, 'LinkedIn'),
//       (Icons.play_circle_outline, 'YouTube'),
//       (Icons.menu_book_outlined, 'Medium'),
//       (Icons.camera_alt_outlined, 'Instagram'),
//       (Icons.videocam_outlined, 'TikTok'),
//     ];

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('À propos'),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/images/kaizen.png',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned.fill(
//             child: Container(
//               color: Colors.black.withValues(alpha: 0.65),
//             ),
//           ),
//           SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'ConseilBox',
//                   style: AppTextStyles.title.copyWith(
//                     color: Colors.white,
//                     fontSize: 32,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 const _NarrativeCard(),
//                 const SizedBox(height: 32),
//                 const Center(child: _FounderCard()),
//                 const SizedBox(height: 32),
//                 Text(
//                   'Réseaux sociaux',
//                   style: AppTextStyles.title.copyWith(color: Colors.white),
//                 ),
//                 const SizedBox(height: 12),
//                 Wrap(
//                   spacing: 12,
//                   runSpacing: 12,
//                   children: [
//                     for (final social in socials)
//                       ActionChip(
//                         avatar: Icon(
//                           social.$1,
//                           color: AppColors.blanc,
//                           size: 18,
//                         ),
//                         label: Text(
//                           social.$2,
//                           style: const TextStyle(color: AppColors.blanc),
//                         ),
//                         backgroundColor:
//                             AppColors.chocolat.withValues(alpha: 0.4),
//                         onPressed: _openLink,
//                       ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _openLink() async {
//     final uri = Uri.parse('https://linkedin.com/in/ireneamdeji');
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
// }

// class _NarrativeCard extends StatelessWidget {
//   const _NarrativeCard({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(24),
//         color: Colors.white.withValues(alpha: 0.08),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Plateforme communautaire',
//             style: AppTextStyles.title.copyWith(color: Colors.white),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'ConseilBox met en lumière les parcours, conseils et idées venues des quatre coins de l’Afrique créative. '
//             'Chaque témoignage est modéré par l’équipe Kaizen afin de garantir authenticité, bienveillance et transmission. '
//             'Le projet vise à connecter les voix locales, inspirer les diasporas et faciliter l’entraide.',
//             style:
//                 AppTextStyles.body.copyWith(color: Colors.white70, height: 1.4),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Fonctionnalités clés :',
//             style: AppTextStyles.body.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: const [
//               _Bullet(text: 'Fil éditorial avec carrousel de publicités tech.'),
//               _Bullet(
//                   text:
//                       'Soumission de conseils en un clic, suivi des statuts.'),
//               _Bullet(
//                   text:
//                       'Favoris, partages sociaux et espace pubs contextualisé.'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _FounderCard extends StatelessWidget {
//   const _FounderCard({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(24),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
//       ),
//       child: Column(
//         children: [
//           Container(
//             width: 140,
//             height: 140,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: Colors.white, width: 4),
//             ),
//             child: ClipOval(
//               child: Image.asset(
//                 'assets/images/irokou.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'Irene Amedji',
//             style:
//                 AppTextStyles.title.copyWith(color: Colors.white, fontSize: 24),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Project Manager • Quantum Enthusiast\nCommunity Manager',
//             textAlign: TextAlign.center,
//             style: AppTextStyles.body.copyWith(color: Colors.white70),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _Bullet extends StatelessWidget {
//   const _Bullet({required this.text});

//   final String text;

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text('• ', style: TextStyle(color: Colors.white)),
//           Expanded(
//             child: Text(
//               text,
//               style: AppTextStyles.body.copyWith(color: Colors.white70),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
