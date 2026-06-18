import 'package:flutter/material.dart';

class CarouselItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String eyebrow;
  final String ctaLabel;
  final String imageAsset;
  final Color background;
  final Color accent;
  final double borderRadius;

  const CarouselItemWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.eyebrow,
    required this.ctaLabel,
    required this.imageAsset,
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
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _TextilePatternPainter(color: accent)),
          ),
          Row(
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
                        color: Color(0xFF201711),
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
                        color: Color(0xFF6F6258),
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
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 15,
                          color: accent,
                        ),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.12),
                      blurRadius: 14,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TextilePatternPainter extends CustomPainter {
  final Color color;

  const _TextilePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color.withValues(alpha: 0.055)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;

    const spacing = 18.0;
    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }

    final dotPaint =
        Paint()
          ..color = color.withValues(alpha: 0.075)
          ..style = PaintingStyle.fill;
    for (double x = 12; x < size.width; x += 36) {
      for (double y = 10; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 1.8, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TextilePatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
