import 'package:flutter/material.dart';
import '../../config/app_text_styles.dart';

class CardConseil extends StatelessWidget {
  final String author;
  final String text;
  final String date;
  const CardConseil({super.key, required this.author, required this.text, required this.date});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(author, style: AppTextStyles.title),
          const SizedBox(height: 6),
          Text(text, style: AppTextStyles.body),
          const SizedBox(height: 8),
          Text(date, style: AppTextStyles.small),
        ]),
      ),
    );
  }
}