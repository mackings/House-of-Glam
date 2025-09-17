import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class WorkDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final IconData? trailingIcon;
  final String? trailingText;
  final bool smallText;

  const WorkDetailRow({
    super.key,
    required this.icon,
    required this.label,
    this.trailingIcon,
    this.trailingText,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 6),
        CustomText(
          label,
          color: Colors.black87,
          fontSize: smallText ? 12 : 14,
        ),
        if (trailingIcon != null && trailingText != null) ...[
          const Spacer(),
          Icon(trailingIcon, size: 16, color: Colors.black54),
          const SizedBox(width: 6),
          CustomText(trailingText!, color: Colors.black87),
        ],
      ],
    );
  }
}