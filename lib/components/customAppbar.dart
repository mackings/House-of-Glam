import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

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
    this.iconColor = Colors.black,
    this.titleStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true, // make sure it doesn’t overlap status bar
      child: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading:
            enableBack
                ? IconButton(
                  icon: Icon(backIcon, color: iconColor),
                  onPressed: onBack ?? () => Navigator.pop(context),
                )
                : null,
        title: CustomText(
          title,
          fontSize: titleStyle?.fontSize ?? 20,
          fontWeight: FontWeight.bold,
          color: titleStyle?.color ?? iconColor,
        ),
        actions:
            enableAction
                ? [
                  IconButton(
                    icon: Icon(actionIcon, color: iconColor),
                    onPressed: onAction,
                  ),
                ]
                : null,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
