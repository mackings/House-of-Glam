import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Banks/Api/BamkService.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
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

  @override
  void initState() {
    super.initState();
    // Auto-fill half payment amount
    _autoFillHalfPayment();
  }

  void _autoFillHalfPayment() {
    // Calculate half of the total amount to pay
    final totalToPay = widget.review.isInternationalVendor
        ? widget.review.totalCostUSD
        : widget.review.totalCost.toDouble();
    final halfAmount = (totalToPay / 2).round();
    amountController.text = halfAmount.toString();
  }

  @override
  void dispose() {
    amountController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _makePayment() async {
    setState(() => isLoading = true);

    try {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('🔥 PAYMENT PROCESSING STARTED');
      print('═══════════════════════════════════════════════════════════');
      
      final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
      final isInternationalVendor = vendorCountry == 'UNITED STATES' ||
          vendorCountry == 'US' ||
          vendorCountry == 'USA' ||
          vendorCountry == 'UNITED KINGDOM' ||
          vendorCountry == 'UK' ||
          vendorCountry == 'GB';

      print('📋 VENDOR INFO:');
      print('   Vendor Country: $vendorCountry');
      print('   Is International Vendor: $isInternationalVendor');
      print('   Vendor Name: ${widget.review.user.fullName}');
      print('');

      // Get user's country
      final userCountry = await CurrencyHelper.getUserCountry();
      final isUserInNigeria = userCountry?.toUpperCase() == 'NIGERIA' || 
                              userCountry?.toUpperCase() == 'NG';

      print('👤 USER INFO:');
      print('   User Country: $userCountry');
      print('   Is User in Nigeria: $isUserInNigeria');
      print('   User Currency Symbol: $currencySymbol');
      print('');

      print('📦 REVIEW/ORDER INFO:');
      print('   Review ID: ${widget.review.id}');
      print('   Total Cost (stored): ${widget.review.totalCost}');
      print('   Amount Paid (stored): ${widget.review.amountPaid}');
      print('   Amount To Pay (stored): ${widget.review.amountToPay}');
      print('   Remaining Balance: ${widget.review.totalCost - widget.review.amountPaid}');
      print('');

      print('💳 PAYMENT DETAILS:');
      print('   Payment Type: $paymentType');
      print('   Shipment Method: $shipment');
      print('');

      // ✅ FOR INTERNATIONAL VENDORS - Use Stripe
      if (isInternationalVendor) {
        print('🌍 INTERNATIONAL VENDOR DETECTED - Using Stripe');
        print('');
        
        String? amountToSend;
        String? addressToSend;

        // Determine vendor's target currency
        final targetCurrency = vendorCountry.contains('UNITED STATES') || 
                              vendorCountry == 'US' || 
                              vendorCountry == 'USA'
            ? 'USD'
            : 'GBP';

        print('💱 TARGET CURRENCY: $targetCurrency');
        print('');

        if (paymentType == "part") {
          print('📝 PART PAYMENT PROCESSING:');

          if (amountController.text.trim().isEmpty) {
            setState(() => isLoading = false);
            print('❌ ERROR: Amount field is empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter an amount")),
            );
            return;
          }

          // ✅ NEW: User enters in THEIR currency, but BACKEND expects NGN
          final userEnteredAmount = double.parse(amountController.text.replaceAll(",", ""));
          print('   User Entered Amount: $userEnteredAmount');
          print('   User Currency: ${isUserInNigeria ? "NGN" : targetCurrency}');
          print('');

          if (isUserInNigeria) {
            // ✅ Nigerian user entering NGN - send as-is, backend handles conversion
            amountToSend = userEnteredAmount.round().toString();
            print('✅ NO CONVERSION NEEDED - Backend will convert');
            print('   User entered: ₦$userEnteredAmount');
            print('   Sending to backend: $amountToSend NGN');
            print('   Backend will convert: NGN → USD for Stripe');
          } else {
            // ✅ International user entering USD/GBP - convert to NGN first
            print('🔄 CONVERSION NEEDED: $targetCurrency → NGN');
            print('   Amount to Convert: \$$userEnteredAmount');
            print('');

            final ngnAmount = await CurrencyHelper.convertToNGN(userEnteredAmount);
            amountToSend = ngnAmount.toString();

            print('✅ CONVERSION SUCCESS');
            print('   From: \$$userEnteredAmount');
            print('   To: ₦$ngnAmount');
            print('   Sending to backend: $amountToSend NGN');
            print('   Backend will convert: NGN → USD for Stripe');
          }
          print('');
        } else {
          // ✅ Full payment - backend uses review.amountToPay, NO amount needed
          print('💰 FULL PAYMENT PROCESSING:');

          if (addressController.text.trim().isEmpty) {
            setState(() => isLoading = false);
            print('❌ ERROR: Delivery address is empty');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Please enter delivery address")),
            );
            return;
          }

          print('   Total Cost (stored): ${widget.review.totalCost}');
          print('   Amount Paid (stored): ${widget.review.amountPaid}');
          print('   Amount To Pay (stored): ${widget.review.amountToPay}');
          print('');

          if (widget.review.amountToPay <= 0) {
            setState(() => isLoading = false);
            print('❌ ERROR: No balance remaining');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No balance left to pay")),
            );
            return;
          }

          // ✅ For full payment, send NULL - backend uses review.amountToPay
          amountToSend = null;
          addressToSend = addressController.text.trim();

          print('✅ FULL PAYMENT - No amount sent');
          print('   Backend will use: review.amountToPay from database');
          print('   Delivery Address: $addressToSend');
          print('');
        }

        // Create Stripe checkout
        print('───────────────────────────────────────────────────────────');
        print('📤 SENDING TO STRIPE CHECKOUT:');
        print('   Review ID: ${widget.review.id}');
        print('   Shipment Method: $shipment');
        print('   Amount: $targetCurrency $amountToSend');
        print('   Address: ${addressToSend ?? "N/A (part payment)"}');
        print('───────────────────────────────────────────────────────────');
        print('');

        final resp = await BankApiService.stripeCheckoutPayment(
          reviewId: widget.review.id,
          shipmentMethod: shipment,
          paymentStatus: paymentType == "part" ? "part payment" : "full payment",
          amount: amountToSend,
          address: addressToSend,
        );

        print('📥 STRIPE RESPONSE:');
        print('   Success: ${resp["success"]}');
        if (resp["success"] == true) {
          print('   Checkout URL: ${resp["checkoutUrl"]}');
        } else {
          print('   Error: ${resp["error"]}');
        }
        print('');

        setState(() => isLoading = false);

        if (resp["success"] == true) {
          final url = resp["checkoutUrl"];
          if (url != null) {
            print('✅ PAYMENT INITIATED SUCCESSFULLY');
            print('═══════════════════════════════════════════════════════════');
            print('');
            Navigator.of(context).pop();
            widget.onCheckout(url);
          }
        } else {
          print('❌ PAYMENT FAILED');
          print('═══════════════════════════════════════════════════════════');
          print('');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resp["error"] ?? "Stripe checkout failed")),
          );
        }
        return;
      }

      // ✅ FOR NIGERIAN VENDORS - Use Paystack
      print('🇳🇬 NIGERIAN VENDOR DETECTED - Using Paystack');
      print('');
      
      String amountToSend;

      if (paymentType == "part") {
        print('📝 PART PAYMENT PROCESSING:');
        
        if (amountController.text.trim().isEmpty) {
          setState(() => isLoading = false);
          print('❌ ERROR: Amount field is empty');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter an amount")),
          );
          return;
        }

        // User enters in THEIR currency
        final userEnteredAmount = double.parse(amountController.text.replaceAll(",", ""));
        print('   User Entered Amount: $userEnteredAmount');
        print('   User Currency: ${isUserInNigeria ? "NGN" : "USD/GBP"}');
        print('');

        if (isUserInNigeria) {
          // Nigerian user entering NGN - send as-is (vendor expects NGN)
          amountToSend = userEnteredAmount.toString();
          print('✅ NO CONVERSION NEEDED');
          print('   Both user and vendor are in Nigeria');
          print('   Amount to Send to Paystack: NGN $amountToSend');
        } else {
          // International user entering USD/GBP - convert to NGN
          print('🔄 CONVERSION NEEDED: USD/GBP → NGN');
          print('   Amount to Convert: $userEnteredAmount');
          print('');
          
          print('📞 Calling CurrencyHelper.convertToNGN...');
          final ngnAmount = await CurrencyHelper.convertToNGN(userEnteredAmount);
          amountToSend = ngnAmount.toString();
          
          print('✅ CONVERSION SUCCESS');
          print('   From: \$$userEnteredAmount');
          print('   To: ₦$ngnAmount');
          print('   Amount to Send to Paystack: NGN $amountToSend');
        }
        print('');
      } else {
        // Full payment
        print('💰 FULL PAYMENT PROCESSING:');
        
        if (addressController.text.trim().isEmpty) {
          setState(() => isLoading = false);
          print('❌ ERROR: Delivery address is empty');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please enter delivery address")),
          );
          return;
        }

        // Amounts are stored in NGN (vendor currency)
        final remainingNGN = widget.review.totalCost - widget.review.amountPaid;
        
        print('   Total Cost (stored): ${widget.review.totalCost}');
        print('   Amount Paid (stored): ${widget.review.amountPaid}');
        print('   Remaining Balance: $remainingNGN');
        print('   Storage Currency: NGN (vendor currency)');
        print('');
        
        if (remainingNGN <= 0) {
          setState(() => isLoading = false);
          print('❌ ERROR: No balance remaining');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No balance left to pay")),
          );
          return;
        }

        // Send remaining balance in NGN
        amountToSend = remainingNGN.toString();
        print('✅ FULL PAYMENT AMOUNT');
        print('   Amount to Send to Paystack: NGN $amountToSend');
        print('');
      }

      print('───────────────────────────────────────────────────────────');
      print('📤 SENDING TO PAYSTACK:');
      print('   Review ID: ${widget.review.id}');
      print('   Shipment Method: $shipment');
      print('   Amount: NGN $amountToSend');
      print('───────────────────────────────────────────────────────────');
      print('');

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

      print('📥 PAYSTACK RESPONSE:');
      print('   Success: ${resp?["success"]}');
      if (resp?["success"] == true) {
        print('   Authorization URL: ${resp?["authorizationUrl"]}');
      }
      print('');

      setState(() => isLoading = false);

      if (resp != null && resp["success"]) {
        final url = resp["authorizationUrl"];
        if (url != null) {
          print('✅ PAYMENT INITIATED SUCCESSFULLY');
          print('═══════════════════════════════════════════════════════════');
          print('');
          Navigator.of(context).pop();
          widget.onCheckout(url);
        }
      } else {
        print('❌ PAYMENT FAILED');
        print('═══════════════════════════════════════════════════════════');
        print('');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Payment failed")),
        );
      }
    } catch (e, stackTrace) {
      setState(() => isLoading = false);
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ PAYMENT ERROR');
      print('═══════════════════════════════════════════════════════════');
      print('Error: $e');
      print('Stack Trace:');
      print(stackTrace);
      print('═══════════════════════════════════════════════════════════');
      print('');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendorCountry = widget.review.user.country?.toUpperCase() ?? '';
    final isInternationalVendor = vendorCountry == 'UNITED STATES' ||
        vendorCountry == 'US' ||
        vendorCountry == 'USA' ||
        vendorCountry == 'UNITED KINGDOM' ||
        vendorCountry == 'UK' ||
        vendorCountry == 'GB';

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
                          "International vendor - Payment via Stripe",
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                ),

              if (isInternationalVendor) const SizedBox(height: 12),

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
                  hintText: "Enter amount in your currency",
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              const SizedBox(height: 12),

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
              CustomButton(
                title: "Make Payment",
                onPressed: _makePayment,
              ),
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
