import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/resetpassword.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';




class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
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
    final email = emailController.text.trim();

    if (email.isEmpty) {
      await showErrorDialog(context, "Please enter your email");
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.forgotPassword(email: email);

    setState(() => isLoading = false);

    if (response["success"]) {
      await showSuccessDialog(context, "Password reset token sent to your email");
      // Navigate to reset password page and pass email
      Nav.push(context, Resetpassword(email: email));
    } else {
      await showErrorDialog(context, response["error"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        appBar: CustomAppBar(title: "Forgot password", enableAction: false),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const CustomText(
                  "Enter your email to receive a password reset token",
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  title: "Email",
                  hintText: "Enter email",
                  fieldKey: "Email",
                  controller: emailController,
                ),
                const SizedBox(height: 400),
                CustomButton(
                  title: "Continue",
                  onPressed: _handleForgotPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
