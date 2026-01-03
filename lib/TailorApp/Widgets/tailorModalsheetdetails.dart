import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Widgets/UpdateQuote.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';


void showTailorMaterialDetails(
  BuildContext context,
  TailorAssignedMaterial item,
) {
  final material = item.material;
  final service = TailorHomeService();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return StatefulBuilder(
          builder: (context, setState) {
            bool isLoading = false;

            Future<void> _deliverAttire() async {
              try {
                setState(() => isLoading = true);
                await service.deliverAttire(material.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Attire delivered successfully!",
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } catch (e) {
                Nav.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "❌ $e",
                      style: GoogleFonts.poppins(),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } finally {
                setState(() => isLoading = false);
              }
            }

            final displayAmounts = _getDisplayAmounts(item);

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Hero Image Section
                          if (material.sampleImages.isNotEmpty)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(32),
                                    topRight: Radius.circular(32),
                                  ),
                                  child: Image.network(
                                    material.sampleImages.first,
                                    width: double.infinity,
                                    height: 280,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 20,
                                  right: 20,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusBackgroundColor(item.status),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      _formatStatus(item.status),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title Section
                                Text(
                                  material.attireType,
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Material Tags
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildTag(
                                      material.clothMaterial,
                                      Icons.checkroom_rounded,
                                      const Color(0xFF6B21A8),
                                    ),
                                    _buildTag(
                                      material.color,
                                      Icons.palette_rounded,
                                      const Color(0xFF7C3AED),
                                    ),
                                    _buildTag(
                                      material.brand,
                                      Icons.local_offer_rounded,
                                      const Color(0xFF8B5CF6),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 32),

                                // Customer Card
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6B21A8),
                                        Color(0xFF7C3AED),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6B21A8).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "CUSTOMER",
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.7),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.3),
                                                width: 2,
                                              ),
                                            ),
                                            child: CircleAvatar(
                                              radius: 26,
                                              backgroundColor: Colors.white.withOpacity(0.2),
                                              backgroundImage: item.user.image != null
                                                  ? NetworkImage(item.user.image!)
                                                  : null,
                                              child: item.user.image == null
                                                  ? Text(
                                                      item.user.fullName.isNotEmpty
                                                          ? item.user.fullName[0].toUpperCase()
                                                          : "?",
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.w600,
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : null,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  item.user.fullName,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item.user.email,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.white.withOpacity(0.8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Financial Overview
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF1F2937),
                                        Color(0xFF111827),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "FINANCIAL OVERVIEW",
                                            style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white.withOpacity(0.5),
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF6B21A8).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Icon(
                                              Icons.account_balance_wallet_rounded,
                                              color: Color(0xFF7C3AED),
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 24),
                                      _buildFinancialRow(
                                        "Material Cost",
                                        displayAmounts['materialCost']!,
                                        false,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildFinancialRow(
                                        "Workmanship",
                                        displayAmounts['workmanshipCost']!,
                                        false,
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        height: 1,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.0),
                                              Colors.white.withOpacity(0.1),
                                              Colors.white.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      _buildFinancialRow(
                                        "Total",
                                        displayAmounts['totalCost']!,
                                        true,
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildPaymentStatus(
                                              "Paid",
                                              displayAmounts['amountPaid']!,
                                              const Color(0xFF10B981),
                                              Icons.check_circle_rounded,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _buildPaymentStatus(
                                              "Balance",
                                              displayAmounts['amountToPay']!,
                                              displayAmounts['amountToPay']! <= 0
                                                  ? Colors.white.withOpacity(0.6)
                                                  : const Color(0xFFF59E0B),
                                              displayAmounts['amountToPay']! <= 0
                                                  ? Icons.check_circle_rounded
                                                  : Icons.schedule_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Vendor Information
                                _buildSection(
                                  "Vendor Information",
                                  Icons.store_rounded,
                                  [
                                    _buildDetailRow("Business Name", item.vendor.businessName),
                                    _buildDetailRow("Email", item.vendor.businessEmail),
                                    _buildDetailRow("Phone", item.vendor.businessPhone),
                                    if (item.country != null)
                                      _buildDetailRow("Country", item.country!),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Timeline
                                _buildSection(
                                  "Timeline",
                                  Icons.timeline_rounded,
                                  [
                                    _buildDetailRow(
                                      "Created",
                                      DateFormat("MMM dd, yyyy").format(item.createdAt),
                                    ),
                                    if (item.deliveryDate != null)
                                      _buildDetailRow(
                                        "Delivery",
                                        DateFormat("MMM dd, yyyy").format(item.deliveryDate!),
                                      ),
                                    if (item.reminderDate != null)
                                      _buildDetailRow(
                                        "Reminder",
                                        DateFormat("MMM dd, yyyy").format(item.reminderDate!),
                                      ),
                                  ],
                                ),

                                if (item.comment != null && item.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 24),
                                  _buildSection(
                                    "Comment",
                                    Icons.comment_rounded,
                                    [
                                      Text(
                                        item.comment!,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: const Color(0xFF6B7280),
                                          height: 1.6,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],

                                const SizedBox(height: 32),

                                // Action Button
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6B21A8),
                                        Color(0xFF7C3AED),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6B21A8).withOpacity(0.4),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              if (item.status.toLowerCase() == "requesting") {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  backgroundColor: Colors.transparent,
                                                  builder: (_) => UpdateQuotationBottomSheet(
                                                    materialId: material.id,
                                                  ),
                                                );
                                              } else {
                                                _deliverAttire();
                                              }
                                            },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Center(
                                        child: isLoading
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5,
                                                ),
                                              )
                                            : Text(
                                                item.status.toLowerCase() == "requesting"
                                                    ? "Update Quotation"
                                                    : "Deliver Attire",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}

Map<String, double> _getDisplayAmounts(TailorAssignedMaterial item) {
  final isInternational = item.isInternationalVendor || 
      (item.country != null && item.country!.toUpperCase() != 'NG');

  if (isInternational) {
    return {
      'materialCost': item.materialTotalCostUSD ?? 0.0,
      'workmanshipCost': item.workmanshipTotalCostUSD ?? 0.0,
      'totalCost': item.totalCostUSD ?? 0.0,
      'amountPaid': item.amountPaidUSD ?? 0.0,
      'amountToPay': item.amountToPayUSD ?? 0.0,
    };
  } else {
    return {
      'materialCost': item.materialTotalCost,
      'workmanshipCost': item.workmanshipTotalCost,
      'totalCost': item.totalCost,
      'amountPaid': item.amountPaid ?? 0.0,
      'amountToPay': item.amountToPay ?? 0.0,
    };
  }
}

Widget _buildTag(String label, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildFinancialRow(String label, double amount, bool isTotal) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: isTotal ? 15 : 14,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          color: Colors.white.withOpacity(isTotal ? 0.9 : 0.6),
        ),
      ),
      Text(
        CurrencyHelper.formatAmount(amount),
        style: GoogleFonts.poppins(
          fontSize: isTotal ? 20 : 15,
          fontWeight: FontWeight.w700,
          color: isTotal ? Colors.white : Colors.white.withOpacity(0.9),
        ),
      ),
    ],
  );
}

Widget _buildPaymentStatus(String label, double amount, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
        color: Colors.white.withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          CurrencyHelper.formatAmount(amount),
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

Widget _buildSection(String title, IconData icon, List<Widget> children) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFFFAF5FF),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: const Color(0xFF6B21A8).withOpacity(0.1),
        width: 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B21A8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: const Color(0xFF6B21A8),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    ),
  );
}

Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

Color _statusBackgroundColor(String status) {
  switch (status.toLowerCase()) {
    case "full payment":
      return const Color(0xFF10B981);
    case "part payment":
      return const Color(0xFFF59E0B);
    case "pending":
      return const Color(0xFF6B7280);
    case "requesting":
      return const Color(0xFF3B82F6);
    default:
      return const Color(0xFF6B7280);
  }
}

String _formatStatus(String status) {
  return status.split(' ').map((word) => 
    word[0].toUpperCase() + word.substring(1).toLowerCase()
  ).join(' ');
}