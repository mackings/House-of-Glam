import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Banks/View/userBanks.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/theme/app_theme.dart';

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
                colors: [AppColors.ink, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 170;

                return Padding(
                  padding: EdgeInsets.all(compact ? 14 : 18),
                  child:
                      isLoading
                          ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(compact ? 8 : 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(
                                        compact ? 12 : 14,
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_outlined,
                                      color: Colors.white,
                                      size: compact ? 18 : 20,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: compact ? 10 : 12,
                                      vertical: compact ? 5 : 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      "HOG Bank",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: compact ? 11 : 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "₦${walletBalance.toStringAsFixed(2)}",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: compact ? 22 : 26,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 4 : 8),
                                  Text(
                                    "Wallet Balance",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: compact ? 11 : 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: compact ? 6 : 12),
                                  Text(
                                    accountNumber,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontSize: compact ? 12 : 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
