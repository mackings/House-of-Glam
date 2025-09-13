import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Home/Model/TransModel.dart';
import 'package:hog/components/texts.dart';




class TransactionDetailsModal extends StatelessWidget {
  final TransactionResponse txn;

  const TransactionDetailsModal({super.key, required this.txn});

  void copyReference(BuildContext context, String reference) {
    Clipboard.setData(ClipboardData(text: reference));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reference copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  "Transaction Details",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.purple.withOpacity(0.1),
                  child: const Icon(Icons.receipt_long, color: Colors.purple),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Info Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: Colors.grey, width: 1),
              ),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tag, color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        CustomText("Ref: ${txn.paymentReference}"),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () =>
                              copyReference(context, txn.paymentReference.toString()),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.assignment_turned_in,
                            color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        CustomText("Status: ${txn.orderStatus}"),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.credit_card,
                            color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        CustomText("Method: ${txn.paymentMethod}"),
                      ],
                    ),
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.purple, size: 20),
                        const SizedBox(width: 8),
                        CustomText(
                          "${txn.deliveryAddress ?? 'N/A'}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Cart Items
            CustomText("Cart Items", fontWeight: FontWeight.bold),
            const SizedBox(height: 8),
            ...txn.cartItems.map(
              (item) => Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.grey, width: 1),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 0,
                child: ListTile(
                  leading: const Icon(Icons.shopping_bag, color: Colors.purple),
                  title: CustomText(item.attireType,
                      fontWeight: FontWeight.bold),
                  subtitle: CustomText("${item.color} • ${item.brand}"),
                  trailing: CustomText(item.clothMaterial),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Sample Images
            CustomText("Sample Images", fontWeight: FontWeight.bold),
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
  }
}
