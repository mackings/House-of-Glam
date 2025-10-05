import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/texts.dart';

final obscureTextProvider = StateProvider.family<bool, String>(
  (ref, fieldKey) => true,
);

class CustomTextField extends ConsumerWidget {
  final String title;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final String fieldKey;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;

  /// Dropdown mode
  final List<String>? dropdownItems;
  final String? selectedValue;

  /// 🔥 NEW: Control padding for row layouts
  final bool isCompact;

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
    this.inputFormatters,
    this.onChanged,
    this.dropdownItems,
    this.selectedValue,
    this.isCompact = false, // 🔥 Default to false for backward compatibility
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final obscureText = ref.watch(obscureTextProvider(fieldKey));

    return Padding(
      padding:
          isCompact
              ? const EdgeInsets.only(bottom: 10) // 🔥 Reduced padding for rows
              : const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title, fontSize: 15, fontWeight: FontWeight.w500),
          const SizedBox(height: 8),

          /// If dropdownItems is provided, show dropdown
          dropdownItems != null
              ? DropdownButtonFormField<String>(
                value: selectedValue,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: screenWidth * 0.04,
                  ),
                ),
                items:
                    dropdownItems!
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  if (controller != null) controller!.text = value ?? '';
                  if (onChanged != null && value != null) onChanged!(value);
                },
              )
              /// Else render normal TextField
              : TextFormField(
                controller: controller,
                validator: validator,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                obscureText: isPassword ? obscureText : false,
                onChanged: onChanged,
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
                  suffixIcon:
                      isPassword
                          ? IconButton(
                            icon: Icon(
                              obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
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
