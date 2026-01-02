import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/components/Tailors/dropdown.dart';
import 'package:hog/components/Tailors/imagepickers.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:image_picker/image_picker.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key});

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  List<Category> categories = [];
  Category? selectedCategory;

  final List<String> materials = [
    "Cotton",
    "Brocade",
    "Atiku",
    "Ankara",
    "Lace",
    "Silk",
    "Chiffon",
    "Linen",
    "Velvet",
    "Organza",
    "Crepe",
    "Satin",
    "Tulle",
    "Georgette",
    "Damask",
    "Khaki",
    "Denim",
    "Cashmere",
    "Wool",
    "Polyester",
    "Corduroy",
    "Rayon",
    "Jersey",
    "Suede",
    "Leather",
    "Net",
    "Voile",
    "Sequin",
    "Taffeta",
  ];

  final List<String> colors = ["Red", "Blue", "White", "Black", "Green"];

  String? selectedMaterial;
  String? selectedColor;

  final TextEditingController brandingController = TextEditingController();
  final TextEditingController specialInstructionsController = TextEditingController();
  final TextEditingController customMaterialController = TextEditingController();
  final TextEditingController customAttireController = TextEditingController();
  final TextEditingController customColorController = TextEditingController(); // NEW

  String? selectedAttireType;

  final Map<String, TextEditingController> measurementControllers = {};

  final List<File> sampleImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  final List<String> measurementFields = [
    "Neck",
    "Shoulder",
    "Chest",
    "Waist",
    "Hip",
    "Sleeve Length",
    "Arm Length",
    "Around Arm",
    "Wrist",
    "Collar Front",
    "Collar Back",
    "Length",
    "Arm Type",
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();

    for (var field in measurementFields) {
      measurementControllers[field] = TextEditingController();
    }
  }

  Future<void> _loadCategories() async {
    final cachedCategories = await SecurePrefs.getCategories();
    setState(() {
      categories = cachedCategories;
    });
  }

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

  void removeSampleImage(int index) {
    setState(() {
      sampleImages.removeAt(index);
    });
  }

  Future<void> pickDate(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  Widget buildMeasurementFields() {
    List<Widget> rows = [];
    for (var i = 0; i < measurementFields.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: MeasurementField(
                  label: measurementFields[i],
                  controller: measurementControllers[measurementFields[i]]!,
                  isNumeric: measurementFields[i] != "Arm Type",
                ),
              ),
            ),
            if (i + 1 < measurementFields.length)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: MeasurementField(
                    label: measurementFields[i + 1],
                    controller: measurementControllers[measurementFields[i + 1]]!,
                    isNumeric: measurementFields[i + 1] != "Arm Type",
                  ),
                ),
              ),
          ],
        ),
      );
      rows.add(const SizedBox(height: 10));
    }
    return Column(children: rows);
  }

  Future<void> _submitOrder() async {
    // Handle "Others" for material and attire type
    final String finalMaterial = selectedMaterial == "Others"
        ? customMaterialController.text.trim()
        : selectedMaterial ?? '';

    final String finalAttireType = (selectedCategory == null && selectedAttireType == "Others")
        ? customAttireController.text.trim()
        : selectedCategory?.name ?? '';

    // Handle "Others" for color - NEW
    final String finalColor = selectedColor == "Others"
        ? customColorController.text.trim()
        : selectedColor ?? '';

    // Validation - UPDATED
    if (finalAttireType.isEmpty || finalMaterial.isEmpty || finalColor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select or specify attire, material, and color"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // Only save category ID if not "Others"
    if (selectedCategory != null) {
      await SecurePrefs.saveAttireId(selectedCategory!.id);
    }

    // Build measurement map
    final measurement = measurementControllers.map((key, controller) {
      if (key == "Arm Type") return MapEntry("armType", controller.text);
      return MapEntry(
        key.replaceAll(' ', '').toLowerCase(),
        double.tryParse(controller.text) ?? 0,
      );
    });

    // Send request - UPDATED
    final response = await UserActivityService.createMaterial(
      clothMaterial: finalMaterial,
      color: finalColor,
      brand: brandingController.text,
      images: sampleImages,
      specialInstructions: specialInstructionsController.text,
      measurement: measurement,
    );

    setState(() => isLoading = false);

    // Feedback
    if (response != null && response.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ ${response.message}")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to submit order")),
      );
    }
  }

  @override
  void dispose() {
    brandingController.dispose();
    specialInstructionsController.dispose();
    customMaterialController.dispose();
    customAttireController.dispose();
    customColorController.dispose(); // NEW
    measurementControllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const CustomText(
            "Place Order",
            color: Colors.white,
            fontSize: 18,
          ),
          backgroundColor: Colors.purple,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // Attire Section
              CustomText(
                "Attire Details *",
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              const Divider(),
              SizedBox(height: 20),

              CustomDropdown(
                label: "Choose Material",
                options: [...materials, "Others"],
                selectedValue: selectedMaterial,
                onChanged: (val) {
                  setState(() {
                    selectedMaterial = val;
                  });
                },
              ),
              if (selectedMaterial == "Others") ...[
                const SizedBox(height: 10),
                CustomTextField(
                  title: "Specify Material",
                  hintText: "Enter material name",
                  fieldKey: "customMaterial",
                  controller: customMaterialController,
                ),
              ],

              const SizedBox(height: 10),

              CustomDropdown(
                label: "Select Attire Type",
                options: [...categories.map((c) => c.name).toList(), "Others"],
                selectedValue: selectedCategory?.name,
                onChanged: (val) {
                  setState(() {
                    if (val == "Others") {
                      selectedCategory = null;
                    } else {
                      selectedCategory = categories.firstWhere((c) => c.name == val);
                    }
                    selectedAttireType = val;
                  });
                },
              ),
              if (selectedAttireType == "Others") ...[
                const SizedBox(height: 10),
                CustomTextField(
                  title: "Specify Attire Type",
                  hintText: "Enter attire type",
                  fieldKey: "customAttireType",
                  controller: customAttireController,
                ),
              ],

              const SizedBox(height: 10),

              // UPDATED: Color dropdown with "Others" option
              CustomDropdown(
                label: "Select Color",
                options: [...colors, "Others"],
                selectedValue: selectedColor,
                onChanged: (val) => setState(() => selectedColor = val),
              ),
              if (selectedColor == "Others") ...[
                const SizedBox(height: 10),
                CustomTextField(
                  title: "Specify Color",
                  hintText: "Enter color name",
                  fieldKey: "customColor",
                  controller: customColorController,
                ),
              ],

              const SizedBox(height: 20),
              CustomText(
                "Brand and Budget *",
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              const Divider(),
              CustomTextField(
                title: "Branding",
                hintText: "Name / Logo embroidery",
                fieldKey: "branding",
                controller: brandingController,
              ),
              const SizedBox(height: 20),

              CustomText(
                "Special Instructions *",
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              const Divider(),
              CustomTextField(
                title: "Special Instructions",
                hintText: "I want it slim fit",
                fieldKey: "specialInstructions",
                controller: specialInstructionsController,
              ),

              const SizedBox(height: 20),
              CustomText(
                "Measurements (CM)*",
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              const Divider(),
              buildMeasurementFields(),

              const SizedBox(height: 20),
              CustomText(
                "Design samples *",
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              const Divider(),
              SizedBox(height: 20),
              MultiImagePicker(
                images: sampleImages,
                onAddImage: pickSampleImage,
                onRemoveImage: removeSampleImage,
              ),

              const SizedBox(height: 40),
              CustomButton(title: "Submit Order", onPressed: _submitOrder),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}