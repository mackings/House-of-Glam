import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/billingService.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

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
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Set Billing",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body:
          _loading
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
                        colors: [Color(0xFFF7F2FF), Color(0xFFFFFFFF)],
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
                                color: AppColors.accentSoft,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.percent_rounded,
                                color: AppColors.accent,
                              ),
                            ),
                            const Spacer(),
                            if (_currentFee != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: CustomText(
                                  "${_currentFee!.toStringAsFixed(2)}%",
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.ink,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const CustomText(
                          "Listing fee control",
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        const CustomText(
                          "Update the marketplace billing percentage used for listing fees.",
                          fontSize: 13,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
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
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 18,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomText(
                          "Billing percentage",
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 6),
                        const CustomText(
                          "Enter the percentage value to apply to new listing charges.",
                          fontSize: 12,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _feeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Set new percentage",
                            suffixText: "%",
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitFee,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 54),
                            ),
                            child: const Text("Update Fee"),
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
