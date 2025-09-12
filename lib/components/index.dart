import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/Orders/OrderHistory.dart';
import 'package:hog/App/Home/Views/Orders/Placeorder.dart';
import 'package:hog/App/Home/Views/allreviews.dart';
import 'package:hog/App/Home/Views/dashboard.dart';
import 'package:hog/components/navbar.dart';



class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Home(), 
    PlaceOrder(),
    OrderHistory(),
    AllReviews()

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
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
