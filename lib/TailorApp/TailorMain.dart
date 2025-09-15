import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Views/TailorDashboard.dart';
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
      barrierDismissible: false, // force user to acknowledge
      builder: (context) => AlertDialog(
        title: const Text("Account Pending"),
        content: const Text(
          "Your vendor account is not yet enabled. Please wait for admin approval.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
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
