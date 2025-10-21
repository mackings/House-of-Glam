import 'dart:convert';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/Auth/Views/verify.dart';
import 'package:hog/App/Auth/widgets/countryCodes.dart';
import 'package:hog/TailorApp/Home/Views/Tailorbusiness.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/alerts.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';



class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  late TextEditingController fullnameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController addressController;
  late TextEditingController countryController;

  bool isLoading = false;
  bool isTailor = false;

  List<String> countries = [];
  String? selectedCountry;

  // ✅ Track selected country code for phone
  String selectedCountryCode = '+234'; // default to Nigeria

  // Future<void> loadCountries() async {
  //   final String response = await rootBundle.loadString(
  //     'assets/countries.json',
  //   );
  //   final List<dynamic> data = json.decode(response);
  //   setState(() {
  //     countries = data.cast<String>();
  //   });
  // }

Future<void> loadCountries() async {
  final allCountries = CountryService().getAll();
  final names = allCountries.map((e) => e.name).toSet().toList(); 
  setState(() {
    countries = names;
  });
}


String _getCountryNameFromCode(String code) {
  try {
    final allCountries = CountryService().getAll();
    final cleanCode = code.replaceAll('+', '');
    final match = allCountries.firstWhere(
      (c) => c.phoneCode == cleanCode,
      orElse: () => allCountries.firstWhere((c) => c.countryCode == 'NG'), // fallback: Nigeria 🇳🇬
    );
    return match.name;
  } catch (e) {
    return 'Unknown';
  }
}



  @override
  void initState() {
    super.initState();
    loadCountries();
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
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final address = addressController.text.trim();
    final country = countryController.text.trim();

    if (fullname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        country.isEmpty ||
        address.isEmpty) {
      await showErrorDialog(context, "Please fill in all fields");
      return;
    }

    // ✅ Combine selected country code with phone number
    final formattedPhone = '$selectedCountryCode$phone';

    setState(() => isLoading = true);

    final response = await ApiService.signup(
      fullName: fullname,
      email: email,
      password: password,
      phoneNumber: formattedPhone, // ✅ send full phone with country code
      address: address,
      country: country,
      role: isTailor ? "tailor" : "user",
    );

    setState(() => isLoading = false);

    if (response["success"]) {
      await showSuccessDialog(context, "Account created successfully!");
      Nav.push(context, Verify());
    } else {
      await showErrorDialog(context, response["error"]);
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: 
Scaffold(
  backgroundColor: Colors.white,
  body: SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey, // ✅ attach form key here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            GestureDetector(
              onTap: () {
                Nav.push(context, TailorRegistrationPage());
              },
              child: CustomText(
                "Sign Up",
                fontWeight: FontWeight.w700,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 40),

            CustomTextField(
              title: "Full Name",
              hintText: "Enter your full name",
              prefixIcon: Icons.person,
              fieldKey: "fullname",
              controller: fullnameController,
              keyboardType: TextInputType.name,
            ),

            CustomTextField(
              title: "Email",
              hintText: "Enter your email",
              prefixIcon: Icons.email,
              fieldKey: "email",
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            // ✅ Phone field with global picker
            CustomTextField(
              title: "Phone",
              hintText: "Enter your phone number",
              prefixIcon: Icons.phone,
              fieldKey: "phone",
              controller: phoneController,
              keyboardType: TextInputType.phone,
              enableCountryCode: true,
              useGlobalCountryPicker: true,
              selectedCountryCode: selectedCountryCode,
              onCountryChanged: (code) {
                setState(() {
                  selectedCountryCode = code ?? '+234';
                  countryController.text = _getCountryNameFromCode(code ?? '+234');
                  selectedCountry = countryController.text;
                });
              },
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 600;

                if (isWideScreen) {
                  // 💻 Desktop / Tablet
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            title: "Address",
                            hintText: "Enter Address",
                            prefixIcon: Icons.house,
                            fieldKey: "address",
                            controller: addressController,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(
                            title: "Country",
                            hintText: "Select Country",
                            prefixIcon: Icons.public,
                            fieldKey: "country",
                            controller: countryController,
                           // readOnly: true, // ✅ prevent dropdown & overflow
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // 📱 Mobile Layout
                return Column(
                  children: [
                    CustomTextField(
                      title: "Address",
                      hintText: "Enter Address",
                      prefixIcon: Icons.house,
                      fieldKey: "address",
                      controller: addressController,
                    ),
                    CustomTextField(
                      title: "Country",
                      hintText: "Select Country",
                      prefixIcon: Icons.public,
                      fieldKey: "country",
                      controller: countryController,
                     // readOnly: true, // ✅ prevents overflow
                    ),
                  ],
                );
              },
            ),

            // 🔒 Password Field (validation included)
            CustomTextField(
              title: "Password",
              hintText: "Enter your password",
              prefixIcon: Icons.lock,
              isPassword: true,
              fieldKey: "password",
              controller: passwordController,
            ),

            Row(
              children: [
                Checkbox(
                  value: isTailor,
                  onChanged: (val) {
                    setState(() {
                      isTailor = val ?? false;
                    });
                    if (val == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Leave blank if you are not a tailor"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
                const CustomText("I'm a Designer"),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Validate before signup
            CustomButton(
              title: "Create Account",
              isOutlined: false,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _handleSignup(); // ✅ validation passed
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fix the errors')),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CustomText("Existing user? "),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const Signin()),
                    );
                  },
                  child: CustomText("Login", fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  ),
),
    );
  }
}
