import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/components/tokenfields.dart';



class Verify extends ConsumerStatefulWidget {
  const Verify({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _VerifyState();
}

class _VerifyState extends ConsumerState<Verify> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
  title: "Verification",
  enableAction: false,
),


      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 20,right: 20),
              child: Column(
                children: [

                  SizedBox(height: 20,),

                  CustomText("We've sent a 4 didgt code to your email",fontSize: 20,),

                  SizedBox(height: 40,),
                
              FourDigitInput(
                onCompleted: (code) {
                  print("Entered 4-digit code: $code");
                },
              ),

               SizedBox(height: 420,),



              CustomButton(title: "Verify", onPressed: (){})


              
              
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

