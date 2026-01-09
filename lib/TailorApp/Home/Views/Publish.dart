import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Api/home.dart';
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
  String? selectedCategoryName;
  bool showCustomCategoryField = false;

  final List<String> colors = ["Red", "Blue", "White", "Black", "Green", "Yellow", "Purple", "Pink", "Orange", "Brown", "Gray", "Others"];
  String? selectedColor;
  bool showCustomColorField = false;

  final TextEditingController attireTypeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController customColorController = TextEditingController();
  final TextEditingController customCategoryController = TextEditingController();

  final List<File> sampleImages = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;

  final _publishedService = PublishedService();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // Load categories via API (with fallback to cache)
  Future<void> _loadCategories() async {
    setState(() => isLoading = true);

    try {
      // Try cached first
      final cachedCategories = await SecurePrefs.getCategories();

      if (cachedCategories.isNotEmpty) {
        setState(() => categories = cachedCategories);
      }

      // Always refresh from API in the background
      final fetchedCategories = await HomeApiService.getAllCategories();
      if (fetchedCategories.isNotEmpty) {
        setState(() => categories = fetchedCategories);
      }

      print("✅ Loaded ${categories.length} categories");
    } catch (e) {
      print("❌ Error loading categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load categories", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }

    setState(() => isLoading = false);
  }

  Future<void> pickSampleImage() async {
    if (sampleImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("You can only upload up to 5 images.", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => sampleImages.add(File(image.path)));
    }
  }

  // Get the final color value (either selected or custom)
  String? _getFinalColorValue() {
    if (selectedColor == "Others" && customColorController.text.isNotEmpty) {
      return customColorController.text.trim();
    }
    return selectedColor != "Others" ? selectedColor : null;
  }

  String? _getFinalCategoryName() {
    if (selectedCategoryName == "Others" &&
        customCategoryController.text.isNotEmpty) {
      return customCategoryController.text.trim();
    }
    return selectedCategoryName == "Others" ? null : selectedCategory?.name;
  }

  Future<void> _submitPublish() async {
    final finalColor = _getFinalColorValue();
    final finalCategoryName = _getFinalCategoryName();

    if (selectedCategoryName == null ||
        attireTypeController.text.isEmpty ||
        finalColor == null ||
        brandController.text.isEmpty ||
        finalCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Please fill all required fields", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (selectedCategory == null || selectedCategory!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("⚠️ Selected category is unavailable. Please refresh.", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await _publishedService.createPublished(
        categoryId: selectedCategory!.id,
        attireType: attireTypeController.text,
        clothPublished: finalCategoryName,
        color: finalColor,
        brand: brandController.text,
        images: sampleImages,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("✅ Material published successfully", style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Failed: $e", style: GoogleFonts.poppins()),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  void removeSampleImage(int index) {
    setState(() {
      sampleImages.removeAt(index);
    });
  }

  @override
  void dispose() {
    attireTypeController.dispose();
    brandController.dispose();
    customColorController.dispose();
    customCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            "Publish Material",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: isLoading && categories.isEmpty
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF6B21A8)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.checkroom_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Attire Details",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Fill in the material information",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Form Container
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Dropdown
                          _buildFieldLabel("Category", true),
                          CustomDropdown(
                            label: "Select Category",
                            options: [
                              ...categories.map((c) => c.name),
                              if (!categories.any(
                                (c) => c.name.toLowerCase() == "others",
                              ))
                                "Others",
                            ],
                            selectedValue: selectedCategoryName,
                            onChanged: (val) {
                              setState(() {
                                selectedCategoryName = val;
                                if (val == "Others") {
                                  selectedCategory = categories.firstWhere(
                                    (c) =>
                                        c.name.toLowerCase() == "others",
                                    orElse:
                                        () => Category(
                                          id: "",
                                          name: "Others",
                                          description: "",
                                          image:
                                              "https://via.placeholder.com/150",
                                          createdAt: "",
                                          updatedAt: "",
                                          v: 0,
                                        ),
                                  );
                                  showCustomCategoryField = true;
                                } else {
                                  selectedCategory = categories.firstWhere(
                                    (c) => c.name == val,
                                  );
                                  showCustomCategoryField = false;
                                  customCategoryController.clear();
                                }
                              });
                            },
                          ),
                          if (showCustomCategoryField) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF5FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF6B21A8).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: const Color(0xFF6B21A8),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Enter Custom Category",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    title: "",
                                    hintText: "e.g Bespoke Gown, Bridal Wear",
                                    fieldKey: "customCategory",
                                    controller: customCategoryController,
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),

                          // Attire Type
                          _buildFieldLabel("Attire Type", true),
                          CustomTextField(
                            title: "",
                            hintText: "e.g Agbada, Senator, Kaftan",
                            fieldKey: "attireType",
                            controller: attireTypeController,
                          ),
                          const SizedBox(height: 20),

                          // Color
                          _buildFieldLabel("Color", true),
                          CustomDropdown(
                            label: "Select Color",
                            options: colors,
                            selectedValue: selectedColor,
                            onChanged: (val) {
                              setState(() {
                                selectedColor = val;
                                showCustomColorField = (val == "Others");
                                if (val != "Others") {
                                  customColorController.clear();
                                }
                              });
                            },
                          ),

                          // Custom Color Field (appears when "Others" is selected)
                          if (showCustomColorField) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFAF5FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF6B21A8).withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: const Color(0xFF6B21A8),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Enter Custom Color",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B21A8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  CustomTextField(
                                    title: "",
                                    hintText: "e.g Navy Blue, Burgundy, Turquoise",
                                    fieldKey: "customColor",
                                    controller: customColorController,
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 20),

                          // Brand
                          _buildFieldLabel("Brand", true),
                          CustomTextField(
                            title: "",
                            hintText: "e.g Gucci, Versace, Louis Vuitton",
                            fieldKey: "brand",
                            controller: brandController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Images Section
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B21A8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.image_rounded,
                                  size: 20,
                                  color: Color(0xFF6B21A8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Upload Images",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  Text(
                                    "Add up to 5 images",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B21A8).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${sampleImages.length}/5",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF6B21A8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          MultiImagePicker(
                            images: sampleImages,
                            onAddImage: pickSampleImage,
                            onRemoveImage: removeSampleImage,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Publish Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6B21A8), Color(0xFF7C3AED)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: isLoading ? null : _submitPublish,
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.publish_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Publish Material",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool required) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
