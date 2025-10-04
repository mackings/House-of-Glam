import 'package:flutter/material.dart';
import 'package:hog/components/button.dart';

class RejectReasonSheet extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const RejectReasonSheet({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // ensures keyboard safe
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
              "Reject Listing",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 5, // ✅ max lines for detailed reason
              decoration: InputDecoration(
                hintText: "Enter reason for rejection...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.purple.shade700, width: 1.5),
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
                    title: "Cancel",
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    title: "Reject",
                    onPressed: onSubmit,
                  ),
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
