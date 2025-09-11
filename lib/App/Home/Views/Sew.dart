import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/components/Tailors/dropdown.dart';
import 'package:hog/components/Tailors/imagepickers.dart';
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
  final List<String> attireTypes = ["Agbada", "Senator", "Kaftan", "Buba & Sokoto", "Iro & Buba"];
  final List<String> materials = ["Cotton", "Brocade", "Atiku", "Ankara", "Lace"];
  final List<String> colors = ["Red", "Blue", "White", "Black", "Green"];

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
      setState(() => sampleImages.add(File(image.path)));
    }
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
        title: const CustomText("Place Order", color: Colors.white, fontSize: 20),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomDropdown(
              label: "Select Attire Type",
              options: attireTypes,
              selectedValue: selectedAttire,
              onChanged: (val) => setState(() => selectedAttire = val),
            ),
            CustomDropdown(
              label: "Choose Material",
              options: materials,
              selectedValue: selectedMaterial,
              onChanged: (val) => setState(() => selectedMaterial = val),
            ),
            CustomDropdown(
              label: "Select Color",
              options: colors,
              selectedValue: selectedColor,
              onChanged: (val) => setState(() => selectedColor = val),
            ),

            CustomText("Branding Option", fontSize: 16, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            CustomTextField(
              title: "Branding",
              hintText: "Name / Logo embroidery",
              fieldKey: "branding",
              controller: brandingController,
            ),

            const SizedBox(height: 16),
            CustomText("Measurements", fontSize: 18, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            ...measurementControllers.keys.map(
              (key) => MeasurementField(label: key, controller: measurementControllers[key]!),
            ),

            const SizedBox(height: 16),
            CustomText("Upload Sample Designs (Optional, up to 5)", fontSize: 16, fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            MultiImagePicker(images: sampleImages, onAddImage: pickSampleImage),

            const SizedBox(height: 40),
            CustomButton(title: "Submit Order", onPressed: _submitOrder),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

