import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/components/tokenfields.dart';



class Verify extends ConsumerStatefulWidget {

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VerifyState();
}

class _VerifyState extends ConsumerState<Verify> {
  String? enteredCode;
  bool isLoading = false;

Future<void> _handleVerification() async {
  if (enteredCode == null || enteredCode!.isEmpty) {
    await showErrorDialog(context, "Please enter the 4-digit code");
    return;
  }

  setState(() => isLoading = true);

  final response = await ApiService.verifyEmail(token: enteredCode!);

  setState(() => isLoading = false);

  if (response["success"]) {
    await showSuccessDialog(context, "Account verified successfully!");
    // Navigate to Signin page
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
        appBar: CustomAppBar(title: "Verification", enableAction: false),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const CustomText(
                      "We've sent a 4-digit code to your email",
                      fontSize: 20,
                    ),
                    const SizedBox(height: 40),

                    FourDigitInput(
                      onCompleted: (code) {
                        setState(() => enteredCode = code);
                        print("Entered 4-digit code: $code");
                      },
                    ),

                    const SizedBox(height: 420),

                    CustomButton(
                      title: "Verify",
                      onPressed: _handleVerification,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

