import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/AnalyticsService.dart';
import 'package:hog/App/Admin/Model/AnalyticsModel.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/constants/currencyHelper.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AdminUsersAnalyticsPage extends StatefulWidget {
  final UserAnalytics data;
  final AnalyticsUsersPage? initialResult;

  const AdminUsersAnalyticsPage({
    super.key,
    required this.data,
    this.initialResult,
  });

  @override
  State<AdminUsersAnalyticsPage> createState() =>
      _AdminUsersAnalyticsPageState();
}

class _AdminUsersAnalyticsPageState extends State<AdminUsersAnalyticsPage> {
  final _search = TextEditingController();
  AnalyticsUsersPage? _result;
  bool _loading = true;
  String? _error;
  int _page = 1;
  String? _role;
  String? _status;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _loading = widget.initialResult == null;
    if (widget.initialResult == null) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    final result = await AnalyticsService.getAnalyticsUsers(
      page: _page,
      search: _search.text.trim(),
      role: _role,
      accountStatus: _status,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      if (result == null) _error = 'Unable to load user records.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _result?.summary ?? widget.data;
    return _RecordsScaffold(
      title: 'Users',
      header: _HeroMetric(
        label: 'Total users',
        value: '${summary.totalUsers}',
        subtitle: '${summary.registeredLast30Days} joined in the last 30 days',
        icon: Icons.people_alt_outlined,
      ),
      controls: Column(
        children: [
          _SearchField(
            controller: _search,
            hint: 'Search name, email, username or phone',
            onSearch: () => _load(page: 1),
          ),
          const SizedBox(height: 10),
          _ResponsiveFilterRow(
            children: [
              _FilterDropdown(
                label: 'Role',
                value: _role,
                values: const ['user', 'tailor', 'admin', 'superAdmin'],
                onChanged: (value) {
                  _role = value;
                  _load(page: 1);
                },
              ),
              _FilterDropdown(
                label: 'Status',
                value: _status,
                values: const ['active', 'blocked'],
                onChanged: (value) {
                  _status = value;
                  _load(page: 1);
                },
              ),
            ],
          ),
        ],
      ),
      loading: _loading,
      error: _error,
      onRetry: _load,
      records:
          (_result?.records ?? const [])
              .map((record) => _UserRecordCard(record: record))
              .toList(),
      pagination: _result?.pagination,
      onPage: (page) => _load(page: page),
    );
  }
}

class AdminListingsAnalyticsPage extends StatefulWidget {
  final ListingAnalytics summary;
  final AnalyticsListingsPage? initialResult;

  const AdminListingsAnalyticsPage({
    super.key,
    required this.summary,
    this.initialResult,
  });

  @override
  State<AdminListingsAnalyticsPage> createState() =>
      _AdminListingsAnalyticsPageState();
}

class _AdminListingsAnalyticsPageState
    extends State<AdminListingsAnalyticsPage> {
  final _search = TextEditingController();
  AnalyticsListingsPage? _result;
  bool _loading = true;
  String? _error;
  int _page = 1;
  String? _pricing;
  String? _approvalStatus;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _loading = widget.initialResult == null;
    if (widget.initialResult == null) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    final result = await AnalyticsService.getAnalyticsListings(
      page: _page,
      search: _search.text.trim(),
      pricing: _pricing,
      approvalStatus: _approvalStatus,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      if (result == null) _error = 'Unable to load listing records.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _result?.summary ?? widget.summary;
    return _RecordsScaffold(
      title: 'Listings',
      header: _HeroMetric(
        label: 'Total listings',
        value: '${summary.totalListings}',
        subtitle:
            '${summary.paidListings} paid • ${summary.freeListings} free • ${summary.unpricedListings} unpriced',
        icon: Icons.storefront_outlined,
      ),
      controls: Column(
        children: [
          _SearchField(
            controller: _search,
            hint: 'Search title, description, fabric or occasion',
            onSearch: () => _load(page: 1),
          ),
          const SizedBox(height: 10),
          _ResponsiveFilterRow(
            children: [
              _FilterDropdown(
                label: 'Pricing',
                value: _pricing,
                values: const ['free', 'paid', 'unpriced'],
                onChanged: (value) {
                  _pricing = value;
                  _load(page: 1);
                },
              ),
              _FilterDropdown(
                label: 'Approval',
                value: _approvalStatus,
                values: const ['pending', 'approved', 'rejected'],
                onChanged: (value) {
                  _approvalStatus = value;
                  _load(page: 1);
                },
              ),
            ],
          ),
        ],
      ),
      loading: _loading,
      error: _error,
      onRetry: _load,
      records:
          (_result?.records ?? const [])
              .map((record) => _ListingRecordCard(record: record))
              .toList(),
      pagination: _result?.pagination,
      onPage: (page) => _load(page: page),
    );
  }
}

class AdminTransactionsAnalyticsPage extends StatefulWidget {
  final TransactionAnalytics data;
  final bool successfulOnly;
  final AnalyticsTransactionsPage? initialResult;

  const AdminTransactionsAnalyticsPage({
    super.key,
    required this.data,
    this.successfulOnly = false,
    this.initialResult,
  });

  @override
  State<AdminTransactionsAnalyticsPage> createState() =>
      _AdminTransactionsAnalyticsPageState();
}

class _AdminTransactionsAnalyticsPageState
    extends State<AdminTransactionsAnalyticsPage> {
  final _search = TextEditingController();
  AnalyticsTransactionsPage? _result;
  bool _loading = true;
  String? _error;
  int _page = 1;
  String? _method;
  String? _currency;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _loading = widget.initialResult == null;
    if (widget.initialResult == null) _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    final result = await AnalyticsService.getAnalyticsTransactions(
      page: _page,
      successfulOnly: widget.successfulOnly,
      search: _search.text.trim(),
      paymentMethod: _method,
      currency: _currency,
    );
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      if (result == null) _error = 'Unable to load transaction records.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _result?.summary ?? widget.data;
    final total =
        widget.successfulOnly
            ? summary.successfulTransactions
            : summary.totalTransactions;
    return _RecordsScaffold(
      title: widget.successfulOnly ? 'Successful Transactions' : 'Transactions',
      header: _HeroMetric(
        label:
            widget.successfulOnly ? 'Successful transactions' : 'Transactions',
        value: '$total',
        subtitle:
            widget.successfulOnly
                ? 'Completed and successful payment activity'
                : '${summary.successfulTransactions} successful transactions',
        icon:
            widget.successfulOnly
                ? Icons.check_circle_outline_rounded
                : Icons.swap_horiz_rounded,
      ),
      controls: Column(
        children: [
          _SearchField(
            controller: _search,
            hint: 'Search reference, title, reason or session',
            onSearch: () => _load(page: 1),
          ),
          const SizedBox(height: 10),
          _ResponsiveFilterRow(
            children: [
              _FilterDropdown(
                label: 'Method',
                value: _method,
                values: summary.byPaymentMethod.keys.toList(),
                onChanged: (value) {
                  _method = value;
                  _load(page: 1);
                },
              ),
              _FilterDropdown(
                label: 'Currency',
                value: _currency,
                values: summary.amountsByCurrency.keys.toList(),
                onChanged: (value) {
                  _currency = value;
                  _load(page: 1);
                },
              ),
            ],
          ),
        ],
      ),
      loading: _loading,
      error: _error,
      onRetry: _load,
      records:
          (_result?.records ?? const [])
              .map((record) => _TransactionRecordCard(record: record))
              .toList(),
      pagination: _result?.pagination,
      onPage: (page) => _load(page: page),
    );
  }
}

class AdminEarningsAnalyticsPage extends StatefulWidget {
  final EarningsAnalytics data;
  final AnalyticsEarningsPage? initialResult;

  const AdminEarningsAnalyticsPage({
    super.key,
    required this.data,
    this.initialResult,
  });

  @override
  State<AdminEarningsAnalyticsPage> createState() =>
      _AdminEarningsAnalyticsPageState();
}

class _AdminEarningsAnalyticsPageState
    extends State<AdminEarningsAnalyticsPage> {
  AnalyticsEarningsPage? _result;
  bool _loading = true;
  String? _error;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _result = widget.initialResult;
    _loading = widget.initialResult == null;
    if (widget.initialResult == null) _load();
  }

  Future<void> _load({int? page}) async {
    setState(() {
      _loading = true;
      _error = null;
      if (page != null) _page = page;
    });
    final result = await AnalyticsService.getAnalyticsEarnings(page: _page);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _result = result;
      if (result == null) _error = 'Unable to load earnings details.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final earnings = _result?.earnings ?? widget.data;
    return _RecordsScaffold(
      title: 'Earnings',
      header: Column(
        children: [
          _HeroMetric(
            label: 'Admin wallet balance',
            value: CurrencyHelper.formatAmount(
              earnings.totalEarnings,
              currencyCode: earnings.currency,
            ),
            subtitle: _label(earnings.basis),
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: 12),
          _AmountBreakdown(data: earnings),
          if ((_result?.note ?? earnings.note).isNotEmpty) ...[
            const SizedBox(height: 12),
            _InformationPanel(text: _result?.note ?? earnings.note),
          ],
        ],
      ),
      loading: _loading,
      error: _error,
      onRetry: _load,
      records:
          (_result?.transactionActivity ?? const [])
              .map((record) => _TransactionRecordCard(record: record))
              .toList(),
      pagination: _result?.pagination,
      onPage: (page) => _load(page: page),
      recordsTitle: 'Successful transaction activity',
    );
  }
}

class _RecordsScaffold extends StatelessWidget {
  final String title;
  final Widget header;
  final Widget? controls;
  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;
  final List<Widget> records;
  final AnalyticsPagination? pagination;
  final ValueChanged<int> onPage;
  final String recordsTitle;

  const _RecordsScaffold({
    required this.title,
    required this.header,
    this.controls,
    this.loading = false,
    this.error,
    required this.onRetry,
    this.records = const [],
    this.pagination,
    required this.onPage,
    this.recordsTitle = 'Records',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text(title)),
      body: RefreshIndicator(
        onRefresh: onRetry,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            header,
            if (controls != null) ...[const SizedBox(height: 14), controls!],
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (error != null)
              _PageState(message: error!, onRetry: onRetry)
            else ...[
              Row(
                children: [
                  Expanded(
                    child: CustomText(
                      recordsTitle,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      textAlign: TextAlign.left,
                    ),
                  ),
                  if (pagination != null)
                    CustomText(
                      '${pagination!.totalRecords} total',
                      fontSize: 11,
                      color: AppColors.subtext,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (records.isEmpty)
                const _InformationPanel(text: 'No records match this view.')
              else
                ...records,
              if (pagination != null && pagination!.totalPages > 1) ...[
                const SizedBox(height: 14),
                _PaginationControls(pagination: pagination!, onPage: onPage),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _UserRecordCard extends StatelessWidget {
  final AnalyticsUserRecord record;

  const _UserRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return _RecordCard(
      leading:
          record.image.isEmpty
              ? CircleAvatar(
                backgroundColor: AppColors.accentSoft,
                child: Text(
                  record.fullName.isEmpty
                      ? '?'
                      : record.fullName[0].toUpperCase(),
                ),
              )
              : CircleAvatar(backgroundImage: NetworkImage(record.image)),
      title: record.fullName.isEmpty ? record.email : record.fullName,
      subtitle: record.email,
      badges: [
        _Badge(label: _label(record.role), tone: AppColors.accent),
        _Badge(
          label: record.isBlocked ? 'Blocked' : 'Active',
          tone: record.isBlocked ? AppColors.danger : AppColors.success,
        ),
        _Badge(
          label: record.isVerified ? 'Verified' : 'Unverified',
          tone: record.isVerified ? AppColors.success : AppColors.warning,
        ),
      ],
      details: [
        if (record.username.isNotEmpty) '@${record.username}',
        if (record.phoneNumber.isNotEmpty) record.phoneNumber,
        if (record.subscriptionPlan.isNotEmpty)
          '${_label(record.subscriptionPlan)} plan',
        if (record.country.isNotEmpty) record.country,
        CurrencyHelper.formatAmount(record.wallet, currencyCode: 'NGN'),
        if (record.subscriptionEndDate != null)
          'Plan ends ${DateFormat('d MMM yyyy').format(record.subscriptionEndDate!)}',
        if (record.createdAt != null)
          'Joined ${DateFormat('d MMM yyyy').format(record.createdAt!)}',
      ],
    );
  }
}

class _ListingRecordCard extends StatelessWidget {
  final Map<String, dynamic> record;

  const _ListingRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final images =
        record['images'] is List ? record['images'] as List : const [];
    final user =
        record['userId'] is Map
            ? Map<String, dynamic>.from(record['userId'] as Map)
            : const <String, dynamic>{};
    final currency = record['currency']?.toString() ?? 'NGN';
    final price = _number(record['price']);
    final image = images.isEmpty ? '' : images.first?.toString() ?? '';
    final category =
        record['categoryId'] is Map
            ? Map<String, dynamic>.from(record['categoryId'] as Map)
            : const <String, dynamic>{};
    return _RecordCard(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
            image.isEmpty
                ? Container(
                  width: 52,
                  height: 52,
                  color: AppColors.surfaceMuted,
                  child: const Icon(Icons.image_outlined),
                )
                : Image.network(
                  image,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                ),
      ),
      title: record['title']?.toString() ?? 'Untitled listing',
      subtitle:
          user['fullName']?.toString() ??
          user['email']?.toString() ??
          'Unknown seller',
      badges: [
        _Badge(
          label: _label(record['approvalStatus']?.toString() ?? 'pending'),
          tone: _statusTone(record['approvalStatus']?.toString()),
        ),
        _Badge(
          label: _label(record['availability']?.toString() ?? 'unknown'),
          tone: AppColors.subtext,
        ),
      ],
      details: [
        CurrencyHelper.formatAmount(price, currencyCode: currency),
        if ((category['name']?.toString() ?? '').isNotEmpty)
          category['name'].toString(),
        if (record['viewsCount'] != null) '${record['viewsCount']} views',
        if (record['savedCount'] != null) '${record['savedCount']} saves',
      ],
    );
  }
}

class _TransactionRecordCard extends StatelessWidget {
  final AnalyticsTransactionRecord record;

  const _TransactionRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final title =
        record.listingTitles.isNotEmpty
            ? record.listingTitles.join(', ')
            : record.materialTitle.isNotEmpty
            ? record.materialTitle
            : record.paymentReference.isNotEmpty
            ? record.paymentReference
            : 'Transaction';
    return _RecordCard(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.accentSoft,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.receipt_long_outlined, color: AppColors.accent),
      ),
      title: title,
      subtitle:
          record.userName.isNotEmpty
              ? record.userName
              : record.userEmail.isNotEmpty
              ? record.userEmail
              : record.vendorName,
      badges: [
        _Badge(
          label: _label(
            record.paymentStatus.isEmpty
                ? record.transactionStatus
                : record.paymentStatus,
          ),
          tone: _statusTone(
            record.paymentStatus.isEmpty
                ? record.transactionStatus
                : record.paymentStatus,
          ),
        ),
        if (record.paymentMethod.isNotEmpty)
          _Badge(label: record.paymentMethod, tone: AppColors.accent),
      ],
      details: [
        CurrencyHelper.formatAmount(
          record.analyticsAmount > 0
              ? record.analyticsAmount
              : record.totalAmount,
          currencyCode: record.currency,
        ),
        if (record.paymentReference.isNotEmpty) record.paymentReference,
        if (record.vendorName.isNotEmpty) record.vendorName,
        if (record.orderStatus.isNotEmpty) _label(record.orderStatus),
        if (record.createdAt != null)
          DateFormat('d MMM yyyy, h:mm a').format(record.createdAt!.toLocal()),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final List<Widget> badges;
  final List<String> details;

  const _RecordCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.badges,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  CustomText(
                    subtitle,
                    fontSize: 11,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ],
                if (badges.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: badges),
                ],
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 5,
                    children:
                        details
                            .map(
                              (detail) => CustomText(
                                detail,
                                fontSize: 10,
                                color: AppColors.subtext,
                                textAlign: TextAlign.left,
                              ),
                            )
                            .toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final VoidCallback onSearch;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: IconButton(
          onPressed: onSearch,
          icon: const Icon(Icons.arrow_forward_rounded),
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      menuMaxHeight: 320,
      decoration: InputDecoration(labelText: label),
      items: [
        const DropdownMenuItem(value: null, child: Text('All')),
        ...values.toSet().map(
          (item) => DropdownMenuItem(
            value: item,
            child: Text(
              _label(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      selectedItemBuilder:
          (context) => [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('All', maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            ...values.toSet().map(
              (item) => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _label(item),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
      onChanged: onChanged,
    );
  }
}

class _ResponsiveFilterRow extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveFilterRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                SizedBox(width: double.infinity, child: children[index]),
                if (index < children.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _PaginationControls extends StatelessWidget {
  final AnalyticsPagination pagination;
  final ValueChanged<int> onPage;

  const _PaginationControls({required this.pagination, required this.onPage});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:
                pagination.hasPreviousPage
                    ? () => onPage(pagination.page - 1)
                    : null,
            icon: const Icon(Icons.chevron_left_rounded),
            label: const Text('Previous'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('${pagination.page} / ${pagination.totalPages}'),
        ),
        Expanded(
          child: FilledButton.icon(
            onPressed:
                pagination.hasNextPage
                    ? () => onPage(pagination.page + 1)
                    : null,
            icon: const Icon(Icons.chevron_right_rounded),
            label: const Text('Next'),
          ),
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;

  const _HeroMetric({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF4FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  fontSize: 12,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 3),
                CustomText(
                  value,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 4),
                CustomText(
                  subtitle,
                  fontSize: 11,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountBreakdown extends StatelessWidget {
  final EarningsAnalytics data;

  const _AmountBreakdown({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _AmountRow(
            label: 'Recorded commission',
            value: data.recordedCommission,
            currency: data.currency,
          ),
          _AmountRow(
            label: 'Recorded tax',
            value: data.recordedTax,
            currency: data.currency,
          ),
          _AmountRow(
            label: 'Other wallet credits',
            value: data.otherWalletCredits,
            currency: data.currency,
          ),
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double value;
  final String currency;

  const _AmountRow({
    required this.label,
    required this.value,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            CurrencyHelper.formatAmount(value, currencyCode: currency),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color tone;

  const _Badge({required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: tone, fontSize: 9, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InformationPanel extends StatelessWidget {
  final String text;

  const _InformationPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accentSoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: CustomText(
        text,
        fontSize: 12,
        color: AppColors.subtext,
        textAlign: TextAlign.left,
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _PageState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomText(message, color: AppColors.subtext),
        const SizedBox(height: 10),
        FilledButton(onPressed: onRetry, child: const Text('Try again')),
      ],
    );
  }
}

Color _statusTone(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'success':
    case 'successful':
    case 'approved':
    case 'completed':
    case 'active':
      return AppColors.success;
    case 'rejected':
    case 'failed':
    case 'blocked':
      return AppColors.danger;
    case 'pending':
    case 'part payment':
      return AppColors.warning;
    default:
      return AppColors.subtext;
  }
}

String _label(String value) {
  switch (value.trim().toLowerCase()) {
    case 'user':
      return 'Standard Account';
    case 'tailor':
      return 'Designer';
    case 'superadmin':
      return 'Super Admin';
  }
  final spaced =
      value
          .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'),
            (match) => '${match.group(1)} ${match.group(2)}',
          )
          .replaceAll('_', ' ')
          .trim();
  if (spaced.isEmpty) return 'Unknown';
  return '${spaced[0].toUpperCase()}${spaced.substring(1)}';
}

double _number(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
