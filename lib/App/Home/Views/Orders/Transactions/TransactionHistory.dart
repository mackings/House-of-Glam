import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/Transaction.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/Transactions/card.dart';
import 'package:hog/components/Transactions/modal.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';





class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  bool isLoading = false;
  List<TransactionResponse> transactions = [];
  // ✅ Store converted amounts
  Map<String, double> convertedAmounts = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() => isLoading = true);
    
    final response = await TransactionService.getTransactions();
    
    if (response != null && response.transactions!.isNotEmpty) {
      setState(() => transactions = response.transactions!);
      
      // ✅ Convert all amounts to user's currency
      await _convertAllAmounts();
    }
    
    setState(() => isLoading = false);
  }

  // ✅ Convert all transaction amounts from NGN to user's currency
  Future<void> _convertAllAmounts() async {
    for (var txn in transactions) {
      // ✅ Use totalAmount for transfers, amountPaid for orders
      final amount = txn.isBankTransfer 
          ? (txn.totalAmount ?? 0)
          : (txn.amountPaid ?? txn.totalAmount ?? 0);
      
      if (amount > 0) {
        try {
          final converted = await CurrencyHelper.convertFromNGN(amount);
          convertedAmounts[txn.id ?? ''] = converted;
        } catch (e) {
          print("❌ Error converting amount for ${txn.id}: $e");
          // Fallback to original amount if conversion fails
          convertedAmounts[txn.id ?? ''] = amount.toDouble();
        }
      }
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  void showTransactionDetails(TransactionResponse txn) {
    final convertedAmount = convertedAmounts[txn.id ?? ''] ?? 0;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionDetailsModal(
        txn: txn,
        convertedAmount: convertedAmount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const CustomText(
          "Transactions",
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTransactions,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : transactions.isEmpty
                ? const Center(child: Text("No transactions found"))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      final convertedAmount = convertedAmounts[txn.id ?? ''] ?? 0;
                      
                      return TransactionCard(
                        txn: txn,
                        convertedAmount: convertedAmount,
                        onTap: () => showTransactionDetails(txn),
                      );
                    },
                  ),
      ),
    );
  }
}
