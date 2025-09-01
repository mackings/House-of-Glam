import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

// ✅ Success Dialog
Future<void> showSuccessDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 8),
          CustomText(
            "Success",
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
      content: CustomText(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText(
            "OK",
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    ),
  );
}

// ❌ Error Dialog
Future<void> showErrorDialog(BuildContext context, String message) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      title: Row(
        children: const [
          Icon(Icons.error, color: Colors.red, size: 28),
          SizedBox(width: 8),
          CustomText(
            "Error",
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ],
      ),
      content: CustomText(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const CustomText(
            "OK",
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ],
    ),
  );
}
