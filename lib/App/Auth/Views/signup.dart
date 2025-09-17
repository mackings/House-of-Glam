import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/Auth/Views/verify.dart';
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

  bool isLoading = false; // for loading overlay
  bool isTailor = false; // 👈 checkbox state

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final address = addressController.text.trim();

    if (fullname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        address.isEmpty) {
      await showErrorDialog(context, "Please fill in all fields");
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.signup(
      fullName: fullname,
      email: email,
      password: password,
      phoneNumber: phone,
      address: address,
      role: isTailor ? "tailor" : "user", // 👈 role depends on checkbox
    );

    setState(() => isLoading = false);

    if (response["success"]) {
      await showSuccessDialog(context, "Account created successfully!");
      Nav.push(context, Verify());
    } else {
      await showErrorDialog(context, response["error"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Title
                CustomText(
                  "Sign Up",
                  fontWeight: FontWeight.w700,
                  fontSize: 25,
                ),
                const SizedBox(height: 20),

                // Full Name Field
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

                CustomTextField(
                  title: "Phone",
                  hintText: "Enter your phone number",
                  prefixIcon: Icons.phone,
                  fieldKey: "phone",
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),

                CustomTextField(
                  title: "Address",
                  hintText: "Enter your Address",
                  prefixIcon: Icons.house,
                  fieldKey: "address",
                  controller: addressController,
                ),

                CustomTextField(
                  title: "Password",
                  hintText: "Enter your password",
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  fieldKey: "password",
                  controller: passwordController,
                ),

                // 👇 Checkbox for tailor role
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
                              content: Text(
                                "Leave blank if you are not a tailor",
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),
                    const CustomText("I'm a Tailor"),
                  ],
                ),

                const SizedBox(height: 20),

                CustomButton(
                  title: "Create Account",
                  isOutlined: false,
                  onPressed: _handleSignup,
                ),
                const SizedBox(height: 20),

                // Existing user? Login
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
    );
  }
}
