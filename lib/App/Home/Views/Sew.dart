import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:image_picker/image_picker.dart';

class Sew extends StatefulWidget {
  const Sew({super.key});

  @override
  State<Sew> createState() => _SewState();
}

class _SewState extends State<Sew> {
  // Options
  final List<String> attireTypes = [
    "Agbada",
    "Senator",
    "Kaftan",
    "Buba & Sokoto",
    "Iro & Buba",
  ];

  final List<String> materials = [
    "Cotton",
    "Brocade",
    "Atiku",
    "Ankara",
    "Lace",
  ];

  final List<String> colors = ["Red", "Blue", "White", "Black", "Green"];

  // Selected options
  String? selectedAttire;
  String? selectedMaterial;
  String? selectedColor;

  final TextEditingController brandingController = TextEditingController();
  final Map<String, TextEditingController> measurementControllers = {
    "Neck": TextEditingController(),
    "Chest": TextEditingController(),
    "Waist": TextEditingController(),
    "Sleeve": TextEditingController(),
    "Hips": TextEditingController(),
  };

  final List<File> sampleImages = [];
  final ImagePicker _picker = ImagePicker();

  Future<void> pickSampleImage() async {
    if (sampleImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You can only upload up to 5 images.")),
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        sampleImages.add(File(image.path));
      });
    }
  }

  Widget _buildDropdown(
      String label,
      List<String> options,
      String? selectedValue,
      Function(String?) onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(label, fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildMeasurementField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        CustomTextField(
          title: label,
          hintText: "Enter $label in inches",
          fieldKey: label.toLowerCase(),
          controller: measurementControllers[label],
          keyboardType: TextInputType.number,
        ),
       // const SizedBox(height: 4),
      ],
    );
  }

  void _submitOrder() {
    final orderData = {
      "attire": selectedAttire,
      "material": selectedMaterial,
      "color": selectedColor,
      "branding": brandingController.text,
      "measurements": measurementControllers.map((k, v) => MapEntry(k, v.text)),
      "sampleImages": sampleImages.map((f) => f.path).toList(),
    };

    print("Order Data: $orderData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order submitted successfully!")),
    );
  }

  @override
  void dispose() {
    brandingController.dispose();
    measurementControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Place Tailor Order"),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
              "Select Attire Type",
              attireTypes,
              selectedAttire,
              (val) => setState(() => selectedAttire = val),
            ),
            _buildDropdown(
              "Choose Material",
              materials,
              selectedMaterial,
              (val) => setState(() => selectedMaterial = val),
            ),
            _buildDropdown(
              "Select Color",
              colors,
              selectedColor,
              (val) => setState(() => selectedColor = val),
            ),

            const SizedBox(height: 8),
            CustomText(
              "Branding Option",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              title: "Branding",
              hintText: "Name / Logo embroidery",
              fieldKey: "branding",
              controller: brandingController,
            ),
            const SizedBox(height: 16),

            CustomText(
              "Measurements",
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            ...measurementControllers.keys.map(
                  (key) => _buildMeasurementField(key),
            ),

            CustomText(
              "Upload Sample Designs (Optional, up to 5)",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sampleImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == sampleImages.length) {
                    return GestureDetector(
                      onTap: pickSampleImage,
                      child: Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade100,
                        ),
                        child: const Center(
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  final file = sampleImages[index];
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
            CustomButton(
              title: "Submit Order",
              onPressed: _submitOrder,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

