import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

enum TopAlertType { info, success, error }

class TopAlert {
  static OverlayEntry? _entry;
  static bool _isShowing = false;

  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    TopAlertType type = TopAlertType.info,
    Duration duration = const Duration(seconds: 3),
    IconData? icon,
    Color? background,
    VoidCallback? onTap,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 12),
  }) async {
    if (_isShowing) return; // avoid stacking
    _isShowing = true;

    final theme = _colorsForType(type);
    final safeTop = MediaQuery.of(context).padding.top;
    final controller = AnimationController(
      vsync: Navigator.of(context),
      duration: const Duration(milliseconds: 780),
      reverseDuration: const Duration(milliseconds: 220),
    );

    final animation = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic);

    _entry = OverlayEntry(
      builder: (ctx) {
        double dragOffset = 0;

        return StatefulBuilder(
          builder: (ctx, setState) {
            return Positioned(
              top: -10 + safeTop + (animation.value * (120)) + dragOffset,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onVerticalDragUpdate: (d) {
                    setState(() => dragOffset += d.delta.dy);
                  },
                  onVerticalDragEnd: (d) async {
                    if (dragOffset > 30) {
                      await controller.reverse();
                      _remove();
                      return;
                    }
                    setState(() => dragOffset = 0);
                  },
                  onTap: () async {
                    onTap?.call();
                    await controller.reverse();
                    _remove();
                  },
                  child: Container(
                    margin: margin,
                    decoration: BoxDecoration(
                      color: background ?? theme.bg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                          color: Colors.black.withOpacity(0.15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon ?? theme.icon, color: theme.fg),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (title != null && title.isNotEmpty)

                              CustomText(title),

                              CustomText(message),
                              
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            await controller.reverse();
                            _remove();
                          },
                          child: Icon(Icons.close_rounded, color: theme.fg),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
    await controller.forward();

    // Auto-dismiss
    await Future.delayed(duration);
    if (controller.status == AnimationStatus.completed) {
      await controller.reverse();
      _remove();
    }
  }

  static void _remove() {
    _entry?.remove();
    _entry = null;
    _isShowing = false;
  }
}

class _AlertPalette {
  final Color bg;
  final Color fg;
  final IconData icon;
  _AlertPalette(this.bg, this.fg, this.icon);
}

_AlertPalette _colorsForType(TopAlertType type) {
  switch (type) {
    case TopAlertType.success:
      return _AlertPalette(const Color(0xFF12B886), Colors.white, Icons.check_circle_rounded);
    case TopAlertType.error:
      return _AlertPalette(const Color(0xFFE03131), Colors.white, Icons.error_rounded);
    case TopAlertType.info:
    default:
      return _AlertPalette(const Color(0xFF1C7ED6), Colors.white, Icons.info_rounded);
  }
}


extension _NavigatorTicker on NavigatorState {}
