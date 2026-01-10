import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Banks/Api/BamkService.dart';
import 'package:hog/App/Banks/Model/bankModel.dart';

class BankTransferPage extends StatefulWidget {
  final Bank bank;
  final double walletBalance;

  const BankTransferPage({
    Key? key,
    required this.bank,
    required this.walletBalance,
  }) : super(key: key);

  @override
  State<BankTransferPage> createState() => _BankTransferPageState();
}

class _BankTransferPageState extends State<BankTransferPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isProcessing = false;
  bool _showPin = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pinController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processTransfer() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    if (amount > widget.walletBalance) {
      _showErrorSnackBar("Insufficient wallet balance");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    Map<String, dynamic> result;

    // ✅ Check if it's a Stripe account
    if (widget.bank.isStripeAccount) {
      result = await BankApiService.stripeTransfer(
        bankId: widget.bank.id,
        amount: amount,
      );
    } else {
      // Local bank transfer (existing code)
      result = await BankApiService.bankTransfer(
        bankId: widget.bank.id,
        amount: amount,
        pin: _pinController.text.isNotEmpty ? _pinController.text : null,
      );
    }

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccessDialog(amount);
    } else {
      _showErrorSnackBar(result['error'] ?? 'Transfer failed');
    }
  }

  void _showSuccessDialog(double amount) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success Animation
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green[600],
                            size: 64,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Transfer Successful!',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _formatCurrency(amount),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'has been sent to ${widget.bank.accountName}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(
                          context,
                          true,
                        ); // Go back to previous page
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '₦${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  void _setQuickAmount(double amount) {
    if (amount <= widget.walletBalance) {
      _amountController.text = amount.toStringAsFixed(0);
    }
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
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bank Transfer',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipient Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue[600]!, Colors.blue[800]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Transfer To',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          widget.bank.accountName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                widget.bank.bankName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white60,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                widget.bank.accountNumber,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Wallet Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green[50],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: Colors.green[700],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Available Balance',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _formatCurrency(widget.walletBalance),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Amount Input Section
                  const Text(
                    'Transfer Amount',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.bold,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          '₦',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                        return 'Please enter a valid amount';
                      }
                      if (amount > widget.walletBalance) {
                        return 'Insufficient balance';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Quick Amount Buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _QuickAmountChip(
                        label: '₦1,000',
                        onTap: () => _setQuickAmount(1000),
                      ),
                      _QuickAmountChip(
                        label: '₦5,000',
                        onTap: () => _setQuickAmount(5000),
                      ),
                      _QuickAmountChip(
                        label: '₦10,000',
                        onTap: () => _setQuickAmount(10000),
                      ),
                      _QuickAmountChip(
                        label: '₦50,000',
                        onTap: () => _setQuickAmount(50000),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // PIN Input Section
                  Row(
                    children: [
                      const Text(
                        'Transaction PIN',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Optional',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(
                          _showPin
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _showPin = !_showPin;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: !_showPin,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: InputDecoration(
                      hintText: '• • • • • •',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        letterSpacing: 8,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.grey[600],
                          size: 20,
                        ),
                      ),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Transfer Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processTransfer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                        shadowColor: Colors.blue.withOpacity(0.3),
                      ),
                      child:
                          _isProcessing
                              ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.send_rounded,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    'Transfer Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info Container
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Funds will be deducted from your wallet balance',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[900],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Quick Amount Chip Widget
class _QuickAmountChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickAmountChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
