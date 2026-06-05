import 'package:flutter/material.dart';
import 'package:hog/App/NewestFeatures/Api/order_context_service.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class OrderContextSelector extends StatelessWidget {
  final List<OrderContext> contexts;
  final OrderContext? selected;
  final ValueChanged<OrderContext> onSelected;
  final String emptyText;

  const OrderContextSelector({
    super.key,
    required this.contexts,
    required this.selected,
    required this.onSelected,
    this.emptyText = 'No eligible orders yet.',
  });

  @override
  Widget build(BuildContext context) {
    if (contexts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: CustomText(
          emptyText,
          color: AppColors.subtext,
          textAlign: TextAlign.left,
        ),
      );
    }

    return Column(
      children:
          contexts.map((item) {
            final isSelected =
                selected?.material.id == item.material.id &&
                selected?.review.id == item.review.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onSelected(item),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accentSoft : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.receipt_long_outlined,
                          color:
                              isSelected ? AppColors.accent : AppColors.subtext,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              item.title,
                              fontWeight: FontWeight.w800,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 4),
                            CustomText(
                              item.subtitle,
                              fontSize: 12,
                              color: AppColors.subtext,
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
