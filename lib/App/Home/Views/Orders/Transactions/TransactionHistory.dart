import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/Transaction.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/Transactions/card.dart';
import 'package:hog/components/Transactions/modal.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  bool isLoading = false;
  List<TransactionResponse> transactions = [];

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
    }
    setState(() => isLoading = false);
  }

  void showTransactionDetails(TransactionResponse txn) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TransactionDetailsModal(txn: txn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const CustomText(
          "Transactions",
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTransactions,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                ? const Center(child: Text("No transactions found"))
                : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final txn = transactions[index];
                    return TransactionCard(
                      txn: txn,
                      onTap: () => showTransactionDetails(txn),
                    );
                  },
                ),
      ),
    );
  }
}
