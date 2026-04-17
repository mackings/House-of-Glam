import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/Auth/Views/verify.dart';
import 'package:hog/TailorApp/Home/Views/Tailorbusiness.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/authShell.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController addressController;
  late TextEditingController countryController;

  bool isLoading = false;
  String selectedCountryCode = '+234';

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    addressController = TextEditingController();
    countryController = TextEditingController();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    countryController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formattedPhone = '$selectedCountryCode${phoneController.text.trim()}';

    setState(() => isLoading = true);

    final response = await ApiService.signup(
      fullName: fullnameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      phoneNumber: formattedPhone,
      address: addressController.text.trim(),
      country: countryController.text.trim(),
      role: "user",
    );

    setState(() => isLoading = false);

    if (!mounted) {
      return;
    }

    if (response["success"]) {
      await SecurePrefs.saveLastEmail(emailController.text.trim());
      if (!mounted) {
        return;
      }
      await showSuccessDialog(context, "Account created successfully!");
      if (!mounted) {
        return;
      }
      Nav.push(context, Verify());
    } else {
      await showErrorDialog(context, response["error"]);
    }
  }

  Widget _buildCountryPickerField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Country",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: countryController,
          readOnly: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select a country';
            }
            return null;
          },
          decoration: const InputDecoration(
            hintText: "Select country",
            prefixIcon: Icon(Icons.public_rounded),
            suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
          ),
          onTap: () {
            showCountryPicker(
              context: context,
              showSearch: true,
              countryListTheme: CountryListThemeData(
                borderRadius: BorderRadius.circular(22),
                inputDecoration: const InputDecoration(
                  hintText: "Search country",
                  prefixIcon: Icon(Icons.search),
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
              onSelect: (Country country) {
                setState(() {
                  countryController.text = country.name;
                });
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: AuthShell(
        eyebrow: 'Join House of GLAME',
        title: 'Create your account',
        subtitle:
            'Join House of GLAME and step into a world of culture, creativity, and style.',
        highlights: const [
          'Custom Orders',
          'Delivery Tracking',
          'Pre-Loved Discovery',
        ],
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomText(
              "Already have an account? ",
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Signin()),
                );
              },
              child: const CustomText(
                "Sign in",
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Customer Profile",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                "Tell us who you are so we can personalise your couture journey.",
                style: TextStyle(color: AppColors.subtext, height: 1.5),
              ),
              const SizedBox(height: 22),
              CustomTextField(
                title: "Full name",
                hintText: "Enter your full name",
                prefixIcon: Icons.person_outline_rounded,
                fieldKey: "fullname",
                controller: fullnameController,
                keyboardType: TextInputType.name,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full name is required';
                  }
                  return null;
                },
              ),
              CustomTextField(
                title: "Email address",
                hintText: "name@example.com",
                prefixIcon: Icons.mail_outline_rounded,
                fieldKey: "email",
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              CustomTextField(
                title: "Phone number",
                hintText: "Enter your phone number",
                prefixIcon: Icons.call_outlined,
                fieldKey: "phone",
                controller: phoneController,
                keyboardType: TextInputType.phone,
                enableCountryCode: true,
                useGlobalCountryPicker: true,
                selectedCountryCode: selectedCountryCode,
                onCountryChanged: (code) {
                  setState(() {
                    selectedCountryCode = code ?? '+234';
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  return null;
                },
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 640;
                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: "Address",
                            hintText: "Enter address",
                            prefixIcon: Icons.home_outlined,
                            fieldKey: "address",
                            controller: addressController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Address is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: _buildCountryPickerField(context)),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      CustomTextField(
                        title: "Address",
                        hintText: "Enter address",
                        prefixIcon: Icons.home_outlined,
                        fieldKey: "address",
                        controller: addressController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                      ),
                      _buildCountryPickerField(context),
                    ],
                  );
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                title: "Password",
                hintText: "Create a secure password",
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                fieldKey: "password",
                controller: passwordController,
              ),
              const SizedBox(height: 18),
              CustomButton(
                title: "Create My Account",
                onPressed: _handleSignup,
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () {
                  Nav.push(context, TailorRegistrationPage());
                },
                icon: const Icon(Icons.design_services_outlined),
                label: const Text("Apply as a Designer"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
