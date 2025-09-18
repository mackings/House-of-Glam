import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: CustomText("Subscription",fontSize: 18,color: Colors.white,),
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [
            
          ],
        ),
      )),
    );
  }
}