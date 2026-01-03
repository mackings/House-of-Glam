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
    final isInternational = item.isInternationalVendor || 
        (item.country != null && item.country!.toUpperCase() != 'NG');

    if (isInternational) {
      return {
        'totalCost': item.totalCostUSD ?? 0.0,
        'amountPaid': item.amountPaidUSD ?? 0.0,
        'amountToPay': item.amountToPayUSD ?? 0.0,
      };
    } else {
      return {
        'totalCost': item.totalCost,
        'amountPaid': item.amountPaid ?? 0.0,
        'amountToPay': item.amountToPay ?? 0.0,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final material = item.material;
    final displayAmounts = _getDisplayAmounts();
    final isFullyPaid = displayAmounts['amountToPay']! <= 0;

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
                    colors: [
                      const Color(0xFF6B21A8),
                      const Color(0xFF7C3AED),
                    ],
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
                            child: material.sampleImages.isNotEmpty
                                ? Image.network(
                                    material.sampleImages.first,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.white.withOpacity(0.1),
                                        child: Icon(
                                          Icons.checkroom_rounded,
                                          color: Colors.white.withOpacity(0.6),
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
                                      color: _getColorFromString(material.color),
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
      
                    // Payment Card - Black Premium Style
                    Container(
                      padding: const EdgeInsets.all(20),
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
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "TOTAL AMOUNT",
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(0.5),
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    CurrencyHelper.formatAmount(
                                      displayAmounts['totalCost']!,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6B21A8).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Color(0xFF7C3AED),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
      
                          const SizedBox(height: 20),
      
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
      
                          const SizedBox(height: 20),
      
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Icon(
                                            Icons.check_circle_rounded,
                                            size: 14,
                                            color: Color(0xFF10B981),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Paid",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      CurrencyHelper.formatAmount(
                                        displayAmounts['amountPaid']!,
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF10B981),
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: Colors.white.withOpacity(0.1),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          "Balance",
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            color: Colors.white.withOpacity(0.6),
                                            fontWeight: FontWeight.w500,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: (isFullyPaid 
                                                ? Colors.white.withOpacity(0.1)
                                                : const Color(0xFFF59E0B).withOpacity(0.15)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            isFullyPaid
                                                ? Icons.check_circle_rounded
                                                : Icons.schedule_rounded,
                                            size: 14,
                                            color: isFullyPaid
                                                ? Colors.white.withOpacity(0.6)
                                                : const Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      CurrencyHelper.formatAmount(
                                        displayAmounts['amountToPay']!,
                                      ),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: isFullyPaid
                                            ? Colors.white.withOpacity(0.6)
                                            : const Color(0xFFF59E0B),
                                        letterSpacing: -0.3,
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
    return status.split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
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