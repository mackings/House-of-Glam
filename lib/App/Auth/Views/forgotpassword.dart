import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/resetpassword.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/authShell.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();

    setState(() => isLoading = true);
    final response = await ApiService.forgotPassword(email: email);
    setState(() => isLoading = false);

    if (!mounted) {
      return;
    }

    if (response["success"]) {
      await showSuccessDialog(
        context,
        "Password reset token sent to your email",
      );
      if (!mounted) {
        return;
      }
      Nav.push(context, Resetpassword(email: email));
    } else {
      await showErrorDialog(context, response["error"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: AuthShell(
        eyebrow: 'Recovery',
        title: 'Reset access without losing your progress.',
        subtitle:
            'We will send a verification token to your email so you can choose a new password securely.',
        showBackButton: true,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Forgot password",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              const Text(
                "Enter the email attached to your account to continue.",
                style: TextStyle(height: 1.5, color: Color(0xFF686271)),
              ),
              const SizedBox(height: 22),
              CustomTextField(
                title: "Email address",
                hintText: "name@example.com",
                fieldKey: "forgot_email",
                controller: emailController,
                prefixIcon: Icons.mail_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Email is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              CustomButton(
                title: "Continue",
                onPressed: _handleForgotPassword,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
