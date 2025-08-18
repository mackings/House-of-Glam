import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool isOutlined;
  final VoidCallback onPressed;
  final double? width;
  final double? height;

  const CustomButton({
    Key? key,
    required this.title,
    required this.onPressed,
    this.isOutlined = false,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: isOutlined ? Colors.transparent : Colors.purple,
          foregroundColor: isOutlined ? Colors.purple : Colors.white,
          side: isOutlined
              ? const BorderSide(color: Colors.purple, width: 2)
              : BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: CustomText(
          title,
          fontSize: screenWidth * 0.04,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
