import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    final password = passwordController.text.trim();

    if (token == null || token!.isEmpty) {
      await showErrorDialog(context, "Please enter the 4-digit token");
      return;
    }

    if (password.isEmpty) {
      await showErrorDialog(context, "Please enter your new password");
      return;
    }

    setState(() => isLoading = true);

    final response = await ApiService.resetPassword(
      token: token!,
      password: password,
    );

    setState(() => isLoading = false);

    if (response["success"]) {
      await showSuccessDialog(context, "Password reset successfully!");
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
      child: Scaffold(
        appBar: CustomAppBar(title: "Reset Password", enableAction: false),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),
                const CustomText(
                  "Enter the token sent to your email and choose a new password",
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                FourDigitInput(
                  onCompleted: (code) {
                    setState(() => token = code);
                  },
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  title: "New Password",
                  hintText: "Enter new password",
                  fieldKey: "password",
                  isPassword: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 50),
                CustomButton(
                  title: "Update Password",
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
