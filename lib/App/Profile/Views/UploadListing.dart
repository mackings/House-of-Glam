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

  final NumberFormat _formatter = NumberFormat('#,###'); // ✅ for display
  bool _isFormatting = false; // ✅ avoid recursion in listener

  // ✅ Separate image slots
  File? frontImage;
  File? sideImage;
  File? backImage;

  final ImagePicker _picker = ImagePicker();

  String condition = "Newly Sewed";
  String status = "Available";
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();

    // ✅ Add listener to format price with commas
    priceController.addListener(() {
      if (_isFormatting) return;
      _isFormatting = true;

      // Remove all commas
      String raw = priceController.text.replaceAll(',', '');

      // ✅ If user cleared the field, just clear it
      if (raw.isEmpty) {
        priceController.value = TextEditingValue(
          text: '',
          selection: const TextSelection.collapsed(offset: 0),
        );
        _isFormatting = false;
        return;
      }

      // ✅ Parse and format
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
    setState(() {
      categories = cachedCategories;
    });
  }

  /// ✅ Pick specific image slot
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
        sizeController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        priceController.text.isEmpty ||
        frontImage == null ||
        sideImage == null ||
        backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all fields and upload all 3 required images.",
          ),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    // ✅ Remove commas before sending
    final rawPrice = priceController.text.replaceAll(',', '');
    final priceToSend = double.tryParse(rawPrice) ?? 0;

    final success = await MarketplaceService.createSellerListing(
      categoryId: selectedCategory!.id,
      title: titleController.text,
      size: sizeController.text,
      description: descriptionController.text,
      condition: condition,
      status: status,
      price: priceToSend, // ✅ raw number
      images: [frontImage!, sideImage!, backImage!],
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
    super.dispose();
  }

  /// ✅ Reusable image picker card
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
              /// Category Dropdown
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

              /// ✅ Price Field with hint
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

              CustomDropdown(
                label: "Condition",
                options: const ["Newly", "Preloved","Newly Sewed"],
                selectedValue: condition,
                onChanged:
                    (val) => setState(() => condition = val ?? "Newly Sewed"),
              ),
              const SizedBox(height: 16),

              CustomDropdown(
                label: "Status",
                options: const ["Available", "Incoming"],
                selectedValue: status,
                onChanged: (val) => setState(() => status = val ?? "Available"),
              ),
              const SizedBox(height: 20),

              /// ✅ Image Picker
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
