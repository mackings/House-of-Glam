import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/utils/ui_label_formatter.dart';

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
          initialValue: selectedValue,
          menuMaxHeight: 320,
          isExpanded: true,
          items:
              options
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(formatUiLabel(e)),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
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
  final bool isNumeric;

  const MeasurementField({
    super.key,
    required this.label,
    required this.controller,
    this.isNumeric = true, // default to numeric
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }
}
