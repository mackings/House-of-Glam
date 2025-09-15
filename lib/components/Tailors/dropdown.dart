import 'package:flutter/material.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';


class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selectedValue;
  final Function(String?) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, fontSize: 16, fontWeight: FontWeight.w500),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: selectedValue,
          items: options
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class MeasurementField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const MeasurementField({super.key, required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      title: label,
      hintText: "Enter $label",
      fieldKey: label.toLowerCase(),
      controller: controller,
      keyboardType: TextInputType.number,
    );
  }
}
