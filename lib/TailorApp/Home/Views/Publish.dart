import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/components/Tailors/dropdown.dart';
import 'package:hog/components/Tailors/imagepickers.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:image_picker/image_picker.dart';




class PublishMaterial extends StatefulWidget {
  const PublishMaterial({super.key});

  @override
  State<PublishMaterial> createState() => _PublishMaterialState();
}

class _PublishMaterialState extends State<PublishMaterial> {
  List<Category> categories = [];
  Category? selectedCategory;

  final List<String> colors = ["Red", "Blue", "White", "Black", "Green"];
  String? selectedColor;

  final TextEditingController attireTypeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();

  final List<File> sampleImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  final _publishedService = PublishedService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

  Future<void> _submitPublish() async {
    if (selectedCategory == null ||
        attireTypeController.text.isEmpty ||
        selectedColor == null ||
        brandController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Please fill all required fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _publishedService.createPublished(
        categoryId: selectedCategory!.id,
        attireType: attireTypeController.text,
        clothPublished: selectedCategory!.name, // category name
        color: selectedColor!,
        brand: brandController.text,
        images: sampleImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Material published successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed: $e")),
        );
      }
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    attireTypeController.dispose();
    brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.purple,
          title: const CustomText(
            "Publish Material",
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText("Attire Details *", color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
              const Divider(),
              const SizedBox(height: 10),

              CustomDropdown(
                label: "Select Category",
                options: categories.map((c) => c.name).toList(),
                selectedValue: selectedCategory?.name,
                onChanged: (val) {
                  setState(() {
                    selectedCategory = categories.firstWhere((c) => c.name == val);
                  });
                },
              ),
              const SizedBox(height: 10),

              CustomTextField(
                title: "Attire Type",
                hintText: "e.g Agbada, Senator",
                fieldKey: "attireType",
                controller: attireTypeController,
              ),
              const SizedBox(height: 10),

              CustomDropdown(
                label: "Select Color",
                options: colors,
                selectedValue: selectedColor,
                onChanged: (val) => setState(() => selectedColor = val),
              ),
              const SizedBox(height: 10),

              CustomTextField(
                title: "Brand",
                hintText: "Gucci, Versace...",
                fieldKey: "brand",
                controller: brandController,
              ),
              const SizedBox(height: 20),

              CustomText("Upload Images *", color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
              const Divider(),
              const SizedBox(height: 10),

              MultiImagePicker(images: sampleImages, onAddImage: pickSampleImage),

              const SizedBox(height: 40),
              CustomButton(title: "Publish", onPressed: _submitPublish),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
