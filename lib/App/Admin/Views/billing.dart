import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/billingService.dart';
import 'package:hog/components/texts.dart';


class SetBilling extends StatefulWidget {
  const SetBilling({super.key});

  @override
  State<SetBilling> createState() => _SetBillingState();
}

class _SetBillingState extends State<SetBilling> {
  final TextEditingController _feeController = TextEditingController();
  bool _loading = false;
  double? _currentFee;

  @override
  void initState() {
    super.initState();
    _fetchCurrentFee();
  }

  /// 🔹 Fetch current billing fee
  Future<void> _fetchCurrentFee() async {
    setState(() => _loading = true);
    final fee = await BillingService.getListingFee();
    setState(() {
      _currentFee = fee;
      _loading = false;
      if (fee != null) {
        _feeController.text = fee.toString();
      }
    });
  }

  /// 🔹 Submit new fee
  Future<void> _submitFee() async {
    final entered = double.tryParse(_feeController.text);
    if (entered == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid number")),
      );
      return;
    }

    setState(() => _loading = true);
    final success = await BillingService.setListingFee(entered);

    setState(() => _loading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Billing fee updated successfully")),
      );
      _fetchCurrentFee();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Failed to update billing fee")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          "Set Billing",
          color: Colors.white,
          fontSize: 18,
        ),
        backgroundColor: Colors.purple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.purple))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (_currentFee != null)
                    CustomText(
                      "${_currentFee!.toStringAsFixed(2)}",
                      fontSize: 58,
                      color: Colors.purple,
                    ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _feeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Set new percentage",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitFee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text("Update Fee"),
                  )
                ],
              ),
            ),
    );
  }
}
