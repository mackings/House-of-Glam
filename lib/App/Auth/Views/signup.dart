import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/components/alerts.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
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
  late TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    fullnameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    final fullname = fullnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (fullname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Creating account for $fullname")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Title
              Text(
                "Sign Up",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 30),

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
                title: "Password",
                hintText: "Enter your password",
                prefixIcon: Icons.lock,
                isPassword: true,
                fieldKey: "password",
                controller: passwordController,
              ),

              CustomTextField(
                title: "Confirm Password",
                hintText: "Re-enter your password",
                prefixIcon: Icons.lock,
                isPassword: true,
                fieldKey: "confirm_password",
                controller: confirmPasswordController,
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
                  GestureDetector(
                    onTap: () {

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const Signin()),
                      );
                    },
                    child: CustomText(
                      "Login",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
