import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/App/Admin/Api/DeliveryRservice.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:intl/intl.dart';


class DeliverySettings extends StatefulWidget {
  const DeliverySettings({super.key});

  @override
  State<DeliverySettings> createState() => _DeliverySettingsState();
}

class _DeliverySettingsState extends State<DeliverySettings> {
  List<Map<String, dynamic>> deliveryRates = [];
  bool isLoading = false;

  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _typeCtrl = TextEditingController();

  final NumberFormat _formatter = NumberFormat("#,##0", "en_US");

  @override
  void initState() {
    super.initState();
    fetchDeliveryRates();

    // 🟣 Add live formatting listener
    _amountCtrl.addListener(() {
      final text = _amountCtrl.text.replaceAll(',', '');
      if (text.isEmpty) return;

      final value = double.tryParse(text);
      if (value != null) {
        final newText = _formatter.format(value);
        if (newText != _amountCtrl.text) {
          final selectionIndex = newText.length;
          _amountCtrl.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: selectionIndex),
          );
        }
      }
    });
  }

  Future<void> fetchDeliveryRates() async {
    setState(() => isLoading = true);
    deliveryRates = await DeliveryRateService.getDeliveryRates();
    setState(() => isLoading = false);
  }

  Future<void> _createDeliveryRate() async {
    if (_amountCtrl.text.isEmpty || _typeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    final cleanAmount = _amountCtrl.text.replaceAll(',', '');

    final success = await DeliveryRateService.createDeliveryRate(
      amount: double.parse(cleanAmount),
      deliveryType: _typeCtrl.text,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Delivery Rate Created Successfully")),
      );
      _amountCtrl.clear();
      _typeCtrl.clear();
      fetchDeliveryRates();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Failed to create delivery rate")),
      );
    }
  }

  Future<void> _deleteRate(String id) async {
    final success = await DeliveryRateService.deleteDeliveryRate(id);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🗑️ Rate deleted successfully")),
      );
      fetchDeliveryRates();
    }
  }

  Future<void> _editRate(String id, double currentAmount) async {
    final TextEditingController amountCtrl = TextEditingController(
      text: _formatter.format(currentAmount),
    );

    // 🟣 Add live formatting to edit field
    amountCtrl.addListener(() {
      final text = amountCtrl.text.replaceAll(',', '');
      if (text.isEmpty) return;
      final value = double.tryParse(text);
      if (value != null) {
        final newText = _formatter.format(value);
        if (newText != amountCtrl.text) {
          final selectionIndex = newText.length;
          amountCtrl.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(offset: selectionIndex),
          );
        }
      }
    });

    showDialog(
      context: context,
      builder: (_) => Column(
        children: [
          AlertDialog(
            title: CustomText("Edit Delivery Rate"),
            content: CustomTextField(
              title: "Rate",
              fieldKey: "rate",
              controller: amountCtrl,
              hintText: "Enter new amount",
              keyboardType: TextInputType.number,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                onPressed: () async {
                  final cleanAmount = amountCtrl.text.replaceAll(',', '');
                  final updated = await DeliveryRateService.updateDeliveryRate(
                    rateId: id,
                    amount: double.parse(cleanAmount),
                  );
                  Navigator.pop(context);
                  if (updated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Rate updated")),
                    );
                    fetchDeliveryRates();
                  }
                },
                child: const CustomText("Update",color: Colors.white,)
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddRateDialog() {
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText("Add Delivery Rate",
                  fontSize: 18, fontWeight: FontWeight.bold),
              const SizedBox(height: 15),
              CustomTextField(
                fieldKey: "Amount",
                title: "Delivery Amount",
                controller: _amountCtrl,
                hintText: "Enter amount",
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                fieldKey: "Delivery Type",
                title: "Delivery Type",
                controller: _typeCtrl,
                hintText: "Delivery type (e.g. Express)",
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: _createDeliveryRate,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Create Rate",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: CustomText("Delivery Settings",
            color: Colors.white, fontSize: 18,),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: _showAddRateDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.purple))
            : Padding(
                padding: const EdgeInsets.all(16),
                child: deliveryRates.isEmpty
                    ? Center(
                        child: CustomText(
                          "No delivery rates found",
                          color: Colors.black54,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const SizedBox(height: 10),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: deliveryRates.length,
                            itemBuilder: (context, index) {
                              final rate = deliveryRates[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    )
                                  ],
                                  border: Border.all(
                                    color: Colors.purple.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.local_shipping,
                                            color: Colors.purple),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CustomText(
                                              rate["deliveryType"] ?? "N/A",
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            CustomText(
                                              "${_formatter.format(rate["amount"])}%",
                                              color: Colors.black54,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit,
                                              color: Colors.black),
                                          onPressed: () => _editRate(
                                            rate["_id"],
                                            double.parse(
                                                rate["amount"].toString()),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _deleteRate(rate["_id"]),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
      ),
    );
  }
}

