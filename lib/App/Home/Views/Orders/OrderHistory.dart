import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/useractivity.dart';
import 'package:hog/App/Home/Model/historymodel.dart';
import 'package:hog/App/Home/Views/Orders/quote.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/Orders/ordercard.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class OrderHistory extends StatefulWidget {
  final bool showBackButton;

  const OrderHistory({super.key, this.showBackButton = true});

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
      final sortedMaterials = [...response.materials]..sort(
        (a, b) => _parseOrderDate(
          b.createdAt,
        ).compareTo(_parseOrderDate(a.createdAt)),
      );
      setState(() => materials = sortedMaterials);
    }
    setState(() => isLoading = false);
  }

  DateTime _parseOrderDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: CustomAppBar(
        title: "Order History",
        enableAction: false,
        enableBack: widget.showBackButton,
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : materials.isEmpty
                ? ListView(
                  children: const [
                    SizedBox(height: 220),
                    Center(child: CustomText("No orders found")),
                  ],
                )
                : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
                  itemCount: materials.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return const Padding(
                        padding: EdgeInsets.fromLTRB(6, 4, 6, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              "Track every submitted outfit request and review tailor quotations from one place.",
                              textAlign: TextAlign.left,
                              color: AppColors.subtext,
                            ),
                            SizedBox(height: 14),
                          ],
                        ),
                      );
                    }

                    final material = materials[index - 1];
                    return OrderCard(
                      material: material,
                      onViewQuotations: () {
                        Nav.push(context, Quotation(materialId: material.id));
                      },
                    );
                  },
                ),
      ),
    );
  }
}
