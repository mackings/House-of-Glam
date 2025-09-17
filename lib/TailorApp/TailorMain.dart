import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Views/AssignedMaterials.dart';
import 'package:hog/TailorApp/Home/Views/Deliveries.dart';
import 'package:hog/TailorApp/Home/Views/Myworks.dart';
import 'package:hog/TailorApp/Home/Views/Publish.dart';
import 'package:hog/TailorApp/Home/Views/TailorDashboard.dart';
import 'package:hog/TailorApp/Home/Views/Tailorbusiness.dart';
import 'package:hog/TailorApp/TailorNav.dart';

class TailorMainPage extends StatefulWidget {
  final bool isVendorEnabled;

  const TailorMainPage({Key? key, required this.isVendorEnabled})
    : super(key: key);

  @override
  State<TailorMainPage> createState() => _TailorMainPageState();
}

class _TailorMainPageState extends State<TailorMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    Tailordashboard(),
    AssignedMaterials(),
    TailorDeliveries(),
    Myworks(),
  ];

  @override
  void initState() {
    super.initState();

    // 🔹 Show dialog immediately if vendor not enabled
    if (!widget.isVendorEnabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showVendorDisabledDialog();
      });
    }
  }

  void _showVendorDisabledDialog() {
    showDialog(
      context: context,
      // barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text("Account Pending"),
            content: const Text(
              "Your vendor account is not yet enabled. Please complete your registration form.",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => TailorRegistrationPage()),
                  );
                },
                child: const Text("Go to Form"),
              ),
            ],
          ),
    );
  }

  void _onNavTap(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.isNotEmpty ? _pages[_currentIndex] : const SizedBox(),
      bottomNavigationBar: TailorCustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
