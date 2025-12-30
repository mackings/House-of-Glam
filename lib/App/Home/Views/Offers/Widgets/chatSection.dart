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

      if (difference.inSeconds < 60) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 6) {
        return '${difference.inHours}h ago';
      } else if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return 'Today, ${DateFormat('h:mm a').format(dt)}';
      } else if (difference.inDays == 1) {
        return 'Yesterday, ${DateFormat('h:mm a').format(dt)}';
      } else if (difference.inDays < 7) {
        return DateFormat('EEE, h:mm a').format(dt);
      } else if (dt.year == now.year) {
        return DateFormat('MMM d • h:mm a').format(dt);
      } else {
        return DateFormat('MMM d, yyyy • h:mm a').format(dt);
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
                          // ✅ Sender label (You/Designer)
                          Text(
                            isUser ? "You" : "Designer",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isUser ? Colors.purple.shade700 : Colors.purple.shade900,
                            ),
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
                          
                         // Replace the Accept Offer Button section in _buildChatBubble with this:

const SizedBox(height: 12),

// ✅ Accept Offer Button (show for both user and designer - they see each other's offers)
if ((isUser && widget.userRole == "tailor") || (!isUser && widget.userRole == "user"))
  SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: () => _showAcceptOfferSheet(
        context,
        displayMaterial,
        displayWorkmanship,
      ),
      icon: const Icon(Icons.check_circle, size: 18),
      label: const Text(
        "Accept This Offer",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
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

  // ✅ Accept Offer Bottom Sheet
// ✅ Accept Offer Bottom Sheet
void _showAcceptOfferSheet(
  BuildContext context,
  double materialAmount,
  double workmanshipAmount,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Accept Offer",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Review the offer details",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Cost breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Material Cost", materialAmount),
                  const SizedBox(height: 12),
                  _buildSummaryRow("Workmanship Cost", workmanshipAmount),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1, color: Colors.grey.shade300),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "$currencySymbol${NumberFormat('#,###.##').format(materialAmount + workmanshipAmount)}",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      
                      // ✅ Set a default comment if empty
                      if (widget.commentCtrl.text.trim().isEmpty) {
                        widget.commentCtrl.text = "I accept this offer";
                      }
                      
                      // Set the amounts in the text fields
                      widget.materialCtrl.text = NumberFormat('#,###.##').format(materialAmount);
                      widget.workmanshipCtrl.text = NumberFormat('#,###.##').format(workmanshipAmount);
                      
                      // Call the accept action
                       _confirmAction(context, "accepted");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Accept Offer",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}



  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          "$currencySymbol${NumberFormat('#,###.##').format(amount)}",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
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
    // ✅ For accept action, amounts are auto-detected by backend - no need to validate here
    // ✅ For counter/reject, we still need the amounts
    if (action != "accepted") {
      final rawMaterial = widget.materialCtrl.text.replaceAll(',', '').trim();
      final rawWorkmanship = widget.workmanshipCtrl.text.replaceAll(',', '').trim();

      if (action == "countered" && (rawMaterial.isEmpty || rawWorkmanship.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text("Please enter counter offer amounts")),
              ],
            ),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        return;
      }
    }

    // ✅ Show different confirmation dialogs based on action
    Color actionColor;
    IconData actionIcon;
    String actionTitle;
    String actionMessage;

    switch (action) {
      case "accepted":
        actionColor = Colors.green.shade600;
        actionIcon = Icons.check_circle;
        actionTitle = "Accept Offer";
        actionMessage = "Accept this offer? The review will be updated with these amounts.";
        break;
      case "rejected":
        actionColor = Colors.red.shade600;
        actionIcon = Icons.cancel;
        actionTitle = "Reject Offer";
        actionMessage = "Reject this offer? This action cannot be undone.";
        break;
      case "countered":
        actionColor = Colors.orange.shade600;
        actionIcon = Icons.swap_horiz;
        actionTitle = "Counter Offer";
        actionMessage = "Send counter offer with your proposed amounts?";
        break;
      default:
        actionColor = Colors.purple;
        actionIcon = Icons.help_outline;
        actionTitle = "Confirm Action";
        actionMessage = "Are you sure you want to proceed?";
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: actionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(actionIcon, color: actionColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                actionTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              actionMessage,
              style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
            ),
            if (action == "accepted") ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Amounts will be auto-detected from the latest offer",
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.black54, fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              elevation: 0,
            ),
            child: Text(
              action == "accepted" ? "Accept" : action == "rejected" ? "Reject" : "Send Counter",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
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