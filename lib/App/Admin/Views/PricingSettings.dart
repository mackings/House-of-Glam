import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/DeliveryRservice.dart';
import 'package:hog/components/texts.dart';

class PricingSettings extends StatefulWidget {
  const PricingSettings({super.key});

  @override
  State<PricingSettings> createState() => _PricingSettingsState();
}

class _PricingSettingsState extends State<PricingSettings> {
  final TextEditingController _quotationTaxCtrl = TextEditingController();
  final TextEditingController _vatCtrl = TextEditingController();

  bool _isLoading = false;
  String _updatedAt = "";

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  @override
  void dispose() {
    _quotationTaxCtrl.dispose();
    _vatCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchConfig() async {
    setState(() => _isLoading = true);
    final data = await DeliveryRateService.getPricingConfig();
    if (!mounted) return;

    if (data != null) {
      _quotationTaxCtrl.text = (data["quotationTaxPercent"] ?? 0).toString();
      _vatCtrl.text = (data["vatPercent"] ?? 0).toString();
      _updatedAt = data["updatedAt"]?.toString() ?? "";
    }
    setState(() => _isLoading = false);
  }

  Future<void> _saveConfig() async {
    final qTax = double.tryParse(_quotationTaxCtrl.text.trim());
    final vat = double.tryParse(_vatCtrl.text.trim());

    if (qTax == null || vat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter valid percentage values")),
      );
      return;
    }

    setState(() => _isLoading = true);
    final ok = await DeliveryRateService.updatePricingConfig(
      quotationTaxPercent: qTax,
      vatPercent: vat,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? "Tax/VAT updated successfully" : "Failed to update Tax/VAT",
        ),
      ),
    );
    if (ok) _fetchConfig();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.purple,
        title: const CustomText("Tax & VAT", color: Colors.white, fontSize: 18),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _quotationTaxCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "Quotation Tax (%)",
                        hintText: "e.g. 10",
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _vatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: "VAT (%)",
                        hintText: "e.g. 10",
                      ),
                    ),
                    if (_updatedAt.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      CustomText(
                        "Last updated: $_updatedAt",
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ],
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveConfig,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
