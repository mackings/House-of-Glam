import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/constants/currency.dart';
import 'package:intl/intl.dart';


class ChatSection extends StatelessWidget {
  final Map<String, dynamic> offer;
  final String userRole;
  final TextEditingController commentCtrl;
  final TextEditingController materialCtrl;
  final TextEditingController workmanshipCtrl;
  final bool isSubmitting;
  final Future<void> Function(String) onReply;
  final Future<void> Function() onMakeOffer;

  const ChatSection({
    super.key,
    required this.offer,
    required this.userRole,
    required this.commentCtrl,
    required this.materialCtrl,
    required this.workmanshipCtrl,
    required this.isSubmitting,
    required this.onReply,
    required this.onMakeOffer,
  });

  @override
  Widget build(BuildContext context) {
    final chats = offer["chats"] as List? ?? [];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: chats.length,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            itemBuilder: (context, i) {
              final chat = chats[i];
              final isUser = chat["senderType"] == "customer";
              final alignment =
                  isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end;
              final bubbleColor = isUser
                  ? Colors.purple.shade50
                  : Colors.purple.withOpacity(0.15);
              final borderRadius = BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isUser ? 0 : 16),
                bottomRight: Radius.circular(isUser ? 16 : 0),
              );

              return Column(
                crossAxisAlignment: alignment,
                children: [
                  Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isUser)
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(Icons.person,
                              color: Colors.purple, size: 18),
                        ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: bubbleColor,
                            borderRadius: borderRadius,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                chat["senderName"] ?? "User",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat["comment"] ?? '',
                                style: const TextStyle(fontSize: 13),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "₦${chat["counterMaterialCost"] ?? 0} | ₦${chat["counterWorkmanshipCost"] ?? 0}",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    chat["timestamp"] ?? '',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isUser) const SizedBox(width: 8),
                      if (!isUser)
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.purple.shade100,
                          child: const Icon(Icons.store,
                              color: Colors.purple, size: 18),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        _buildReplyForm(context),
      ],
    );
  }

  Widget _buildReplyForm(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: commentCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: userRole == "user"
                ? "Write your offer..."
                : "Reply to buyer...",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: materialCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.checkroom, color: Colors.purple),
                  hintText: "Material ${currencySymbol}",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: workmanshipCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [ThousandsFormatter()],
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.handyman, color: Colors.purple),
                  hintText: "Workmanship (₦)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _buildButtons(context),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      backgroundColor: Colors.purple,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );

    if (userRole == "user") {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.swap_horiz),
          label: const Text("Counter Offer"),
          style: btnStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.purple.shade400),
          ),
          onPressed:
              isSubmitting ? null : () => _confirmAction(context, "countered"),
        ),
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text("Counter"),
                  style: btnStyle.copyWith(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.orange.shade600),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () => _confirmAction(context, "countered"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  label: const Text("Accept"),
                  style: btnStyle.copyWith(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.green.shade600),
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () => _confirmAction(context, "accepted"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.close, color: Colors.black87),
              label: const Text("Reject",
                  style: TextStyle(color: Colors.black87, fontSize: 14)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.black54),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: isSubmitting
                  ? null
                  : () => _confirmAction(context, "rejected"),
            ),
          ),
        ],
      );
    }
  }

  void _confirmAction(BuildContext context, String action) {
    final rawMaterial =
        materialCtrl.text.replaceAll(',', '').trim(); // remove commas
    final rawWorkmanship =
        workmanshipCtrl.text.replaceAll(',', '').trim(); // remove commas

    print("📤 Sending Material: $rawMaterial, Workmanship: $rawWorkmanship");

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          children: [
            Icon(Icons.help_outline, color: Colors.purple.shade400, size: 40),
            const SizedBox(height: 10),
            Text(
              "Are you sure you want to ${action.toUpperCase()} this offer?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                    ),
                    child: const Text("Yes, Proceed",
                        style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context);
                      onReply(action);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ThousandsFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat("#,###");

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(',', '');
    if (digits.isEmpty) return newValue;

    final formatted = _formatter.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection:
          TextSelection.collapsed(offset: formatted.length), // keep cursor end
    );
  }
}
