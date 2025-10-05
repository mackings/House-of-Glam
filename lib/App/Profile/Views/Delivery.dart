import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class MarketDelivery extends StatefulWidget {
  const MarketDelivery({super.key});

  @override
  State<MarketDelivery> createState() => _MarketDeliveryState();
}

class _MarketDeliveryState extends State<MarketDelivery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const CustomText("Complete Payment",color: Colors.white,fontSize: 18,),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
      ),

      body: SafeArea(child: SingleChildScrollView(
        child: Column(
          children: [],
        ),
      )),
    );
  }
}