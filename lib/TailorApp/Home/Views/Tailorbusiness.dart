import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Api/business.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:image_picker/image_picker.dart';

class TailorRegistrationPage extends StatefulWidget {
  @override
  State<TailorRegistrationPage> createState() => _TailorRegistrationPageState();
}

class _TailorRegistrationPageState extends State<TailorRegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  final addressController = TextEditingController();
  final businessNameController = TextEditingController();
  final businessEmailController = TextEditingController();
  final businessPhoneController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final yearController = TextEditingController();
  final descriptionController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false; // 🔹 for overlay

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);
    try {
      await TailorHomeService().createTailor(
        address: addressController.text,
        businessName: businessNameController.text,
        businessEmail: businessEmailController.text,
        businessPhone: businessPhoneController.text,
        city: cityController.text,
        state: stateController.text,
        yearOfExperience: yearController.text,
        description: descriptionController.text,
        imageFile: _selectedImage,
      );

      setState(() => isLoading = false);

      await showSuccessDialog(
        context,
        "Business Registration submitted successfully!",
      );

      Nav.pushReplacement(context, Signin());
    } catch (e) {
      setState(() => isLoading = false);

      await showErrorDialog(context, "❌ Error submitting registration: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: Colors.purple,
          title: const CustomText(
            "Business Registration",
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                CustomTextField(
                  title: "Business Name",
                  hintText: "Enter your business name",
                  fieldKey: "businessName",
                  controller: businessNameController,
                ),
                CustomTextField(
                  title: "Business Email",
                  hintText: "Enter your business email",
                  fieldKey: "businessEmail",
                  controller: businessEmailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  title: "Business Phone",
                  hintText: "Enter your business phone number",
                  fieldKey: "businessPhone",
                  controller: businessPhoneController,
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  title: "Address",
                  hintText: "Enter your full address",
                  fieldKey: "address",
                  controller: addressController,
                ),
                CustomTextField(
                  title: "City",
                  hintText: "Enter your city",
                  fieldKey: "city",
                  controller: cityController,
                ),
                CustomTextField(
                  title: "State",
                  hintText: "Enter your state",
                  fieldKey: "state",
                  controller: stateController,
                ),
                CustomTextField(
                  title: "Years of Experience",
                  hintText: "Enter number of years of tailoring experience",
                  fieldKey: "yearOfExperience",
                  controller: yearController,
                  keyboardType: TextInputType.number,
                ),
                CustomTextField(
                  title: "Description",
                  hintText: "Briefly describe your tailoring services",
                  fieldKey: "description",
                  controller: descriptionController,
                  keyboardType: TextInputType.multiline,
                ),

                const SizedBox(height: 16),

                // Image Picker
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload),
                      label: const Text("Add Business Logo"),
                    ),
                    const SizedBox(width: 12),
                    if (_selectedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImage!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      const Text(
                        "No logo selected",
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                CustomButton(
                  title: "Submit",
                  isOutlined: false,
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
