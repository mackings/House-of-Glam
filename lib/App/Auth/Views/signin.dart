import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Views/forgotpassword.dart';
import 'package:hog/App/Home/Views/dashboard.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/alerts.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/index.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/navcontroller.dart';

class Signin extends ConsumerStatefulWidget {
  const Signin({super.key});

  @override
  ConsumerState<Signin> createState() => _SigninState();
}

class _SigninState extends ConsumerState<Signin> {
  bool rememberMe = false;
  late TextEditingController emailController;
  late TextEditingController passwordController;

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

  void _handleSignin() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Signing in as $email")));
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
                    child: CustomText("Forgot password"),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              CustomButton(
                title: "Login",
                isOutlined: false,
                onPressed: () {
                  TopAlert.show(
                    context,
                    title: "Heads up",
                    message: "Login successful",
                    type: TopAlertType.info,
                  );
                  NavigationController.push(MainPage());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
