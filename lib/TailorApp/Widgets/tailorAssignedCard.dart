import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;



class TailorAssignedCard extends StatelessWidget {
  final TailorAssignedMaterial item;
  final VoidCallback onTap;

  const TailorAssignedCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  Map<String, double> _getDisplayAmounts() {
    final countryCode = item.country?.trim().toUpperCase();
    final isInternational =
        item.isInternationalVendor ||
        (countryCode != null &&
            countryCode != 'NG' &&
            countryCode != 'NIGERIA');

    if (isInternational) {
      final material = item.materialTotalCostUSD ?? 0.0;
      final workmanship = item.workmanshipTotalCostUSD ?? 0.0;
      final total =
          (item.totalCostUSD ?? 0.0) > 0
              ? item.totalCostUSD!
              : (material + workmanship > 0
                  ? material + workmanship
                  : (item.amountPaidUSD ?? 0.0) + (item.amountToPayUSD ?? 0.0));
      final paid =
          (item.amountPaidUSD ?? 0.0) > 0
              ? item.amountPaidUSD!
              : (total > 0 && (item.amountToPayUSD ?? 0.0) > 0
                  ? (total - (item.amountToPayUSD ?? 0.0))
                  : 0.0);
      final toPay =
          (item.amountToPayUSD ?? 0.0) > 0
              ? item.amountToPayUSD!
              : (total > 0 && paid > 0 ? (total - paid) : 0.0);
      return {
        'totalCost': total,
        'amountPaid': paid,
        'amountToPay': toPay,
      };
    } else {
      final material = item.materialTotalCost;
      final workmanship = item.workmanshipTotalCost;
      final total =
          item.totalCost > 0
              ? item.totalCost
              : (material + workmanship > 0
                  ? material + workmanship
                  : (item.amountPaid ?? 0.0) + (item.amountToPay ?? 0.0));
      final paid =
          (item.amountPaid ?? 0.0) > 0
              ? item.amountPaid!
              : (total > 0 && (item.amountToPay ?? 0.0) > 0
                  ? (total - (item.amountToPay ?? 0.0))
                  : 0.0);
      final toPay =
          (item.amountToPay ?? 0.0) > 0
              ? item.amountToPay!
              : (total > 0 && paid > 0 ? (total - paid) : 0.0);
      return {
        'totalCost': total,
        'amountPaid': paid,
        'amountToPay': toPay,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = item.material;
    final displayAmounts = _getDisplayAmounts();
    final totalAmount = displayAmounts['totalCost']!;
    final paidAmount = displayAmounts['amountPaid']!;
    final outstandingUserPayment = displayAmounts['amountToPay']! > 0;
    final isPartPayment = item.status.toLowerCase() == "part payment";
    final paidDisplayRaw =
        isPartPayment || outstandingUserPayment ? paidAmount : totalAmount;
    final isFullPayment = item.status.toLowerCase() == "full payment";
    final paidDisplay =
        isFullPayment ? totalAmount : (paidDisplayRaw * 0.80);
    final payableBalanceRaw =
        isPartPayment || outstandingUserPayment
            ? displayAmounts['amountToPay']!
            : totalAmount * 0.90;
    final payableBalance = payableBalanceRaw.abs();
    final balanceLabel =
        isPartPayment || outstandingUserPayment ? "Balance" : "Payable Balance";
    final isFullyPaid = !outstandingUserPayment;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6B21A8).withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Purple Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF6B21A8), const Color(0xFF7C3AED)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Material Image
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child:
                                material.sampleImages.isNotEmpty
                                    ? Image.network(
                                      material.sampleImages.first,
                                      fit: BoxFit.cover,
                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          color: Colors.white.withOpacity(0.1),
                                          child: Icon(
                                            Icons.checkroom_rounded,
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            size: 32,
                                          ),
                                        );
                                      },
                                    )
                                    : Container(
                                      color: Colors.white.withOpacity(0.1),
                                      child: Icon(
                                        Icons.checkroom_rounded,
                                        color: Colors.white.withOpacity(0.6),
                                        size: 32,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title and Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                material.attireType,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      material.clothMaterial,
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getColorFromString(
                                        material.color,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Status Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _statusBackgroundColor(item.status),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _formatStatus(item.status),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _statusTextColor(item.status),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // White Content Section
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 5),

                    if (outstandingUserPayment) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFF59E0B).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Color(0xFFF59E0B),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "User has an outstanding payment to complete.",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF92400E),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Payment Summary - Light Modern Style
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6B21A8).withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF7C3AED)
                                      .withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Color(0xFF6B21A8),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total Amount",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyHelper.formatAmount(totalAmount),
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF111827),
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isFullyPaid
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFFEDD5),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isFullyPaid ? "Paid" : "Outstanding",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isFullyPaid
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFEA580C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 1,
                            color: const Color(0xFFE2E8F0),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _paymentStat(
                                  label: "Paid",
                                  value: CurrencyHelper.formatAmount(
                                    paidDisplay,
                                  ),
                                  color: const Color(0xFF16A34A),
                                  icon: Icons.check_circle_rounded,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _paymentStat(
                                  label: balanceLabel,
                                  value: CurrencyHelper.formatAmount(
                                    payableBalance,
                                  ),
                                  color:
                                      isFullyPaid
                                          ? const Color(0xFF64748B)
                                          : const Color(0xFFF59E0B),
                                  icon:
                                      isFullyPaid
                                          ? Icons.check_circle_rounded
                                          : Icons.schedule_rounded,
                                  alignEnd: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusBackgroundColor(String status) {
    switch (status.toLowerCase()) {
      case "full payment":
        return Colors.white.withOpacity(0.2);
      case "part payment":
        return const Color(0xFFF59E0B).withOpacity(0.2);
      case "pending":
        return Colors.white.withOpacity(0.1);
      case "requesting":
        return const Color(0xFF3B82F6).withOpacity(0.2);
      default:
        return Colors.white.withOpacity(0.1);
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case "full payment":
        return Colors.white;
      case "part payment":
        return Colors.white;
      case "pending":
        return Colors.white.withOpacity(0.9);
      case "requesting":
        return Colors.white;
      default:
        return Colors.white.withOpacity(0.9);
    }
  }

  String _formatStatus(String status) {
    return status
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Widget _paymentStat({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment:
              alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Color _getColorFromString(String colorName) {
    final colorMap = {
      'red': Colors.red,
      'blue': Colors.blue,
      'green': Colors.green,
      'yellow': Colors.yellow,
      'purple': Colors.purple,
      'orange': Colors.orange,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'grey': Colors.grey,
      'gray': Colors.grey,
      'black': Colors.black,
      'white': Colors.white,
      'navy': Colors.indigo,
      'teal': Colors.teal,
      'cyan': Colors.cyan,
    };

    return colorMap[colorName.toLowerCase()] ?? Colors.grey;
  }
}
