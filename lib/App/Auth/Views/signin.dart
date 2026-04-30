import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/auth_choice.dart';
import 'package:hog/App/Auth/Views/forgotpassword.dart';
import 'package:hog/App/Admin/Views/adminHome.dart';
import 'package:hog/TailorApp/TailorMain.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/authShell.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/index.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Signin extends ConsumerStatefulWidget {
  final String? initialEmail;

  const Signin({super.key, this.initialEmail});

  @override
  ConsumerState<Signin> createState() => _SigninState();
}

class _SigninState extends ConsumerState<Signin> {
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    if ((widget.initialEmail ?? '').trim().isNotEmpty) {
      emailController.text = widget.initialEmail!.trim();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);
    final response = await ApiService.login(email: email, password: password);
    setState(() => isLoading = false);

    if (!mounted) {
      return;
    }

    if (response["success"] == true && response["token"] != null) {
      final token = response["token"];
      final user = response["user"];

      await SecurePrefs.saveLastEmail(email);

      if (rememberMe && token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", token);
      }

      if (!mounted) {
        return;
      }

      await showSuccessDialog(
        context,
        response["message"] ?? "Login successful!",
      );

      if (!mounted) {
        return;
      }

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
      } else if (user != null &&
          ((user["role"] ?? '').toString().toLowerCase() == "admin" ||
              (user["role"] ?? '').toString().toLowerCase() == "superadmin")) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminHome()),
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
      child: AuthShell(
        eyebrow: 'Welcome Back',
        title: 'Access Your House of GLAME Account.',
        subtitle:
            'Access your custom orders, quote approvals, delivery tracking, and curated fashion collections.',
        highlights: const [
          'Manage Quotes',
          'Track Orders',
          'Explore Pre-Loved',
        ],
        footer: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CustomText(
              "New here? ",
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => const AuthChoiceScreen(showBackButton: true),
                  ),
                );
              },
              child: const CustomText(
                "Create account",
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
                "Account Access",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                "Use the email and password linked to your House of GLAME profile.",
                style: TextStyle(color: AppColors.subtext, height: 1.5),
              ),
              if (emailController.text.trim().isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.mark_email_read_outlined,
                          size: 18,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: CustomText(
                          "Your last email is already filled in so you can continue your fashion journey quickly.",
                          fontSize: 12,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
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
                title: "Password",
                hintText: "Enter your password",
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
                fieldKey: "password",
                controller: passwordController,
                autofocus: (widget.initialEmail ?? '').trim().isNotEmpty,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() => rememberMe = !rememberMe);
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() => rememberMe = value ?? false);
                            },
                          ),
                          const Flexible(
                            child: CustomText(
                              "Remember me",
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Nav.push(context, const ForgotPassword());
                    },
                    child: const CustomText(
                      "Forgot password?",
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomButton(title: "Sign In", onPressed: _handleSignin),
            ],
          ),
        ),
      ),
    );
  }
}
