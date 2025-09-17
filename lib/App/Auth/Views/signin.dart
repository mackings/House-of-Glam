import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/forgotpassword.dart';
import 'package:hog/TailorApp/TailorMain.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/index.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends ConsumerStatefulWidget {
  const Signin({super.key});

  @override
  ConsumerState<Signin> createState() => _SigninState();
}

class _SigninState extends ConsumerState<Signin> {
  bool rememberMe = false;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => isLoading = true);
    final response = await ApiService.login(email: email, password: password);
    setState(() => isLoading = false);

    print("🔎 Login response: $response");

    if (response["success"] == true) {
      final data = response["data"];
      final token = data["token"];
      final user = data["user"];

      if (rememberMe && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
      }

      await showSuccessDialog(context, data["message"] ?? "Login successful!");

      if (user != null && user["role"] == "tailor") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => TailorMainPage(
                  isVendorEnabled: user["isVendorEnabled"] ?? false,
                ),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
      }
    } else {
      await showErrorDialog(
        context,
        response["error"] ?? "Something went wrong",
      );
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 50.0,
            ),
            //padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Title
                Text(
                  "Sign In",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Email Field
                CustomTextField(
                  title: "Email",
                  hintText: "Enter your email",
                  prefixIcon: Icons.email,
                  fieldKey: "email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),

                CustomTextField(
                  title: "Password",
                  hintText: "Enter your password",
                  prefixIcon: Icons.lock,
                  isPassword: true,
                  fieldKey: "password",
                  controller: passwordController,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() {
                              rememberMe = value ?? false;
                            });
                          },
                          activeColor: Colors.black,
                        ),
                        const CustomText("Remember me"),
                      ],
                    ),

                    GestureDetector(
                      onTap: () {
                        Nav.push(context, ForgotPassword());
                      },
                      child: const CustomText("Forgot password"),
                    ),
                  ],
                ),

                const SizedBox(height: 50),

                CustomButton(
                  title: "Login",
                  isOutlined: false,
                  onPressed: _handleSignin,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
