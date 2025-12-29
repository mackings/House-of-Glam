import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Banks/Api/BamkService.dart';
import 'package:hog/App/Banks/Api/ExchangeService.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/components/thousandformat.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';



class PaymentOptionsModal extends StatefulWidget {
  final Review review;
  final Function(String url) onCheckout;

  const PaymentOptionsModal({
    super.key,
    required this.review,
    required this.onCheckout,
  });

  @override
  State<PaymentOptionsModal> createState() => _PaymentOptionsModalState();
}

class _PaymentOptionsModalState extends State<PaymentOptionsModal> {
  String paymentType = "part";
  String shipment = "Regular";

  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;

  // ✅ For currency conversion transparency
  double? convertedAmount;
  String? targetCurrency;
  bool isConverting = false;

  @override
  void initState() {
    super.initState();
    // Add listener to amount controller for real-time conversion
    amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    amountController.removeListener(_onAmountChanged);
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  // ✅ Real-time conversion when user types amount
  Future<void> _onAmountChanged() async {
    final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
    final isInternationalVendor = vendorCountry == 'UNITED STATES' ||
        vendorCountry == 'US' ||
        vendorCountry == 'USA' ||
        vendorCountry == 'UNITED KINGDOM' ||
        vendorCountry == 'UK' ||
        vendorCountry == 'GB';

    if (!isInternationalVendor || amountController.text.trim().isEmpty) {
      if (mounted) {
        setState(() {
          convertedAmount = null;
          targetCurrency = null;
        });
      }
      return;
    }

    try {
      final userAmount = double.parse(amountController.text.replaceAll(",", ""));

      // Determine target currency based on vendor country
      String currency = 'USD';
      if (vendorCountry.contains('UNITED KINGDOM') || vendorCountry == 'UK' || vendorCountry == 'GB') {
        currency = 'GBP';
      }

      if (mounted) {
        setState(() {
          isConverting = true;
          targetCurrency = currency;
        });
      }

      // Get conversion from NGN to target currency
      final ngnAmount = await CurrencyHelper.convertToNGN(userAmount);
      final result = await ConversionApiService.getExchangeRate(
        amount: ngnAmount.toDouble(),
        targetCurrency: currency,
      );

      if (result['success'] == true && mounted) {
        setState(() {
          convertedAmount = result['convertedAmount'];
          isConverting = false;
        });
      } else {
        if (mounted) {
          setState(() {
            isConverting = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          convertedAmount = null;
          isConverting = false;
        });
      }
    }
  }

  Future<void> _makePayment() async {
    setState(() => isLoading = true);

    try {
      // ✅ Check if vendor is from US or international country requiring Stripe
      final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
      final isInternationalVendor = vendorCountry == 'UNITED STATES' ||
          vendorCountry == 'US' ||
          vendorCountry == 'USA' ||
          vendorCountry == 'UNITED KINGDOM' ||
          vendorCountry == 'UK' ||
          vendorCountry == 'GB';

      // ✅ For international vendors, use Stripe checkout
      if (isInternationalVendor) {
        String? amountToSend;
        String? addressToSend;

        if (paymentType == "part") {
          if (amountController.text.trim().isEmpty) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter an amount")),
            );
            return;
          }
          // Part payment - send NGN amount (backend will convert)
          final userAmount = double.parse(amountController.text.replaceAll(",", ""));
          final ngnAmount = await CurrencyHelper.convertToNGN(userAmount);
          amountToSend = ngnAmount.toString();
        } else {
          // Full payment - send remaining balance amount + address
          if (addressController.text.trim().isEmpty) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter delivery address")),
            );
            return;
          }
          // Calculate remaining balance in NGN
          final remaining = widget.review.totalCost - widget.review.amountPaid;
          if (remaining <= 0) {
            setState(() => isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No balance left to pay")),
            );
            return;
          }
          amountToSend = remaining.toString();
          addressToSend = addressController.text.trim();
        }

        // Create Stripe checkout
        final resp = await BankApiService.stripeCheckoutPayment(
          reviewId: widget.review.id,
          shipmentMethod: shipment,
          amount: amountToSend,
          address: addressToSend,
        );

        setState(() => isLoading = false);

        if (resp["success"] == true) {
          final url = resp["checkoutUrl"];
          if (url != null) {
            Navigator.of(context).pop();
            widget.onCheckout(url);
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp["error"] ?? "Stripe checkout failed")),
          );
        }
        return;
      }

      // ✅ For local vendors (Nigeria), use Paystack.
      String amountToSend;

      if (paymentType == "part") {
        if (amountController.text.trim().isEmpty) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter an amount")),
          );
          return;
        }

        // ✅ Convert user input back to NGN if needed
        final userAmount = double.parse(amountController.text.replaceAll(",", ""));
        final ngnAmount = await CurrencyHelper.convertToNGN(userAmount);
        amountToSend = ngnAmount.toString();
      } else {
        // Full payment - use original NGN amount
        final remaining = widget.review.totalCost - widget.review.amountPaid;
        if (remaining <= 0) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No balance left to pay")),
          );
          return;
        }
        amountToSend = remaining.toString();
      }

      final resp = paymentType == "part"
          ? await PaymentService.createPartPayment(
              reviewId: widget.review.id,
              amount: amountToSend,
              shipmentMethod: shipment,
            )
          : await PaymentService.createFullPayment(
              reviewId: widget.review.id,
              amount: amountToSend,
              shipmentMethod: shipment,
              address: addressController.text.trim(),
            );

      setState(() => isLoading = false);

      if (resp != null && resp["success"]) {
        final url = resp["authorizationUrl"];
        if (url != null) {
          Navigator.of(context).pop();
          widget.onCheckout(url);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed")),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if vendor is international
    final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
    final isInternationalVendor = vendorCountry == 'UNITED STATES' ||
        vendorCountry == 'US' ||
        vendorCountry == 'USA' ||
        vendorCountry == 'UNITED KINGDOM' ||
        vendorCountry == 'UK' ||
        vendorCountry == 'GB';

    // Determine currency symbol based on vendor country
    String getCurrencySymbolForVendor() {
      if (vendorCountry.contains('UNITED STATES') || vendorCountry == 'US' || vendorCountry == 'USA') {
        return '\$';
      } else if (vendorCountry.contains('UNITED KINGDOM') || vendorCountry == 'UK' || vendorCountry == 'GB') {
        return '£';
      }
      return currencySymbol; // Default to user's currency
    }

    return FutureBuilder<double>(
      future: isInternationalVendor
          ? CurrencyHelper.convertFromNGN(widget.review.totalCost - widget.review.amountPaid)
          : Future.value((widget.review.totalCost - widget.review.amountPaid).toDouble()),
      builder: (context, snapshot) {
        final displayBalance = snapshot.data ??
            (widget.review.totalCost - widget.review.amountPaid).toDouble();

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 36,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CustomText(
                    "Choose a Payment Option",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 12),

                  // ✅ Show payment method indicator
                  if (isInternationalVendor)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.payment, color: Colors.blue.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomText(
                              "International vendor detected. Payment via Stripe (${widget.review.user.country})",
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (isInternationalVendor) const SizedBox(height: 12),

                  // ✅ Show balance in vendor's currency
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const CustomText("Balance:", fontSize: 14),
                            CustomText(
                              isInternationalVendor
                                  ? '${getCurrencySymbolForVendor()}${displayBalance.toStringAsFixed(2)}'
                                  : CurrencyHelper.formatAmount(displayBalance),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ],
                        ),
                        // ✅ Show transparent conversion info for international vendors
                        if (isInternationalVendor) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.info_outline, size: 14, color: Colors.purple.shade700),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    "≈ $currencySymbol${(widget.review.totalCost - widget.review.amountPaid).toStringAsFixed(0)} NGN",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.purple.shade900,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Payment type radios
                  Row(
                    children: [
                      Radio(
                        value: "full",
                        groupValue: paymentType,
                        onChanged: (val) => setState(() => paymentType = val!),
                      ),
                      const Text("Full Payment"),
                      Radio(
                        value: "part",
                        groupValue: paymentType,
                        onChanged: (val) {
                          setState(() {
                            paymentType = val as String;
                            amountController.clear();
                          });
                        },
                      ),
                      const Text("Part Payment"),
                    ],
                  ),

                  if (paymentType == "part") ...[
                    CustomTextField(
                      title: "Amount ($currencySymbol)",
                      fieldKey: "amount",
                      hintText: "Enter amount",
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d,.]')),
                        ThousandsFormatter(),
                      ],
                    ),

                    // ✅ Show transparent conversion for international vendors
                    if (isInternationalVendor) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.currency_exchange, color: Colors.green.shade700, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: isConverting
                                  ? Row(
                                      children: [
                                        SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Converting...",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade900,
                                          ),
                                        ),
                                      ],
                                    )
                                  : convertedAmount != null && targetCurrency != null
                                      ? Text(
                                          "≈ ${targetCurrency == 'USD' ? '\$' : '£'}${convertedAmount!.toStringAsFixed(2)} $targetCurrency",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade900,
                                          ),
                                        )
                                      : Text(
                                          "Enter amount to see conversion",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.green.shade700,
                                          ),
                                        ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],

                  const SizedBox(height: 12),

                  // Shipment dropdown
                  const CustomText("Shipment Method", fontSize: 16),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: shipment,
                      decoration: const InputDecoration(border: InputBorder.none),
                      items: const [
                        DropdownMenuItem(value: "Regular", child: Text("Regular (1–8 days)")),
                        DropdownMenuItem(value: "Express", child: Text("Express (1–4 days)")),
                        DropdownMenuItem(value: "Cargo", child: Text("Cargo (1–15 days)")),
                      ],
                      onChanged: (val) => setState(() => shipment = val!),
                    ),
                  ),

                  if (paymentType != "part")
                    CustomTextField(
                      title: "Delivery Address",
                      fieldKey: "address",
                      hintText: "Enter address",
                      controller: addressController,
                    ),

                  const SizedBox(height: 20),
                  CustomButton(title: "Make Payment", onPressed: _makePayment),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            if (isLoading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}



// class PaymentOptionsModal extends StatefulWidget {
//   final Review review;
//   final Function(String url) onCheckout;

//   const PaymentOptionsModal({
//     super.key,
//     required this.review,
//     required this.onCheckout,
//   });

//   @override
//   State<PaymentOptionsModal> createState() => _PaymentOptionsModalState();
// }

// class _PaymentOptionsModalState extends State<PaymentOptionsModal> {
//   String paymentType = "part";
//   String shipment = "Regular";

//   final TextEditingController amountController = TextEditingController();
//   final TextEditingController addressController = TextEditingController();
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     amountController.clear();
//   }

//   @override
//   void dispose() {
//     amountController.dispose();
//     super.dispose();
//   }

//   Future<void> _makePayment() async {
//     setState(() => isLoading = true);

//     String amountToSend;

//     if (paymentType == "part") {
//       if (amountController.text.trim().isEmpty) {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Please enter an amount for part payment"),
//           ),
//         );
//         return;
//       }
//       amountToSend = amountController.text.replaceAll(",", "");
//     } else {
//       // ✅ Full payment logic
//       final int remaining = widget.review.totalCost - widget.review.amountPaid;

//       if (remaining <= 0) {
//         setState(() => isLoading = false);
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text("No balance left to pay")));
//         return;
//       }

//       amountToSend = remaining.toString();
//     }

//     Map<String, dynamic>? resp;

//     if (paymentType == "part") {
//       resp = await PaymentService.createPartPayment(
//         reviewId: widget.review.id,
//         amount: amountToSend,
//         shipmentMethod: shipment,
//       );
//     } else {
//       resp = await PaymentService.createFullPayment(
//         reviewId: widget.review.id,
//         amount: amountToSend,
//         shipmentMethod: shipment,
//         address: addressController.text.trim(),
//       );
//     }

//     setState(() => isLoading = false);

//     if (resp != null && resp["success"]) {
//       final url = resp["authorizationUrl"];
//       if (url != null) {
//         // ✅ Close only THIS modal and call parent
//         Navigator.of(context).pop();
//         widget.onCheckout(url);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No payment link received")),
//         );
//       }
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Payment initialization failed")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 36,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   const CustomText(
//                     "Choose a Payment Option",
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),

//               // Payment Type Radios
//               Row(
//                 children: [
//                   Radio(
//                     value: "full",
//                     groupValue: paymentType,
//                     onChanged: (val) => setState(() => paymentType = val!),
//                   ),
//                   const Text("Full Payment"),
//                   Radio(
//                     value: "part",
//                     groupValue: paymentType,
//                     onChanged: (val) {
//                       setState(() {
//                         paymentType = val!;
//                         amountController.clear();
//                       });
//                     },
//                   ),
//                   const Text("Part Payment"),
//                 ],
//               ),

//               const SizedBox(height: 12),

//               if (paymentType == "part")
//                 CustomTextField(
//                   title: "Amount",
//                   fieldKey: "amount",
//                   hintText: "Enter Amount",
//                   controller: amountController,
//                   keyboardType: TextInputType.number,
//                   inputFormatters: [
//                     FilteringTextInputFormatter.digitsOnly,
//                     ThousandsFormatter(),
//                   ],
//                 ),

//               const SizedBox(height: 12),

//               // Shipment
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CustomText(
//                     "Shipment Method",
//                     fontSize: 16,
//                     fontWeight: FontWeight.w400,
//                   ),

//                   const SizedBox(height: 6),

//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey.shade400),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: DropdownButtonFormField<String>(
//                       value: shipment,
//                       decoration: const InputDecoration(
//                         border: InputBorder.none,
//                       ),
//                       items: const [
//                         DropdownMenuItem(
//                           value: "Regular",
//                           child: Text("Regular (1–8 days)"),
//                         ),
//                         DropdownMenuItem(
//                           value: "Express",
//                           child: Text("Express (1–4 days)"),
//                         ),
//                         DropdownMenuItem(
//                           value: "Cargo",
//                           child: Text("Cargo (1–15 days)"),
//                         ),
//                       ],
//                       onChanged: (val) => setState(() => shipment = val!),
//                     ),
//                   ),

//                   if (paymentType != "part")
//                     CustomTextField(
//                       title: "Address",
//                       fieldKey: "Address",
//                       hintText: "Enter delivery address",
//                       controller: addressController,
//                       keyboardType: TextInputType.text,
//                     ),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               CustomButton(title: "Make Payment", onPressed: _makePayment),
//               const SizedBox(height: 40),
//             ],
//           ),
//         ),

//         if (isLoading)
//           Container(
//             color: Colors.black26,
//             child: const Center(child: CircularProgressIndicator()),
//           ),
//       ],
//     );
//   }
// }
