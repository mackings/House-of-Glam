import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool isOutlined;
  final VoidCallback? onPressed; // ✅ make nullable so we can disable
  final double? width;
  final double? height;
  final bool isLoading; // ✅ optional loading state

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.isOutlined = false,
    this.width,
    this.height,
    this.isLoading = false, // ✅ default false
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDisabled = isLoading || onPressed == null;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isOutlined ? 0 : 1,
          shadowColor: AppColors.shadow,
          backgroundColor:
              isOutlined
                  ? Colors.white
                  : (isDisabled ? AppColors.accent.withValues(alpha: 0.55) : AppColors.accent),
          foregroundColor: isOutlined ? AppColors.accent : Colors.white,
          side:
              isOutlined
                  ? const BorderSide(color: AppColors.border, width: 1.2)
                  : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        child:
            isLoading
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : CustomText(
                  title,
                  fontSize: screenWidth < 390 ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  color: isOutlined ? AppColors.accent : Colors.white,
                ),
      ),
    );
  }
}
