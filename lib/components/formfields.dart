import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/texts.dart';


final obscureTextProvider =
    StateProvider.family<bool, String>((ref, fieldKey) => true);

class CustomTextField extends ConsumerWidget {
  
  final String title;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;

  final String fieldKey;

  const CustomTextField({
    Key? key,
    required this.title,
    required this.hintText,
    required this.fieldKey,
    this.prefixIcon,
    this.isPassword = false,
    this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final obscureText = ref.watch(obscureTextProvider(fieldKey));

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: 10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

           CustomText(
            title,
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w600,
          ),

          const SizedBox(height: 8),

          // TextFormField
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: isPassword ? obscureText : false,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        ref
                            .read(obscureTextProvider(fieldKey).notifier)
                            .state = !obscureText;
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: screenWidth * 0.04,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

