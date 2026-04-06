import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAction;
  final IconData backIcon;
  final IconData actionIcon;
  final bool enableBack;
  final bool enableAction;
  final Color backgroundColor;
  final Color iconColor;
  final TextStyle? titleStyle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.onBack,
    this.onAction,
    this.backIcon = Icons.arrow_back_ios,
    this.actionIcon = Icons.info_outline,
    this.enableBack = true,
    this.enableAction = true,
    this.backgroundColor = Colors.transparent,
    this.iconColor = AppColors.ink,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: true,
      leading:
          enableBack
              ? Padding(
                padding: const EdgeInsets.only(left: 10),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Icon(backIcon, color: iconColor, size: 18),
                  ),
                  onPressed: onBack ?? () => Navigator.pop(context),
                ),
              )
              : null,
      title: CustomText(
        title,
        fontSize: titleStyle?.fontSize ?? 20,
        fontWeight: FontWeight.w700,
        color: titleStyle?.color ?? iconColor,
      ),
      actions:
          enableAction
              ? [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(actionIcon, color: iconColor, size: 18),
                    ),
                    onPressed: onAction,
                  ),
                ),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
