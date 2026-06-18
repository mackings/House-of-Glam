import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/AnalyticsService.dart';
import 'package:hog/App/Admin/Model/AnalyticsModel.dart';
import 'package:hog/App/Admin/Views/analytics_details.dart';
import 'package:hog/App/Admin/Widgets/analyticsCard.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  AdminAnalyticsData? _analytics;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    final response = await AnalyticsService.getAnalytics();
    if (!mounted) return;

    setState(() {
      _loading = false;
      if (response == null || !response.success) {
        _error =
            response?.message.isNotEmpty == true
                ? response!.message
                : 'Unable to load admin analytics.';
        return;
      }
      _analytics = response.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = _analytics;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const Text(
          "Analytics",
          style: TextStyle(
            fontSize: 18,
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body:
          _loading && analytics == null
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              )
              : _error != null && analytics == null
              ? _AnalyticsError(message: _error!, onRetry: fetchAnalytics)
              : RefreshIndicator(
                onRefresh: fetchAnalytics,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                  children: [
                    _AnalyticsHero(data: analytics!),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      _InlineError(message: _error!),
                    ],
                    const SizedBox(height: 16),
                    _SummaryGrid(data: analytics),
                  ],
                ),
              ),
    );
  }
}

class _AnalyticsHero extends StatelessWidget {
  final AdminAnalyticsData data;

  const _AnalyticsHero({required this.data});

  @override
  Widget build(BuildContext context) {
    final generatedAt = data.generatedAt?.toLocal();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8F3FF), Color(0xFFFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: CustomText(
                  "${data.listings.totalListings} listings",
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const CustomText(
            "Platform snapshot",
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          const CustomText(
            "Monitor account growth, marketplace inventory, wallet earnings, and transaction activity.",
            fontSize: 13,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
          if (generatedAt != null) ...[
            const SizedBox(height: 10),
            CustomText(
              "Updated ${DateFormat('d MMM yyyy, h:mm a').format(generatedAt)}",
              fontSize: 11,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  final AdminAnalyticsData data;

  const _SummaryGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        title: "Total Users",
        value: "${data.users.totalUsers}",
        icon: Icons.people_alt_outlined,
        tint: const Color(0xFF2563EB),
        onTap: () => _open(context, AdminUsersAnalyticsPage(data: data.users)),
      ),
      (
        title: "Total Listings",
        value: "${data.listings.totalListings}",
        icon: Icons.storefront_outlined,
        tint: const Color(0xFFEC4899),
        onTap:
            () => _open(
              context,
              AdminListingsAnalyticsPage(summary: data.listings),
            ),
      ),
      (
        title: "Total Earnings",
        value: CurrencyHelper.formatAmount(
          data.earnings.totalEarnings,
          currencyCode: data.earnings.currency,
        ),
        icon: Icons.account_balance_wallet_outlined,
        tint: const Color(0xFFF59E0B),
        onTap:
            () =>
                _open(context, AdminEarningsAnalyticsPage(data: data.earnings)),
      ),
      (
        title: "Transactions",
        value: "${data.transactions.totalTransactions}",
        icon: Icons.swap_horiz_rounded,
        tint: const Color(0xFF0EA5E9),
        onTap:
            () => _open(
              context,
              AdminTransactionsAnalyticsPage(
                data: data.transactions,
                successfulOnly: false,
              ),
            ),
      ),
      (
        title: "Successful",
        value: "${data.transactions.successfulTransactions}",
        icon: Icons.check_circle_outline_rounded,
        tint: AppColors.success,
        onTap:
            () => _open(
              context,
              AdminTransactionsAnalyticsPage(
                data: data.transactions,
                successfulOnly: true,
              ),
            ),
      ),
      (
        title: "New Users (30d)",
        value: "${data.users.registeredLast30Days}",
        icon: Icons.person_add_alt_rounded,
        tint: AppColors.accent,
        onTap: () => _open(context, AdminUsersAnalyticsPage(data: data.users)),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 720 ? 3 : 2;
        final spacing = 12.0;
        final width =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children:
              cards
                  .map(
                    (card) => SizedBox(
                      width: width,
                      child: AnalyticsCard(
                        title: card.title,
                        value: card.value,
                        icon: card.icon,
                        tint: card.tint,
                        onTap: card.onTap,
                      ),
                    ),
                  )
                  .toList(),
        );
      },
    );
  }
}

void _open(BuildContext context, Widget page) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
}

class _AnalyticsError extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _AnalyticsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.analytics_outlined,
              size: 46,
              color: AppColors.subtext,
            ),
            const SizedBox(height: 12),
            CustomText(message, color: AppColors.subtext),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: CustomText(
        message,
        fontSize: 11,
        color: AppColors.danger,
        textAlign: TextAlign.left,
      ),
    );
  }
}
