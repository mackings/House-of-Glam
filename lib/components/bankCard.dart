import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Banks/View/userBanks.dart';
import 'package:hog/components/Navigator.dart';

class BankDetailsCard extends StatefulWidget {
  final double borderRadius;

  const BankDetailsCard({Key? key, this.borderRadius = 16}) : super(key: key);

  @override
  State<BankDetailsCard> createState() => _BankDetailsCardState();
}

class _BankDetailsCardState extends State<BankDetailsCard> {
  String accountNumber = "••••••••••";
  double walletBalance = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async {
    final userData = await SecurePrefs.getUserData();
    if (userData != null && mounted) {
      setState(() {
        accountNumber = userData["accountNumber"] ?? "N/A";
        walletBalance = (userData["wallet"] ?? 0).toDouble();
        isLoading = false;
      });
    } else {
      setState(() {
        accountNumber = "N/A";
        walletBalance = 0.0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Nav.push(context, MyBanksPage());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 9),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius + 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF16131E), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(18),
            child:
                isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Bank Logo/Icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.account_balance_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                "HOG Bank",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Account Details
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Wallet Balance
                            Text(
                              "₦${walletBalance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Label
                            Text(
                              "Wallet Balance",
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Account Number
                            Text(
                              accountNumber,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
          ),
        ),
      ),
    );
  }
}
