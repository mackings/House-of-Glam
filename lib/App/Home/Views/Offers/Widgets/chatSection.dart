import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hog/constants/currency.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';

class ChatSection extends StatefulWidget {
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
  State<ChatSection> createState() => _ChatSectionState();
}

class _ChatSectionState extends State<ChatSection> {
  bool _showReplyForm = false;

String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null || timestamp.toString().isEmpty) return '';
  
  try {
    final DateTime dt = DateTime.parse(timestamp.toString());
    final now = DateTime.now();
    final difference = now.difference(dt);

    // Just now (< 1 minute)
    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    // Minutes ago (< 1 hour)
    else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    }
    // Hours ago (< 6 hours) - relative
    else if (difference.inHours < 6) {
      return '${difference.inHours}h ago';
    }
    // Today - show time
    else if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
      return 'Today, ${DateFormat('h:mm a').format(dt)}'; // e.g., "Today, 2:30 PM"
    }
    // Yesterday
    else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dt)}'; // e.g., "Yesterday, 2:30 PM"
    }
    // Within last 7 days
    else if (difference.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(dt); // e.g., "Mon, 2:30 PM"
    }
    // This year
    else if (dt.year == now.year) {
      return DateFormat('MMM d • h:mm a').format(dt); // e.g., "Dec 15 • 2:30 PM"
    }
    // Different year
    else {
      return DateFormat('MMM d, yyyy • h:mm a').format(dt); // e.g., "Dec 15, 2024 • 2:30 PM"
    }
  } catch (e) {
    return timestamp.toString();
  }
}

  @override
  Widget build(BuildContext context) {
    final chats = widget.offer["chats"] as List? ?? [];

    return Stack(
      children: [
        // Chat messages
        Column(
          children: [
            Expanded(
              child: chats.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Colors.purple.shade300,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No conversations yet",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start the conversation below",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: chats.length,
                      padding: EdgeInsets.only(
                        top: 10,
                        bottom: _showReplyForm ? 10 : 80,
                        left: 10,
                        right: 10,
                      ),
                      itemBuilder: (context, i) {
                        final chat = chats[i];
                        return _buildChatBubble(chat);
                      },
                    ),
            ),
            // Reply form (slides up when visible)
            if (_showReplyForm) _buildReplyForm(context),
          ],
        ),

        // Floating Action Button
        if (!_showReplyForm)
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => setState(() => _showReplyForm = true),
              backgroundColor: Colors.purple,
              icon: const Icon(Icons.reply_rounded, color: Colors.white),
              label: Text(
                widget.userRole == "user" ? "Make Offer" : "Reply",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              elevation: 4,
            ),
          ),
      ],
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> chat) {
    final isUser = chat["senderType"] == "customer";
    final alignment = isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end;
    
    final materialNGN = int.tryParse(chat["counterMaterialCost"]?.toString() ?? "0") ?? 0;
    final workmanshipNGN = int.tryParse(chat["counterWorkmanshipCost"]?.toString() ?? "0") ?? 0;

    return FutureBuilder<Map<String, double>>(
      future: _convertChatAmounts(materialNGN, workmanshipNGN),
      builder: (context, snapshot) {
        final displayMaterial = snapshot.data?['material'] ?? materialNGN.toDouble();
        final displayWorkmanship = snapshot.data?['workmanship'] ?? workmanshipNGN.toDouble();
        final total = displayMaterial + displayWorkmanship;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: alignment,
            children: [
              Row(
                mainAxisAlignment:
                    isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isUser) _buildAvatar(isUser),
                  if (isUser) const SizedBox(width: 10),
                  
                  Flexible(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isUser
                              ? [Colors.white, Colors.grey.shade50]
                              : [Colors.purple.shade50, Colors.purple.shade100.withOpacity(0.5)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(20),
                          topRight: const Radius.circular(20),
                          bottomLeft: Radius.circular(isUser ? 4 : 20),
                          bottomRight: Radius.circular(isUser ? 20 : 4),
                        ),
                        border: Border.all(
                          color: isUser
                              ? Colors.grey.shade200
                              : Colors.purple.shade200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isUser ? Colors.black : Colors.purple)
                                .withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Sender name
                          Row(
                            children: [
                              Icon(
                                isUser ? Icons.person : Icons.store,
                                size: 14,
                                color: isUser ? Colors.purple.shade700 : Colors.purple.shade800,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                chat["senderName"] ?? "User",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isUser ? Colors.purple.shade700 : Colors.purple.shade900,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 10),
                          
                          // Comment
                          Text(
                            chat["comment"] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: Colors.black87,
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Cost breakdown
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                _buildCostRow(
                                  Icons.checkroom,
                                  "Material",
                                  displayMaterial,
                                ),
                                const SizedBox(height: 6),
                                _buildCostRow(
                                  Icons.handyman,
                                  "Workmanship",
                                  displayWorkmanship,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Divider(
                                    height: 1,
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.attach_money,
                                          size: 14,
                                          color: Colors.purple.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          "Total",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "$currencySymbol${NumberFormat('#,###.##').format(total)}",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Timestamp
Row(
  children: [
    Icon(
      Icons.access_time_rounded,
      size: 10,
      color: Colors.grey.shade500,
    ),
    const SizedBox(width: 4),
    Text(
      _formatTimestamp(chat["timestamp"]),
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade600,
      ),
    ),
  ],
),

                        ],
                      ),
                    ),
                  ),
                  
                  if (!isUser) const SizedBox(width: 10),
                  if (!isUser) _buildAvatar(isUser),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple, Colors.purple.shade300],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.white,
        child: Icon(
          isUser ? Icons.person : Icons.store,
          color: Colors.purple.shade700,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCostRow(IconData icon, String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.purple.shade400),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        Text(
          "$currencySymbol${NumberFormat('#,###.##').format(amount)}",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildReplyForm(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.reply_rounded, color: Colors.purple.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.userRole == "user" ? "Make Your Offer" : "Reply to Buyer",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _showReplyForm = false),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Comment field
          TextField(
            controller: widget.commentCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write your message...",
              filled: true,
              fillColor: Colors.grey.shade50,
              prefixIcon: Icon(Icons.comment_outlined, color: Colors.purple.shade400),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.purple.shade300, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Amount fields
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.materialCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalThousandsFormatter()],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.checkroom, color: Colors.purple.shade400),
                    hintText: "Material ($currencySymbol)",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: widget.workmanshipCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [DecimalThousandsFormatter()],
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.handyman, color: Colors.purple.shade400),
                    hintText: "Work ($currencySymbol)",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildButtons(context),
        ],
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final btnStyle = ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    );

    if (widget.userRole == "user") {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.swap_horiz, color: Colors.white),
          label: const Text(
            "Submit Counter Offer",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          style: btnStyle.copyWith(
            backgroundColor: WidgetStateProperty.all(Colors.purple),
          ),
          onPressed:
              widget.isSubmitting
                  ? null
                  : () => _confirmAction(context, "countered"),
        ),
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.swap_horiz, size: 18, color: Colors.white),
                  label: const Text(
                    "Counter",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: btnStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.orange.shade600),
                  ),
                  onPressed:
                      widget.isSubmitting
                          ? null
                          : () => _confirmAction(context, "countered"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check, size: 18, color: Colors.white),
                  label: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: btnStyle.copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.green.shade600),
                  ),
                  onPressed:
                      widget.isSubmitting
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
              icon: const Icon(Icons.close, color: Colors.red, size: 18),
              label: const Text(
                "Reject Offer",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.red.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed:
                  widget.isSubmitting
                      ? null
                      : () => _confirmAction(context, "rejected"),
            ),
          ),
        ],
      );
    }
  }

  void _confirmAction(BuildContext context, String action) async {
    final rawMaterial = widget.materialCtrl.text.replaceAll(',', '').trim();
    final rawWorkmanship = widget.workmanshipCtrl.text.replaceAll(',', '').trim();

    // Convert back to NGN
    final materialNGN = await CurrencyHelper.convertToNGN(
      double.tryParse(rawMaterial) ?? 0,
    );
    final workNGN = await CurrencyHelper.convertToNGN(
      double.tryParse(rawWorkmanship) ?? 0,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.help_outline, color: Colors.purple.shade700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Confirm ${action.toUpperCase()}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: Text(
          "Are you sure you want to ${action.toLowerCase()} this offer?",
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Yes, Proceed",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _showReplyForm = false);
      widget.onReply(action);
    }
  }

  Future<Map<String, double>> _convertChatAmounts(int materialNGN, int workmanshipNGN) async {
    return {
      'material': await CurrencyHelper.convertFromNGN(materialNGN),
      'workmanship': await CurrencyHelper.convertFromNGN(workmanshipNGN),
    };
  }
}

/// Decimal formatter (reuse from ReusableOfferSheet)
class DecimalThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(',', '');
    
    if (text.isEmpty) return newValue;
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    final parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    if (integerPart.isNotEmpty) {
      final formatter = NumberFormat('#,###');
      integerPart = formatter.format(int.parse(integerPart));
    }

    String formatted = integerPart;
    if (decimalPart != null) {
      formatted += '.$decimalPart';
    } else if (text.endsWith('.')) {
      formatted += '.';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}