import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Views/resetpassword.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends ConsumerState<ForgotPassword> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Forgot password", enableAction: false),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                SizedBox(height: 30),

                CustomText(
                  "Enter your email to receive a password reset Token",
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 30),
                CustomTextField(
                  title: "Email",
                  hintText: "Enter password",
                  fieldKey: "Email",
                ),

                SizedBox(height: 420),

                CustomButton(
                  title: "Continue",
                  onPressed: () {
                    Nav.push(context, Resetpassword());
                  },
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
