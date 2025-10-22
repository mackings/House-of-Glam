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

  String paymentType = "part";
  String shipment = "Regular";

  final TextEditingController amountController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    amountController.clear();
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }




  Future<void> _makePayment() async {
    setState(() => isLoading = true);

    String amountToSend;

    if (paymentType == "part") {
      if (amountController.text.trim().isEmpty) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please enter an amount for part payment"),
          ),
        );
        return;
      }
      amountToSend = amountController.text.replaceAll(",", "");
    } else {
      // ✅ Full payment logic
      final int remaining = widget.review.totalCost - widget.review.amountPaid;

      if (remaining <= 0) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("No balance left to pay")));
        return;
      }

      amountToSend = remaining.toString();
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
        address: addressController.text.trim()
      );
    }

    setState(() => isLoading = false);

    if (resp != null && resp["success"]) {
      final url = resp["authorizationUrl"];
      if (url != null) {
        // ✅ Close only THIS modal and call parent
        Navigator.of(context).pop();
        widget.onCheckout(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No payment link received")),
        );
      }
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
            top: 36,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CustomText(
                    "Choose a Payment Option",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Payment Type Radios
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
                        paymentType = val!;
                        amountController.clear();
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

              // Shipment
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const CustomText(
                    "Shipment Method",
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
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
  decoration: const InputDecoration(
    border: InputBorder.none,
  ),
  items: const [
    DropdownMenuItem(
      value: "Regular",
      child: Text("Regular (1–8 days)"),
    ),
    DropdownMenuItem(
      value: "Express",
      child: Text("Express (1–4 days)"),
    ),
    DropdownMenuItem(
      value: "Cargo",
      child: Text("Cargo (1–15 days)"),
    ),
  ],
  onChanged: (val) => setState(() => shipment = val!),
),


                  ),


             if (paymentType != "part")
             CustomTextField(
                  title: "Address",
                  fieldKey: "Address",
                  hintText: "Enter delivery address",
                  controller: addressController,
                  keyboardType: TextInputType.text,

                ),


                  
                ],
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
  }
}
