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
   final businessRegNoController = TextEditingController();

  File? _selectedImage;
  bool isLoading = false; // 🔹 for overlay

  // 🔹 New state for registered/consent section
  bool _isRegisteredBusiness = true;
  File? _businessDoc;
  File? _consentImage;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  // 🔹 New pickers
  Future<void> _pickBusinessDoc() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _businessDoc = File(picked.path));
    }
  }

  Future<void> _pickConsentImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _consentImage = File(picked.path));
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
        businessRegNo: _isRegisteredBusiness ? businessRegNoController.text : null,
        // You can later include _businessDoc / _consentImage if needed
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      label: const Text("Attach Registration Doc"),
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
                        "No Image seletcted",
                        style: TextStyle(color: Colors.grey),
                      ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔹 Business Registration Choice
                // Title
                const Row(
                  children: [
                    Icon(Icons.business_center, color: Colors.purple, size: 22),
                    SizedBox(width: 8),
                    Text(
                      "Business Registration",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Radio Options stacked vertically
                Column(
                  children: [
                    RadioListTile<bool>(
                      title: Row(
                        children: [
                          Icon(Icons.apartment, color: Colors.purple, size: 20),
                          SizedBox(width: 6),
                          Text("Registered Business"),
                        ],
                      ),
                      value: true,
                      groupValue: _isRegisteredBusiness,
                      activeColor: Colors.purple,
                      onChanged: (val) {
                        setState(() => _isRegisteredBusiness = val!);
                      },
                    ),
                    RadioListTile<bool>(
                      title: Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: Colors.purple,
                            size: 20,
                          ),
                          SizedBox(width: 6),
                          Text("Not Registered"),
                        ],
                      ),
                      value: false,
                      groupValue: _isRegisteredBusiness,
                      activeColor: Colors.purple,
                      onChanged: (val) {
                        setState(() => _isRegisteredBusiness = val!);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Conditional Sections
_isRegisteredBusiness
    ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.file_present, color: Colors.purple, size: 20),
              SizedBox(width: 6),
              Text(
                "Upload Business Registration Document",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 🔹 New Business Reg Number Input
          CustomTextField(
            title: "Business Reg Number",
            hintText: "Business Registration number",
            fieldKey: "businessRegNo",
            controller: businessRegNoController,
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Please enter your registration number";
              }
              return null;
            },
          ),
          const SizedBox(height: 10),

        ],
      )

                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Consent",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "My business is not registered yet and I agree to provide my business logo.",
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _pickConsentImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text("Upload Logo"),
                        ),
                        if (_consentImage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    "Selected: ${_consentImage!.path.split('/').last}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                const SizedBox(height: 24),

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
