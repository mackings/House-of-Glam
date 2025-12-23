// pages/my_banks_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Banks/Api/BamkService.dart';
import 'package:hog/App/Banks/Model/bankModel.dart';
import 'package:hog/App/Banks/View/addBank.dart';
import 'package:hog/App/Banks/View/transferPage.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';


class MyBanksPage extends StatefulWidget {
  const MyBanksPage({Key? key}) : super(key: key);

  @override
  State<MyBanksPage> createState() => _MyBanksPageState();
}

class _MyBanksPageState extends State<MyBanksPage> with SingleTickerProviderStateMixin {
  List<Bank> _banks = [];
  bool _isLoading = true;
  double _walletBalance = 0.0; // This will be in NGN
  double _displayBalance = 0.0; // This will be in user's currency
  bool _balanceVisible = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    await Future.wait([
      _fetchBanks(),
      _fetchWalletBalance(),
    ]);

    setState(() {
      _isLoading = false;
    });
    
    _animationController.forward();
  }

  Future<void> _fetchBanks() async {
    try {
      final banks = await BankApiService.getAllBanks();
      if (mounted) {
        setState(() {
          _banks = banks;
        });
      }
    } catch (e) {
      print("❌ Error fetching banks: $e");
    }
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final result = await BankApiService.getUserWalletBalance();
      if (result['success'] == true && mounted) {
        final balanceNGN = (result['balance'] ?? 0).toDouble();
        
        // ✅ Convert to user's currency
        final converted = await CurrencyHelper.convertFromNGN(balanceNGN.toInt());
        
        setState(() {
          _walletBalance = balanceNGN; // Keep NGN for API calls
          _displayBalance = converted; // Display in user's currency
        });
      }
    } catch (e) {
      print("❌ Error fetching wallet balance: $e");
    }
  }

  Future<void> _navigateToAddBank() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddBankAccountPage(),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###.##');
    return '$currencySymbol${formatter.format(amount)}';
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _balanceVisible = !_balanceVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bank Accounts",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.add, color: Colors.purple[700], size: 20),
            ),
            onPressed: _navigateToAddBank,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: Colors.purple,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Wallet Balance Card
                    SliverToBoxAdapter(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        child: _buildWalletCard(),
                      ),
                    ),

                    // Quick Stats
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildQuickStats(),
                      ),
                    ),

                    // Section Header
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CustomText(
                                  "Saved Banks",
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                const SizedBox(height: 4),
                                CustomText(
                                  "${_banks.length} ${_banks.length == 1 ? 'account' : 'accounts'}",
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Banks List or Empty State
                    _banks.isEmpty
                        ? SliverFillRemaining(
                            child: _buildEmptyState(),
                          )
                        : SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final bank = _banks[index];
                                  return _buildBankCard(bank, index);
                                },
                                childCount: _banks.length,
                              ),
                            ),
                          ),

                    const SliverToBoxAdapter(
                      child: SizedBox(height: 20),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: _banks.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _navigateToAddBank,
              backgroundColor: Colors.purple[700],
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Bank',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade700,
            Colors.purple.shade500,
            Colors.deepPurple.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      "Main Wallet",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _balanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _toggleBalanceVisibility,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Available Balance",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _balanceVisible 
                ? _formatCurrency(_displayBalance) // ✅ Show converted balance
                : "$currencySymbol •••••••",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Transfer to any of your saved bank accounts",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Rest of the widgets remain the same...
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.account_balance,
            label: "Total Banks",
            value: "${_banks.length}",
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.trending_up,
            label: "Active",
            value: "${_banks.length}",
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_outlined,
              size: 64,
              color: Colors.purple[300],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "No bank accounts yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: _navigateToAddBank,
            icon: const Icon(Icons.add_circle_outline, size: 20),
            label: const Text(
              "Add Your First Bank",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankCard(Bank bank, int index) {
    final colors = [
      [Colors.blue.shade700, Colors.blue.shade500],
      [Colors.purple.shade700, Colors.purple.shade500],
      [Colors.green.shade700, Colors.green.shade500],
      [Colors.orange.shade700, Colors.orange.shade500],
      [Colors.teal.shade700, Colors.teal.shade500],
    ];
    final cardColor = colors[index % colors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: cardColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bank.bankName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Account Number",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bank.accountNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Account Name",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    bank.accountName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BankTransferPage(
                        bank: bank,
                        walletBalance: _walletBalance, // Pass NGN balance
                      ),
                    ),
                  ).then((value) {
                    if (value == true) {
                      _loadData();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_forward, color: cardColor[0], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        "Transfer to this account",
                        style: TextStyle(
                          color: cardColor[0],
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
