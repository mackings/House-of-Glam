import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/components/Orders/ordercard.dart';
import 'package:hog/components/texts.dart';




class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool isLoading = false;
  List<MaterialReview> materials = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    final response = await UserActivityService.getAllMaterialsForReview();
    if (response != null && response.success) {
      setState(() => materials = response.materials);
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText("Order History", color: Colors.white, fontSize: 18),
        backgroundColor: Colors.purple,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : materials.isEmpty
                ? const Center(child: CustomText("No orders found"))
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: materials.length,
                    itemBuilder: (context, index) {
                      final material = materials[index];
                      return OrderCard(
                        material: material,
                        onViewQuotations: () {
                          Navigator.pushNamed(
                            context,
                            "/quotations",
                            arguments: material.id,
                          );
                        },
                      );
                    },
                  ),
      ),
    );
  }
}
