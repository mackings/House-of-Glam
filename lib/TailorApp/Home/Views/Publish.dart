import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/theme/app_theme.dart';
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

  final List<String> colors = [
    "Red",
    "Blue",
    "White",
    "Black",
    "Green",
    "Yellow",
    "Purple",
    "Pink",
    "Orange",
    "Brown",
    "Gray",
    "Others",
  ];
  String? selectedColor;
  bool showCustomColorField = false;

  final TextEditingController attireTypeController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController customColorController = TextEditingController();
  final TextEditingController customCategoryController =
      TextEditingController();

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

      debugPrint("Loaded ${categories.length} categories");
    } catch (e) {
      if (!mounted) return;
      debugPrint("Error loading categories: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load categories",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> pickSampleImage() async {
    if (sampleImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "You can only upload up to 5 images.",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
          content: Text(
            "⚠️ Please fill all required fields",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (selectedCategory == null || selectedCategory!.id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "⚠️ Selected category is unavailable. Please refresh.",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "✅ Material published successfully",
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Failed: $e", style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
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
    final hasCustomCategory =
        selectedCategoryName == "Others" && showCustomCategoryField;
    final hasCustomColor = selectedColor == "Others" && showCustomColorField;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.canvas,
        title: Text(
          "Publish Material",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
      ),
      body:
          isLoading && categories.isEmpty
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderCard(),
                      const SizedBox(height: 18),
                      _buildSectionCard(
                        icon: Icons.checkroom_outlined,
                        title: "Material basics",
                        subtitle:
                            "Start with the category and attire type customers will see first.",
                        child: Column(
                          children: [
                            _buildFieldLabel("Category", true),
                            _buildStyledDropdown(
                              hint: "Select category",
                              value: selectedCategoryName,
                              options: [
                                ...categories.map((c) => c.name),
                                if (!categories.any(
                                  (c) => c.name.toLowerCase() == "others",
                                ))
                                  "Others",
                              ],
                              onChanged: (val) {
                                setState(() {
                                  selectedCategoryName = val;
                                  if (val == "Others") {
                                    selectedCategory = categories.firstWhere(
                                      (c) => c.name.toLowerCase() == "others",
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
                            if (hasCustomCategory) ...[
                              const SizedBox(height: 8),
                              _buildAssistCard(
                                title: "Custom category",
                                subtitle:
                                    "Name the material group exactly as you want it to appear.",
                                child: CustomTextField(
                                  title: "",
                                  hintText: "e.g Bespoke Gown, Bridal Wear",
                                  fieldKey: "customCategory",
                                  controller: customCategoryController,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            _buildFieldLabel("Attire Type", true),
                            CustomTextField(
                              title: "",
                              hintText: "e.g Agbada, Senator, Kaftan",
                              fieldKey: "attireType",
                              controller: attireTypeController,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _buildSectionCard(
                        icon: Icons.palette_outlined,
                        title: "Appearance and brand",
                        subtitle:
                            "Keep the listing easy to scan with a clear color and recognizable brand.",
                        child: Column(
                          children: [
                            _buildFieldLabel("Color", true),
                            _buildStyledDropdown(
                              hint: "Select color",
                              value: selectedColor,
                              options: colors,
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
                            if (hasCustomColor) ...[
                              const SizedBox(height: 8),
                              _buildAssistCard(
                                title: "Custom color",
                                subtitle:
                                    "Use the exact shade name if it helps buyers identify the fabric faster.",
                                child: CustomTextField(
                                  title: "",
                                  hintText:
                                      "e.g Navy Blue, Burgundy, Turquoise",
                                  fieldKey: "customColor",
                                  controller: customColorController,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
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
                      const SizedBox(height: 18),
                      _buildSectionCard(
                        icon: Icons.photo_library_outlined,
                        title: "Preview gallery",
                        subtitle:
                            "Upload sharp images that show texture, fit, and color properly.",
                        trailing: _buildCountBadge("${sampleImages.length}/5"),
                        child: _buildImagePickerGrid(),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 18,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Ready to publish?",
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Review the details once and publish when the material is ready for customers to browse.",
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: AppColors.subtext,
                              ),
                            ),
                            const SizedBox(height: 18),
                            CustomButton(
                              title: "Publish Material",
                              onPressed: isLoading ? null : _submitPublish,
                              isLoading: isLoading,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF7F1FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.publish_rounded,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "List a new material",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Use clear details and strong photos so the listing feels premium from the first glance.",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildMiniInfoChip(
                icon: Icons.style_outlined,
                text: "Category, type, color",
              ),
              _buildMiniInfoChip(
                icon: Icons.image_outlined,
                text: "Up to 5 gallery images",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        height: 1.45,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 12), trailing],
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildAssistCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              height: 1.4,
              color: AppColors.subtext,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String hint,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.4),
        ),
      ),
      style: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.ink,
      ),
      items:
          options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildImagePickerGrid() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.tips_and_updates_outlined,
                  color: AppColors.accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Use bright front shots and close texture angles for better discovery.",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.subtext,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sampleImages.length < 5 ? sampleImages.length + 1 : 5,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemBuilder: (context, index) {
            if (index == sampleImages.length && sampleImages.length < 5) {
              return InkWell(
                onTap: pickSampleImage,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Add image",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final image = sampleImages[index];
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    image: DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => removeSampleImage(index),
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildMiniInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
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
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              "*",
              style: TextStyle(color: Color(0xFFEF4444), fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }
}
