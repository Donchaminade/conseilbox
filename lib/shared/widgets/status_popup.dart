import 'package:flutter/material.dart';

enum PopupStatus { success, error }

Future<void> showStatusPopup(
    BuildContext context, PopupStatus status, String message) {
  IconData icon;
  Color color;

  switch (status) {
    case PopupStatus.success:
      icon = Icons.check_circle;
      color = Colors.green;
      break;
    case PopupStatus.error:
      icon = Icons.error;
      color = Colors.red;
      break;
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 50),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    },
  );
}
