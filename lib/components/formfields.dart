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

  final List<String>? dropdownItems;
  final String? selectedValue;

  final bool enableCountryCode;
  final List<String> countryCodes;
  final String? selectedCountryCode;
  final ValueChanged<String?>? onCountryChanged;

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
    this.isCompact = false,
    this.enableCountryCode = false,
    this.countryCodes = const ['+1', '+44', '+234', '+91'],
    this.selectedCountryCode,
    this.onCountryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final obscureText = ref.watch(obscureTextProvider(fieldKey));

    return Padding(
      padding: isCompact
          ? const EdgeInsets.only(bottom: 10)
          : const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(title, fontSize: 15, fontWeight: FontWeight.w500),
          const SizedBox(height: 8),

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
                  items: dropdownItems!
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
              : Row(
                  children: [
                    if (enableCountryCode) ...[
                      SizedBox(
                        width: 100,
                        child: DropdownButtonFormField<String>(
                          value: selectedCountryCode ?? countryCodes.first,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 10,
                            ),
                          ),
                          items: countryCodes
                              .map(
                                (code) => DropdownMenuItem<String>(
                                  value: code,
                                  child: Text(code),
                                ),
                              )
                              .toList(),
                          onChanged: onCountryChanged,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],

                    Expanded(
                      child: TextFormField(
                        controller: controller,
                        keyboardType: keyboardType,
                        inputFormatters: inputFormatters,
                        obscureText: isPassword ? obscureText : false,
                        onChanged: onChanged,

                        /// ✅ Smart validator for password fields
                        validator: (value) {
                          if (isPassword) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(value)) {
                              return 'Password must contain at least one uppercase letter';
                            }
                            if (!RegExp(r'[0-9]').hasMatch(value)) {
                              return 'Password must contain at least one number';
                            }
                            if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) {
                              return 'Password must contain at least one special character';
                            }
                          }

                          if (validator != null) {
                            return validator!(value);
                          }
                          return null;
                        },

                        decoration: InputDecoration(
                          hintText: hintText,
                          prefixIcon:
                              prefixIcon != null ? Icon(prefixIcon) : null,
                          suffixIcon: isPassword
                              ? IconButton(
                                  icon: Icon(
                                    obscureText
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    ref
                                        .read(obscureTextProvider(fieldKey)
                                            .notifier)
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
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
