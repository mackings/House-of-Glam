import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/Auth/widgets/password_requirements.dart';
import 'package:hog/components/authShell.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/tokenfields.dart';

class Resetpassword extends ConsumerStatefulWidget {
  final String email;

  const Resetpassword({super.key, required this.email});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends ConsumerState<Resetpassword> {
  String? token;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _passwordValidationError(String password) {
    if (password.isEmpty) {
      return "Please enter your new password";
    }
    if (password.length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "Password must contain at least one uppercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "Password must contain at least one number";
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return "Password must contain at least one special character";
    }
    return null;
  }

  Future<void> _handleResetPassword() async {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text;

    if (token == null || token!.isEmpty) {
      await showErrorDialog(context, "Please enter the 4-digit token");
      return;
    }

    final passwordError = _passwordValidationError(password);
    if (passwordError != null) {
      await showErrorDialog(context, passwordError);
      return;
    }

    if (confirmPassword.isEmpty) {
      await showErrorDialog(context, "Please confirm your new password");
      return;
    }

    if (confirmPassword != passwordController.text) {
      await showErrorDialog(context, "Passwords do not match");
      return;
    }

    setState(() => isLoading = true);
    final response = await ApiService.resetPassword(
      token: token!,
      password: password,
    );
    setState(() => isLoading = false);

    if (!mounted) {
      return;
    }

    if (response["success"]) {
      await showSuccessDialog(context, "Password reset successfully!");
      if (!mounted) {
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Signin()),
      );
    } else {
      await showErrorDialog(context, response["error"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: AuthShell(
        eyebrow: 'Create a New Password',
        title: 'Set a fresh password for House of GLAME.',
        subtitle:
            'Enter the code sent to ${widget.email} and choose a strong new password for your account.',
        showBackButton: true,
        highlights: const ['Verified Access', 'Secure Password Reset'],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Reset Password",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              "Use the code from your email, then create a new secure password.",
              style: TextStyle(height: 1.5, color: Color(0xFF686271)),
            ),
            const SizedBox(height: 24),
            FourDigitInput(
              onCompleted: (code) {
                setState(() => token = code);
              },
            ),
            const SizedBox(height: 20),
            CustomTextField(
              title: "New password",
              hintText: "Enter new password",
              fieldKey: "reset_password",
              isPassword: true,
              prefixIcon: Icons.lock_outline_rounded,
              controller: passwordController,
              onChanged: (_) => setState(() {}),
            ),
            PasswordRequirements(
              password: passwordController.text,
              confirmPassword: confirmPasswordController.text,
            ),
            CustomTextField(
              title: "Confirm new password",
              hintText: "Re-enter new password",
              fieldKey: "reset_confirm_password",
              isPassword: true,
              validatePasswordRules: false,
              prefixIcon: Icons.lock_outline_rounded,
              controller: confirmPasswordController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),
            CustomButton(
              title: "Update password",
              onPressed: _handleResetPassword,
            ),
          ],
        ),
      ),
    );
  }
}
