import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/App/Home/Api/paymentService.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/formfields.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/components/thousandformat.dart';



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
  String paymentType = "part"; // 👈 Default is now part payment
  String shipment = "Regular";
  final TextEditingController amountController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    amountController.clear(); // 👈 Start with empty field
  }

Future<void> _makePayment() async {
  setState(() => isLoading = true);

  String amountToSend;

  if (paymentType == "part") {
    if (amountController.text.trim().isEmpty) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an amount for part payment")),
      );
      return;
    }
    amountToSend = amountController.text.replaceAll(",", "");
  } else {
    // ✅ Use the balance coming from backend
    if (widget.review.amountToPay <= 0) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No balance left to pay")),
      );
      return;
    }
    amountToSend = widget.review.amountToPay.toString();
  }

  Map<String, dynamic>? resp;

  if (paymentType == "part") {
    resp = await PaymentService.createPartPayment(
      reviewId: widget.review.id,
      amount: amountToSend,
      shipmentMethod: shipment,
    );
  } else {
    resp = await PaymentService.createFullPayment(
      reviewId: widget.review.id,
      amount: amountToSend,
      shipmentMethod: shipment,
    );
  }

  setState(() => isLoading = false);

  if (resp != null && resp["success"]) {
    widget.onCheckout(resp["authorizationUrl"]);
    Navigator.pop(context);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Payment initialization failed")),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomText(
                "Choose Payment Option",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),

              // Payment Type
              Row(
                children: [
                  Radio(
                    value: "full",
                    groupValue: paymentType,
                    onChanged: (val) {
                      setState(() {
                        paymentType = val!;
                        if (paymentType == "part") {
                          amountController.clear(); // 👈 reset when switching
                        }
                      });
                    },
                  ),
                  const Text("Full Payment"),
                  Radio(
                    value: "part",
                    groupValue: paymentType,
                    onChanged: (val) {
                      setState(() {
                        paymentType = val!;
                        if (paymentType == "part") {
                          amountController.clear(); // 👈 reset when switching
                        }
                      });
                    },
                  ),
                  const Text("Part Payment"),
                ],
              ),
              const SizedBox(height: 12),

              if (paymentType == "part")
                CustomTextField(
                  title: "Amount",
                  fieldKey: "amount",
                  hintText: "Enter Amount",
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    ThousandsFormatter(),
                  ],
                ),

              const SizedBox(height: 12),

              // Shipment dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    "Shipment Method",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
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
                      items: ["Regular", "Express", "Cargo"]
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => shipment = val!),
                    ),
                  ),
                ],
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

        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}
