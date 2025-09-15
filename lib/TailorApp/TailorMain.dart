import 'package:flutter/material.dart';
import 'package:hog/TailorApp/TailorNav.dart';

class TailorMainPage extends StatefulWidget {
  const TailorMainPage({Key? key}) : super(key: key);

  @override
  State<TailorMainPage> createState() => _TailorMainPageState();
}

class _TailorMainPageState extends State<TailorMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [

  

  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex], 
      bottomNavigationBar: TailorCustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
