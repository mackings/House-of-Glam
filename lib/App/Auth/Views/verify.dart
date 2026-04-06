import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/authclass.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/components/authShell.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/dialogs.dart';
import 'package:hog/components/loadingoverlay.dart';
import 'package:hog/components/tokenfields.dart';

class Verify extends ConsumerStatefulWidget {
  const Verify({super.key});

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

    if (!mounted) {
      return;
    }

    if (response["success"]) {
      await showSuccessDialog(context, "Account verified successfully!");
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
        eyebrow: 'Email verification',
        title: 'Confirm your account before you enter the app.',
        subtitle:
            'Use the 4-digit code sent to your email to activate your profile and continue.',
        showBackButton: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Verification code",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            const Text(
              "We've sent a code to your email address.",
              style: TextStyle(height: 1.5, color: Color(0xFF686271)),
            ),
            const SizedBox(height: 24),
            FourDigitInput(
              onCompleted: (code) {
                setState(() => enteredCode = code);
              },
            ),
            const SizedBox(height: 26),
            CustomButton(
              title: "Verify account",
              onPressed: _handleVerification,
            ),
          ],
        ),
      ),
    );
  }
}
