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
  bool isLoading = false;
  bool _isRegisteredBusiness = true;

  @override
  void dispose() {
    addressController.dispose();
    businessNameController.dispose();
    businessEmailController.dispose();
    businessPhoneController.dispose();
    cityController.dispose();
    stateController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    businessRegNoController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error picking image: $e")),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all required fields"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate image for registered businesses
    if (_isRegisteredBusiness && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please upload your business registration document"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await TailorHomeService().createTailor(
        address: addressController.text.trim(),
        businessName: businessNameController.text.trim(),
        businessEmail: businessEmailController.text.trim(),
        businessPhone: businessPhoneController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        yearOfExperience: yearController.text.trim(),
        description: descriptionController.text.trim(),
        imageFile: _selectedImage,
        businessRegNo: _isRegisteredBusiness ? businessRegNoController.text.trim() : null,
      );

      setState(() => isLoading = false);

      if (mounted) {
        await showSuccessDialog(
          context,
          "Business registration submitted successfully! Your application is under review.",
        );

        Nav.pushReplacement(context, Signin());
      }
    } catch (e) {
      setState(() => isLoading = false);

      if (mounted) {
        await showErrorDialog(
          context,
          "Error submitting registration: ${e.toString().replaceAll('Exception:', '').trim()}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: Colors.purple,
          title: const CustomText(
            "Business Registration",
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade400, Colors.purple.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.business_center, color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text(
                      "Register Your Tailoring Business",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Join our network of professional tailors and grow your business",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Business Information Section
              _buildSectionCard(
                title: "Business Information",
                icon: Icons.store,
                children: [
                  CustomTextField(
                    title: "Business Name",
                    hintText: "Enter your business name",
                    fieldKey: "businessName",
                    controller: businessNameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Business name is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: "Business Email",
                    hintText: "Enter your business email",
                    fieldKey: "businessEmail",
                    controller: businessEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Business email is required";
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: "Business Phone",
                    hintText: "Enter your business phone number",
                    fieldKey: "businessPhone",
                    controller: businessPhoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Business phone is required";
                      }
                      if (value.trim().length < 10) {
                        return "Please enter a valid phone number";
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Location Section
              _buildSectionCard(
                title: "Business Location",
                icon: Icons.location_on,
                children: [
                  CustomTextField(
                    title: "Address",
                    hintText: "Enter your full business address",
                    fieldKey: "address",
                    controller: addressController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Address is required";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          title: "City",
                          hintText: "Enter city",
                          fieldKey: "city",
                          controller: cityController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "City is required";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomTextField(
                          title: "State",
                          hintText: "Enter state",
                          fieldKey: "state",
                          controller: stateController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "State is required";
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Professional Details Section
              _buildSectionCard(
                title: "Professional Details",
                icon: Icons.work_outline,
                children: [
                  CustomTextField(
                    title: "Years of Experience",
                    hintText: "Enter number of years",
                    fieldKey: "yearOfExperience",
                    controller: yearController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Years of experience is required";
                      }
                      final years = int.tryParse(value);
                      if (years == null || years < 0) {
                        return "Please enter a valid number";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: "Description",
                    hintText: "Describe your tailoring services and specialties",
                    fieldKey: "description",
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Description is required";
                      }
                      if (value.trim().length < 20) {
                        return "Please provide a more detailed description (min 20 characters)";
                      }
                      return null;
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Registration Status Section
              _buildSectionCard(
                title: "Registration Status",
                icon: Icons.assignment,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.purple.shade100),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: Row(
                            children: const [
                              Icon(Icons.verified, color: Colors.purple, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Registered Business",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(left: 28, top: 4),
                            child: Text(
                              "I have official business registration",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ),
                          value: true,
                          groupValue: _isRegisteredBusiness,
                          activeColor: Colors.purple,
                          onChanged: (val) {
                            setState(() => _isRegisteredBusiness = val!);
                          },
                        ),
                        Divider(height: 1, color: Colors.purple.shade100),
                        RadioListTile<bool>(
                          title: Row(
                            children: const [
                              Icon(Icons.person_outline, color: Colors.purple, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Not Registered",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(left: 28, top: 4),
                            child: Text(
                              "Individual tailor without registration",
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
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
                  ),

                  const SizedBox(height: 20),

                  // Conditional Fields
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isRegisteredBusiness
                        ? _buildRegisteredBusinessSection()
                        : _buildUnregisteredBusinessSection(),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              CustomButton(
                title: "Submit Registration",
                isOutlined: false,
                onPressed: _submitForm,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
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
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.purple, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRegisteredBusinessSection() {
    return Column(
      key: const ValueKey('registered'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          title: "Business Registration Number",
          hintText: "Enter your registration number",
          fieldKey: "businessRegNo",
          controller: businessRegNoController,
          keyboardType: TextInputType.text,
          validator: (value) {
            if (_isRegisteredBusiness && (value == null || value.trim().isEmpty)) {
              return "Registration number is required for registered businesses";
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        const Text(
          "Upload Registration Document",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Please upload a clear copy of your business registration certificate",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        _buildImagePicker(),
      ],
    );
  }

  Widget _buildUnregisteredBusinessSection() {
    return Column(
      key: const ValueKey('unregistered'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: const [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "No business registration required. We recommend getting registered for better credibility.",
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          "Upload Business Logo (Optional)",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Upload your business logo to help customers recognize your brand",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        _buildImagePicker(),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedImage != null ? Colors.green : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: _selectedImage != null
            ? Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Document uploaded successfully",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text("Change Document"),
                    style: TextButton.styleFrom(foregroundColor: Colors.purple),
                  ),
                ],
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      size: 40,
                      color: Colors.purple.shade300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tap to upload document",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "PNG, JPG up to 5MB",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
      ),
    );
  }
}
