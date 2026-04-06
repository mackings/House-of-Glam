import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/Transaction.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/Transactions/card.dart';
import 'package:hog/components/Transactions/modal.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';

class Transactions extends StatefulWidget {
  final bool showBackButton;

  const Transactions({super.key, this.showBackButton = true});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  bool isLoading = false;
  List<TransactionResponse> transactions = [];
  Map<String, double> convertedAmounts = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    setState(() => isLoading = true);

    final response = await TransactionService.getTransactions();

    if (response != null && response.transactions.isNotEmpty) {
      setState(() => transactions = response.transactions);
      await _convertAllAmounts();
    }

    setState(() => isLoading = false);
  }

  Future<void> _convertAllAmounts() async {
    for (var txn in transactions) {
      final amount =
          txn.isBankTransfer
              ? (txn.totalAmount ?? 0.0)
              : (txn.amountPaid ?? txn.totalAmount ?? 0.0);

      if (amount > 0) {
        try {
          final ngnAmount = amount.round();
          final converted = await CurrencyHelper.convertFromNGN(ngnAmount);
          convertedAmounts[txn.id ?? ''] = converted;
        } catch (_) {
          convertedAmounts[txn.id ?? ''] = amount;
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
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => TransactionDetailsModal(
            txn: txn,
            convertedAmount: convertedAmount,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: CustomAppBar(
        title: "Transactions",
        enableAction: false,
        enableBack: widget.showBackButton,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTransactions,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                ? ListView(
                  children: const [
                    SizedBox(height: 220),
                    Center(child: Text("No transactions found")),
                  ],
                )
                : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                  itemCount: transactions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(6, 4, 6, 10),
                        child: Text(
                          "Review payments, transfers, and order activity with cleaner transaction details.",
                          style: TextStyle(
                            color: AppColors.subtext,
                            height: 1.5,
                          ),
                        ),
                      );
                    }

                    final txn = transactions[index - 1];
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
