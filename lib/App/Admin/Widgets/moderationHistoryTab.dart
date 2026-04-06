import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/adminService.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/App/Admin/Widgets/moderationHistoryCard.dart';

class ModerationHistoryTab extends StatefulWidget {
  final bool isSuperAdmin;
  final String? userId;

  const ModerationHistoryTab({
    super.key,
    required this.isSuperAdmin,
    required this.userId,
  });

  @override
  State<ModerationHistoryTab> createState() => _ModerationHistoryTabState();
}

class _ModerationHistoryTabState extends State<ModerationHistoryTab> {
  late Future<ListingModerationHistoryResponse> _future;
  String? _action;
  bool _mineOnly = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<ListingModerationHistoryResponse> _load() {
    return AdminService.getModerationHistory(
      action: _action,
      moderatorId: widget.isSuperAdmin && _mineOnly ? widget.userId : null,
    );
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All actions'),
                  selected: _action == null,
                  onSelected: (_) {
                    setState(() {
                      _action = null;
                      _future = _load();
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Approved'),
                  selected: _action == 'approved',
                  onSelected: (_) {
                    setState(() {
                      _action = 'approved';
                      _future = _load();
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Rejected'),
                  selected: _action == 'rejected',
                  onSelected: (_) {
                    setState(() {
                      _action = 'rejected';
                      _future = _load();
                    });
                  },
                ),
                if (widget.isSuperAdmin && widget.userId != null) ...[
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: const Text('My activity'),
                    selected: _mineOnly,
                    onSelected: (_) {
                      setState(() {
                        _mineOnly = !_mineOnly;
                        _future = _load();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder<ListingModerationHistoryResponse>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _HistoryEmptyState(
                  icon: Icons.error_outline,
                  title: 'Unable to load moderation history',
                  message: snapshot.error
                      .toString()
                      .replaceFirst('Exception: ', ''),
                  actionLabel: 'Retry',
                  onAction: _refresh,
                );
              }

              final response = snapshot.data;
              final items = response?.data ?? const <ListingModerationFeedItem>[];
              final summary = response?.summary ??
                  const ListingModerationSummary(
                    pending: 0,
                    approved: 0,
                    rejected: 0,
                  );

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 18),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              label: 'Pending',
                              value: summary.pending,
                              color: const Color(0xFFB26A00),
                              background: const Color(0xFFFFF4DE),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Approved',
                              value: summary.approved,
                              color: const Color(0xFF1B8E4B),
                              background: const Color(0xFFE8F8EE),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SummaryCard(
                              label: 'Rejected',
                              value: summary.rejected,
                              color: const Color(0xFFC62828),
                              background: const Color(0xFFFDECEC),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (items.isEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.14,
                        ),
                        child: const _HistoryEmptyState(
                          icon: Icons.history_toggle_off,
                          title: 'No moderation activity',
                          message: 'Pull down to refresh this feed.',
                        ),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                        child: Text(
                          'Recent activity',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      ...items.map((item) => ModerationHistoryCard(item: item)),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final Color background;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _HistoryEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: Colors.grey.shade500),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            TextButton(
              onPressed: () async => onAction!.call(),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
