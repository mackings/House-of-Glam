import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const InfoRow({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          CustomText(
            "$title: ",
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          Expanded(child: CustomText(value, color: Colors.black87)),
        ],
      ),
    );
  }
}
