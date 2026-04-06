import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/adminService.dart';
import 'package:hog/App/Admin/Model/PendingListing.dart';
import 'package:hog/App/Admin/Widgets/PendingCard.dart';
import 'package:hog/App/Admin/Widgets/moderationListingDetailSheet.dart';
import 'package:hog/App/Admin/Widgets/rejectionSheet.dart';

class ModerationListingsTab extends StatefulWidget {
  final String status;
  final bool isSuperAdmin;

  const ModerationListingsTab({
    super.key,
    required this.status,
    required this.isSuperAdmin,
  });

  @override
  State<ModerationListingsTab> createState() => _ModerationListingsTabState();
}

class _ModerationListingsTabState extends State<ModerationListingsTab> {
  late Future<SellerModerationListResponse> _future;
  bool _mineOnly = false;
  String? _busyListingId;

  bool get _showMineToggle =>
      widget.isSuperAdmin && widget.status.toLowerCase() != 'pending';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<SellerModerationListResponse> _load() {
    switch (widget.status.toLowerCase()) {
      case 'approved':
        return AdminService.getApprovedListings(mine: _mineOnly);
      case 'rejected':
        return AdminService.getRejectedListings(mine: _mineOnly);
      default:
        return AdminService.getAllPendingListings();
    }
  }

  Future<void> _refresh() async {
    final future = _load();
    setState(() => _future = future);
    await future;
  }

  Future<void> _approve(String listingId) async {
    setState(() => _busyListingId = listingId);
    try {
      await AdminService.approveListing(listingId);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing approved')));
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _busyListingId = null);
      }
    }
  }

  Future<void> _reject(String listingId) async {
    final reasons = await showRejectReasonSheet(context);
    if (reasons == null || reasons.isEmpty) {
      return;
    }

    setState(() => _busyListingId = listingId);
    try {
      await AdminService.rejectListing(listingId, reasons);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listing rejected')));
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) {
        setState(() => _busyListingId = null);
      }
    }
  }

  Future<void> _openDetails(String listingId) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return ModerationListingDetailSheet(
          listingId: listingId,
          allowModerationActions: widget.status.toLowerCase() == 'pending',
        );
      },
    );

    if (updated == true && mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showMineToggle)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: !_mineOnly,
                  onSelected: (_) {
                    setState(() {
                      _mineOnly = false;
                      _future = _load();
                    });
                  },
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('Mine'),
                  selected: _mineOnly,
                  onSelected: (_) {
                    setState(() {
                      _mineOnly = true;
                      _future = _load();
                    });
                  },
                ),
              ],
            ),
          ),
        Expanded(
          child: FutureBuilder<SellerModerationListResponse>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return _AdminTabState(
                  icon: Icons.error_outline,
                  title: 'Unable to load listings',
                  message: snapshot.error
                      .toString()
                      .replaceFirst('Exception: ', ''),
                  actionLabel: 'Retry',
                  onAction: _refresh,
                );
              }

              final response = snapshot.data;
              final listings = response?.data ?? const <SellerModerationListing>[];
              if (listings.isEmpty) {
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.18),
                      _AdminTabState(
                        icon: Icons.inventory_2_outlined,
                        title: 'No ${widget.status} listings',
                        message: 'Pull down to refresh this queue.',
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 18),
                  itemCount: listings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final pagination = response!.pagination;
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 2),
                        child: Text(
                          'Showing ${listings.length} of ${pagination.total} listings',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }

                    final listing = listings[index - 1];
                    return ModerationListingCard(
                      listing: listing,
                      onTap: () => _openDetails(listing.id),
                      onApprove:
                          widget.status.toLowerCase() == 'pending'
                              ? () => _approve(listing.id)
                              : null,
                      onReject:
                          widget.status.toLowerCase() == 'pending'
                              ? () => _reject(listing.id)
                              : null,
                      isBusy: _busyListingId == listing.id,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AdminTabState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  const _AdminTabState({
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
