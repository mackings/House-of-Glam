import 'package:flutter/material.dart';

class CarouselItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String eyebrow;
  final String ctaLabel;
  final IconData icon;
  final Color background;
  final Color accent;
  final double borderRadius;

  const CarouselItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.ctaLabel,
    required this.icon,
    required this.background,
    required this.accent,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 9),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  eyebrow.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF172033),
                    fontSize: 18,
                    height: 1.08,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 9),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ctaLabel,
                      style: TextStyle(
                        color: accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_rounded, size: 15, color: accent),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 96,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 34),
          ),
        ],
      ),
    );
  }
}
