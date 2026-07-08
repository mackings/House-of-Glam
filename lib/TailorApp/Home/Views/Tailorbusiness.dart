import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/Legal/Views/legal_document_view.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Api/business.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
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

  Widget _buildTermsConsent(BuildContext context) {
    final baseStyle =
        Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.subtext,
          height: 1.5,
        ) ??
        const TextStyle(color: AppColors.subtext, fontSize: 12, height: 1.5);
    final linkStyle = baseStyle.copyWith(
      color: AppColors.accent,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.accent,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text.rich(
        TextSpan(
          style: baseStyle,
          children: [
            const TextSpan(
              text: "By submitting, you agree to House of GLAME's ",
            ),
            TextSpan(
              text: "Designer Terms",
              style: linkStyle,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => Nav.push(
                      context,
                      const LegalDocumentPage(slug: "designer-terms"),
                    ),
            ),
            const TextSpan(text: " and "),
            TextSpan(
              text: "Privacy Policy",
              style: linkStyle,
              recognizer:
                  TapGestureRecognizer()
                    ..onTap = () => Nav.push(
                      context,
                      const LegalDocumentPage(slug: "privacy-policy"),
                    ),
            ),
            const TextSpan(text: "."),
          ],
        ),
      ),
    );
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
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
        businessRegNo:
            _isRegisteredBusiness ? businessRegNoController.text.trim() : null,
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
          backgroundColor: AppColors.accent,
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
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentDeep],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
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
                      "Set Up Your Business Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Provide your business details to start receiving orders globally.",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Business Information Section
              _buildSectionCard(
                title: "Business Information",
                subtitle:
                    "This helps customers trust your brand and increases your visibility.",
                icon: Icons.store,
                children: [
                  CustomTextField(
                    title: "Business Name",
                    helperText:
                        "This is how customers will identify your brand.",
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
                    helperText:
                        "Used for orders, payouts, and important updates.",
                    hintText: "Enter your business email",
                    fieldKey: "businessEmail",
                    controller: businessEmailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Business email is required";
                      }
                      if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value)) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    title: "Business Phone",
                    helperText: "Improves communication and order coordination",
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
                title: "Business Location & Coverage",
                subtitle:
                    "Helps match you with nearby and international customers.",
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
                title: "Your Expertise",
                subtitle: "Improves your chances of receiving relevant orders.",
                icon: Icons.work_outline,
                children: [
                  CustomTextField(
                    title: "Your experience in fashion design",
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
                    title: "Brand Overview",
                    helperText:
                        "This helps customers understand your style and choose you confidently.",
                    hintText: "Describe your design services and specialties",
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
                      color: AppColors.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<bool>(
                          title: Row(
                            children: const [
                              Icon(
                                Icons.verified,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Verified Business Entity",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(left: 28, top: 4),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Registered and legally recognized business.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 14,
                                      color: AppColors.accent,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "Verified designers get higher visibility.",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.subtext,
                                          height: 1.35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          value: true,
                          groupValue: _isRegisteredBusiness,
                          activeColor: AppColors.accent,
                          onChanged: (val) {
                            setState(() => _isRegisteredBusiness = val!);
                          },
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.accent.withValues(alpha: 0.18),
                        ),
                        RadioListTile<bool>(
                          title: Row(
                            children: const [
                              Icon(
                                Icons.person_outline,
                                color: AppColors.accent,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Independent Designer",
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                          subtitle: const Padding(
                            padding: EdgeInsets.only(left: 28, top: 4),
                            child: Text(
                              "Operating as an individual without formal registration.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          value: false,
                          groupValue: _isRegisteredBusiness,
                          activeColor: AppColors.accent,
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
                    child:
                        _isRegisteredBusiness
                            ? _buildRegisteredBusinessSection()
                            : _buildUnregisteredBusinessSection(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.public_rounded,
                        size: 14,
                        color: AppColors.subtext,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Trusted by global customers.",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.subtext,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withValues(alpha: 0.14),
                  ),
                ),
                child: const Text(
                  "🎯 Verified profiles receive up to 3x more customer requests.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTermsConsent(context),
              CustomButton(
                title: "Submit Registration",
                isOutlined: false,
                onPressed: _submitForm,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.lock_outline, size: 15, color: AppColors.subtext),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "Your information is securely processed and protected.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.subtext,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
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
    String? subtitle,
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
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.subtext,
                height: 1.45,
              ),
            ),
          ],
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
            if (_isRegisteredBusiness &&
                (value == null || value.trim().isEmpty)) {
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
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.lock_outline, size: 16, color: AppColors.subtext),
            SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Secure verification process.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Your documents are encrypted and used strictly for compliance.",
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.subtext,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        child:
            _selectedImage != null
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
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.accent,
                      ),
                    ),
                  ],
                )
                : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: AppColors.accent,
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
