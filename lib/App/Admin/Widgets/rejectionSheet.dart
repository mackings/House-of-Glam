import 'package:flutter/material.dart';
import 'package:hog/components/button.dart';
import 'package:hog/theme/app_theme.dart';

Future<List<String>?> showRejectReasonSheet(BuildContext context) async {
  final controller = TextEditingController();

  final reasons = await showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: MediaQuery.of(sheetContext).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(Icons.drag_handle, color: Colors.grey, size: 32),
              ),
              const SizedBox(height: 8),
              const Text(
                'Reject Listing',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter one reason per line.',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 5,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: 'Images are unclear\nIncorrect category selected',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.accentDeep,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      isOutlined: true,
                      title: 'Cancel',
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      title: 'Reject',
                      onPressed: () {
                        final values =
                            controller.text
                                .split('\n')
                                .map((item) => item.trim())
                                .where((item) => item.isNotEmpty)
                                .toList();

                        if (values.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter at least one reason'),
                            ),
                          );
                          return;
                        }

                        Navigator.pop(sheetContext, values);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  controller.dispose();
  return reasons;
}
