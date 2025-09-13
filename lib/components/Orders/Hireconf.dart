import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';



class HireDesignerConfirmation extends StatelessWidget {
  final VoidCallback onYes;
  const HireDesignerConfirmation({super.key, required this.onYes});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CustomText(
            "Do you want to proceed with this designer?",
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onYes();
                },
                child: const CustomText("Yes"),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const CustomText("Cancel"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
