import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';

class Uploadlisting extends StatefulWidget {
  const Uploadlisting({super.key});

  @override
  State<Uploadlisting> createState() => _UploadlistingState();
}

class _UploadlistingState extends State<Uploadlisting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomText("List Item",color: Colors.white,fontSize: 18,),
        backgroundColor: Colors.purple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
    );
  }
}