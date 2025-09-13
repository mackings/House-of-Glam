import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/Transaction.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
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
if (response != null && response.transactions.isNotEmpty) {
  setState(() => transactions = response.transactions);
}

    setState(() => isLoading = false);
  }

  String formatDate(String date) {
    return DateFormat.yMMMd().format(DateTime.parse(date));
  }

void showTransactionDetails(TransactionResponse txn) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) {
      return DraggableScrollableSheet(
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title
              Text("Transaction Details",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 20),

              // Transaction info section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.black12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Reference: ${txn.paymentReference}"),
                      Text("Order Status: ${txn.orderStatus}"),
                      Text("Payment Method: ${txn.paymentMethod}"),
                      Text("Delivery Address: ${txn.deliveryAddress ?? 'N/A'}"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Cart Items Section
              Text("Cart Items",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              ...txn.cartItems.map(
                (item) => Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: Colors.black12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.purple),
                    title: Text(item.attireType,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${item.color} • ${item.brand}"),
                    trailing: Text(item.clothMaterial),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Images Section
              Text("Sample Images",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: txn.cartItems.expand((item) {
                    return item.sampleImage.map(
                      (img) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            img,
                            width: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
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
                      return GestureDetector(
                        onTap: () => showTransactionDetails(txn),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: Colors.black12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("₦${txn.totalAmount}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 16)),
                                    Chip(
                                      label: Text(txn.paymentStatus.toString()),
                                      backgroundColor: txn.paymentStatus == "success"
                                          ? Colors.green[100]
                                          : Colors.red[100],
                                      labelStyle: TextStyle(
                                        color: txn.paymentStatus == "success"
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text("Method: ${txn.paymentMethod}"),
                                Text("Date: ${formatDate(txn.createdAt.toString())}"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}