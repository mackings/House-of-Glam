import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/reviewModel.dart';
import 'package:hog/components/Orders/PaymentOp.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:hog/utils/ui_label_formatter.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuotationCard extends StatelessWidget {
  final Review review;
  final VoidCallback onHireDesigner;
  final VoidCallback? onMakeOffer;
  final void Function(int amount) onCompletePayment;
  final VoidCallback? onRefresh;
  final bool hasSubmittedOffer;

  const QuotationCard({
    super.key,
    required this.review,
    required this.onHireDesigner,
    this.onMakeOffer,
    required this.onCompletePayment,
    this.onRefresh,
    this.hasSubmittedOffer = false,
  });

  @override
  Widget build(BuildContext context) {
    final isPartPayment = review.status == "part payment";
    final isFullPayment = review.status == "full payment";
    final hasAcceptedOffer = review.hasAcceptedOffer;
    final hasPartPayment = review.amountPaid > 0 && review.amountToPay > 0;
    final agreedTotal = review.userPayableTotal ?? review.totalCost;
    final displayTotal = hasAcceptedOffer ? agreedTotal : review.totalCost;
    final displayAmountToPay = review.amountToPay;
    final currencyCode = 'NGN';
    final displayTotalUSD = review.totalCostUSD;
    final showOriginalUSD = review.isInternationalVendor && displayTotalUSD > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.accentSoft,
                child: Text(
                  review.user.fullName.isNotEmpty
                      ? review.user.fullName[0].toUpperCase()
                      : "?",
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      review.user.fullName,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      "Delivery: ${DateFormat("dd MMM yyyy").format(review.deliveryDate)}",
                      fontSize: 12,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              _StatusTag(status: review.status),
            ],
          ),
          const SizedBox(height: 12),
          if (review.comment.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomText(
                review.comment,
                fontSize: 13,
                color: AppColors.subtext,
                textAlign: TextAlign.left,
                overflow: TextOverflow.visible,
              ),
            ),
          _buildTotalCost(
            displayTotal,
            currencyCode: currencyCode,
            includesVat: hasAcceptedOffer,
          ),
          if (showOriginalUSD) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFF1D4ED8),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "USD ${CurrencyHelper.formatAmount(displayTotalUSD, currencyCode: 'USD')} • Rate: ₦${review.exchangeRate.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPartPayment) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4DE),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF5D08A)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.warning,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Partial payment made",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Balance: ${CurrencyHelper.formatAmount(displayAmountToPay, currencyCode: currencyCode)}",
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 18),
          if (isFullPayment)
            _FilledAction(
              title: "Paid",
              icon: Icons.check_circle_rounded,
              onPressed: null,
              background: Colors.grey.shade400,
            )
          else if (hasPartPayment)
            _FilledAction(
              title:
                  "Pay Balance (${CurrencyHelper.formatAmount(displayAmountToPay, currencyCode: currencyCode)})",
              icon: Icons.payment_rounded,
              onPressed: () => onCompletePayment(displayAmountToPay.round()),
            )
          else if (hasAcceptedOffer)
            Column(
              children: [
                _FilledAction(
                  title:
                      "Pay in Full (${CurrencyHelper.formatAmount(displayTotal, currencyCode: currencyCode)})",
                  icon: Icons.payment_rounded,
                  onPressed: () => onCompletePayment(displayTotal.round()),
                ),
                const SizedBox(height: 10),
                _OutlineAction(
                  title: "Pay Half (Part Payment)",
                  icon: Icons.payments_outlined,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (BuildContext ctx) {
                        return PaymentOptionsModal(
                          review: review,
                          onCheckout: (String url) async {
                            Navigator.of(ctx).pop();
                            await Future.delayed(
                              const Duration(milliseconds: 250),
                            );
                            if (context.mounted) {
                              _openCheckout(context, url);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            )
          else
            Column(
              children: [
                _FilledAction(
                  title:
                      "Hire Designer (${CurrencyHelper.formatAmount(displayTotal, currencyCode: currencyCode)})",
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: onHireDesigner,
                ),
                const SizedBox(height: 10),
                _OutlineAction(
                  title: hasSubmittedOffer ? "Offer Submitted" : "Make Offer",
                  icon: Icons.local_offer_outlined,
                  onPressed: hasSubmittedOffer ? null : onMakeOffer,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTotalCost(
    double total, {
    required String currencyCode,
    required bool includesVat,
  }) {
    final vatLabel = includesVat ? "Including VAT" : "Excluding VAT";
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.attach_money_rounded,
            size: 16,
            color: AppColors.accent,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text:
                        "Total: ${CurrencyHelper.formatAmount(total, currencyCode: currencyCode)} ",
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  TextSpan(
                    text: vatLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.subtext,
                    ),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  void _openCheckout(BuildContext context, String url) {
    final controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => Scaffold(
              backgroundColor: AppColors.canvas,
              appBar: AppBar(
                title: const Text("Payments"),
                backgroundColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
              ),
              body: WebViewWidget(controller: controller),
            ),
      ),
    ).then((_) {
      controller.clearCache();
    });
  }
}

class _FilledAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? background;

  const _FilledAction({
    required this.title,
    required this.icon,
    required this.onPressed,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: Colors.white),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: background ?? AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}

class _OutlineAction extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onPressed;

  const _OutlineAction({
    required this.title,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 18,
          color: disabled ? Colors.grey.shade500 : AppColors.accent,
        ),
        label: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: disabled ? Colors.grey.shade500 : AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(
            color: disabled ? Colors.grey.shade300 : AppColors.border,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;

  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    Color foreground;
    Color background;

    switch (status.toLowerCase()) {
      case 'full payment':
        foreground = AppColors.success;
        background = const Color(0xFFEAF8F1);
        break;
      case 'part payment':
        foreground = AppColors.warning;
        background = const Color(0xFFFFF4DE);
        break;
      default:
        foreground = AppColors.accent;
        background = AppColors.accentSoft;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        formatUiLabel(status),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
