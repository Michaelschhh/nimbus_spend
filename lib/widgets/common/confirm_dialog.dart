import 'package:flutter/material.dart';
import '../../theme/colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmLabel;
  final VoidCallback onConfirm;
  final bool isDanger;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmLabel = "Confirm",
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Text(content),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isDanger ? AppColors.danger : AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            confirmLabel,
            style: TextStyle(color: (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
          ),
        ),
      ],
    );
  }
}
