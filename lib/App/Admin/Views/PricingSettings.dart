import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/DeliveryRservice.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

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
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Tax & VAT",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEFF6FF), Color(0xFFFFFFFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.receipt_long_outlined,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const Spacer(),
                            if (_updatedAt.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const CustomText(
                                  "Config synced",
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const CustomText(
                          "Pricing configuration",
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        const CustomText(
                          "Manage quotation tax and VAT used throughout order pricing.",
                          fontSize: 13,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                        if (_updatedAt.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          CustomText(
                            "Last updated: $_updatedAt",
                            fontSize: 12,
                            color: AppColors.subtext,
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
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
                            suffixText: "%",
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
                            suffixText: "%",
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveConfig,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              minimumSize: const Size(double.infinity, 54),
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
                ],
              ),
    );
  }
}
