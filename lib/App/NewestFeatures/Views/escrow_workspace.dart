import 'package:flutter/material.dart';
import 'package:hog/App/NewestFeatures/Api/order_context_service.dart';
import 'package:hog/App/NewestFeatures/Views/order_context_widgets.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class EscrowWorkspace extends StatefulWidget {
  const EscrowWorkspace({super.key});

  @override
  State<EscrowWorkspace> createState() => _EscrowWorkspaceState();
}

class _EscrowWorkspaceState extends State<EscrowWorkspace> {
  late Future<List<OrderContext>> _protectedOrdersFuture;
  OrderContext? _selectedOrder;

  @override
  void initState() {
    super.initState();
    _protectedOrdersFuture = OrderContextService.getQuotationContexts(
      paidOnly: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderContext>>(
      future: _protectedOrdersFuture,
      builder: (context, snapshot) {
        final orders = snapshot.data ?? const <OrderContext>[];
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            _Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomText(
                    'Payment protection',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8),
                  const CustomText(
                    'Your eligible paid orders appear here automatically. Payments stay protected until delivery is confirmed or a support review is completed.',
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 14),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    OrderContextSelector(
                      contexts: orders,
                      selected: _selectedOrder,
                      emptyText:
                          'No protected payments yet. Orders appear here after payment checkout succeeds.',
                      onSelected:
                          (order) => setState(() => _selectedOrder = order),
                    ),
                ],
              ),
            ),
            if (_selectedOrder != null) ...[
              const SizedBox(height: 14),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                      'Designer wallet status',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      'Funds paid for ${_selectedOrder!.title} should show to the designer as held balance. They should only move to bank payout after delivery confirmation or admin release.',
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    _TimelineRow(label: 'Payment held', active: true),
                    _TimelineRow(
                      label: 'Delivery confirmed',
                      active: _selectedOrder!.material.isDelivered,
                    ),
                    _TimelineRow(
                      label: 'Release to designer bank',
                      active:
                          _selectedOrder!.material.isDelivered &&
                          _selectedOrder!.review.status == 'full payment',
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class EscrowSummaryCard extends StatelessWidget {
  final Map<String, dynamic> escrow;

  const EscrowSummaryCard({super.key, required this.escrow});

  @override
  Widget build(BuildContext context) {
    if (escrow.isEmpty) return const SizedBox.shrink();
    final rows = [
      ('Total', escrow['totalAmount']),
      ('Deposit', escrow['depositAmount']),
      ('Balance', escrow['balanceAmount']),
      ('Status', escrow['status']),
    ];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Payment protection',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row.$1,
                      style: const TextStyle(color: AppColors.subtext),
                    ),
                  ),
                  Text(
                    '${row.$2 ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WorkflowTimelineCard extends StatelessWidget {
  final Map<String, dynamic> workflow;

  const WorkflowTimelineCard({super.key, required this.workflow});

  @override
  Widget build(BuildContext context) {
    final rawTimeline = workflow['timeline'];
    final timeline =
        rawTimeline is List
            ? rawTimeline
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : const <Map<String, dynamic>>[];
    final current = workflow['currentStatus']?.toString();
    final statuses =
        timeline.isNotEmpty
            ? timeline
                .map((item) => item['status']?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
            : const [
              'quote_received',
              'accepted',
              'in_production',
              'ready',
              'shipped',
              'delivered',
            ];

    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Production timeline',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          ...statuses.map(
            (status) => _TimelineRow(
              label: status,
              active:
                  status == current ||
                  timeline.any((item) => item['status'] == status),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String label;
  final bool active;

  const _TimelineRow({required this.label, required this.active});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            active
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: active ? AppColors.success : AppColors.subtext,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label.replaceAll('_', ' '),
              style: TextStyle(
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                color: active ? AppColors.ink : AppColors.subtext,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;

  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
