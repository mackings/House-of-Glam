import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/App/Profile/Api/ListingService.dart';
import 'package:hog/components/Tailors/dropdown.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Uploadlisting extends StatefulWidget {
  const Uploadlisting({super.key});

  @override
  State<Uploadlisting> createState() => _UploadlistingState();
}

class _UploadlistingState extends State<Uploadlisting> {
  List<Category> categories = [];
  Category? selectedCategory;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController sizeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // ✅ For yard inputs
  final TextEditingController lengthController = TextEditingController();
  final TextEditingController widthController = TextEditingController();

  final NumberFormat _formatter = NumberFormat('#,###');
  bool _isFormatting = false;

  File? frontImage;
  File? sideImage;
  File? backImage;

  final ImagePicker _picker = ImagePicker();

  String condition = "Newly Sewed";
  String status = "Available";
  bool isLoading = false;

  // ✅ New variable: Listing type
  String listingType = "Attire"; // or "Material"

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // ✅ Price formatting
    priceController.addListener(() {
      if (_isFormatting) return;
      _isFormatting = true;
      String raw = priceController.text.replaceAll(',', '');

      if (raw.isEmpty) {
        priceController.value = const TextEditingValue(
          text: '',
          selection: TextSelection.collapsed(offset: 0),
        );
        _isFormatting = false;
        return;
      }

      final value = int.tryParse(raw);
      if (value != null) {
        final formatted = _formatter.format(value);
        priceController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }

      _isFormatting = false;
    });
  }

  Future<void> _loadCategories() async {
    final cachedCategories = await SecurePrefs.getCategories();
    setState(() => categories = cachedCategories);
  }

  Future<void> pickImage(String type) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() {
      if (type == "front") frontImage = File(picked.path);
      if (type == "side") sideImage = File(picked.path);
      if (type == "back") backImage = File(picked.path);
    });
  }

  Future<void> _submitListing() async {
    if (selectedCategory == null ||
        titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        frontImage == null ||
        sideImage == null ||
        backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields.")),
      );
      return;
    }

    if (listingType == "Material" &&
        (lengthController.text.isEmpty || widthController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter length and width for material."),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final rawPrice = priceController.text.replaceAll(',', '');
    final priceToSend = double.tryParse(rawPrice) ?? 0;

    // ✅ Create yard data only if Material
    final List<Map<String, dynamic>>? yards =
        listingType == "Material"
            ? [
              {
                "length": lengthController.text.trim(),
                "width": widthController.text.trim(),
              },
            ]
            : null;

    final success = await MarketplaceService.createSellerListing(
      categoryId: selectedCategory!.id,
      title: titleController.text,
      size: sizeController.text,
      description: descriptionController.text,
      condition: condition,
      status: status,
      price: priceToSend,
      images: [frontImage!, sideImage!, backImage!],
      yards: yards, // ✅ New optional field
    );

    setState(() => isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Listing uploaded successfully")),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to upload listing")),
      );
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    sizeController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    lengthController.dispose();
    widthController.dispose();
    super.dispose();
  }

  Widget imagePickerCard(String label, File? image, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child:
            image == null
                ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_a_photo, size: 30, color: Colors.grey),
                      const SizedBox(height: 5),
                      Text(label, style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
                : ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(image, fit: BoxFit.cover),
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const CustomText(
            "List Item",
            color: Colors.white,
            fontSize: 18,
          ),
          backgroundColor: Colors.purple,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ✅ Select Type (Attire or Material)
              CustomDropdown(
                label: "Listing Type",
                options: const ["Attire", "Material"],
                selectedValue: listingType,
                onChanged:
                    (val) => setState(() => listingType = val ?? "Attire"),
              ),
              const SizedBox(height: 16),

              CustomDropdown(
                label: "Select Category",
                options: categories.map((c) => c.name).toList(),
                selectedValue: selectedCategory?.name,
                onChanged: (val) {
                  setState(() {
                    selectedCategory = categories.firstWhere(
                      (c) => c.name == val,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                title: "Title",
                hintText: "Enter product title",
                fieldKey: "title",
                controller: titleController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                title: "Size",
                hintText: "e.g. M, L, XL",
                fieldKey: "size",
                controller: sizeController,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                title: "Price",
                hintText: "Enter price (0 if free)",
                fieldKey: "price",
                controller: priceController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 4),
              const Text(
                "💡 Enter 0 if this item is listed for free",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                title: "Description",
                hintText: "Describe the item",
                fieldKey: "description",
                controller: descriptionController,
              ),
              const SizedBox(height: 16),

              /// ✅ Show yard fields only for Materials
              if (listingType == "Material") ...[
                CustomTextField(
                  title: "Length (yards)",
                  hintText: "Enter length in yards",
                  fieldKey: "length",
                  controller: lengthController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  title: "Width (yards)",
                  hintText: "Enter width in yards",
                  fieldKey: "width",
                  controller: widthController,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              CustomDropdown(
                label: "Condition",
                options: const ["Newly", "Preloved", "Newly Sewed"],
                selectedValue: condition,
                onChanged:
                    (val) => setState(() => condition = val ?? "Newly Sewed"),
              ),
              const SizedBox(height: 16),

              CustomDropdown(
                label: "Status",
                options: const ["Available", "Incoming", "For Sales"],
                selectedValue: status,
                onChanged: (val) => setState(() => status = val ?? "Available"),
              ),
              const SizedBox(height: 20),

              CustomText(
                "Upload Images",
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  imagePickerCard(
                    "Front",
                    frontImage,
                    () => pickImage("front"),
                  ),
                  imagePickerCard("Side", sideImage, () => pickImage("side")),
                  imagePickerCard("Back", backImage, () => pickImage("back")),
                ],
              ),

              const SizedBox(height: 30),
              CustomButton(title: "Upload Listing", onPressed: _submitListing),
            ],
          ),
        ),
      ),
    );
  }
}
