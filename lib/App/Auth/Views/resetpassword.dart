import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/components/tokenfields.dart';




class Resetpassword extends ConsumerStatefulWidget {
  const Resetpassword({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ResetpasswordState();
}

class _ResetpasswordState extends ConsumerState<Resetpassword> {
  String? token; // store the entered token
  bool isTokenValid = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Reset Password", enableAction: false),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                CustomText(
                  "Enter Token and Enter a new strong password for your account",
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // 4-digit input
                FourDigitInput(
                  onCompleted: (code) {
                    setState(() {
                      token = code;
                      isTokenValid = code.length == 4; // enable if valid
                    });
                  },
                ),

                const SizedBox(height: 30),

                // Show password field only after token is valid
                if (isTokenValid) ...[
                  CustomTextField(
                    title: "Password",
                    hintText: "Enter new password",
                    fieldKey: "password",
                    isPassword: true,
                  ),

                  const SizedBox(height: 35),
                ],

                 const SizedBox(height: 290),

CustomButton(
  title: "Update Password",
  onPressed: () {
    if (!isTokenValid) return; 
    print("Updating password with token: $token");
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
