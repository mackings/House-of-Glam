import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class TailorDeliveries extends StatefulWidget {
  const TailorDeliveries({super.key});

  @override
  State<TailorDeliveries> createState() => _TailorDeliveriesState();
}

class _TailorDeliveriesState extends State<TailorDeliveries> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: CustomText("Deliverables",color: Colors.white,fontSize: 18,),
      ),
      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      )),
    );
  }
}