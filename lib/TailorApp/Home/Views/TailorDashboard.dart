import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/UserProfile/Views/UserProfile.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/materialModel.dart';
import 'package:hog/TailorApp/Widgets/DetailsTaiioesheet.dart';
import 'package:hog/TailorApp/Widgets/MaterialCard.dart';
import 'package:hog/TailorApp/Widgets/tailorAppBar.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/error_display.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Tailordashboard extends StatefulWidget {
  const Tailordashboard({super.key});

  @override
  State<Tailordashboard> createState() => _TailordashboardState();
}

class _TailordashboardState extends State<Tailordashboard> {
  late Future<TailorMaterialResponse> _materialsFuture;
  _AttireFilter _filter = _AttireFilter.all;

  @override
  void initState() {
    super.initState();
    _materialsFuture = _fetchMaterials();
  }

  Future<TailorMaterialResponse> _fetchMaterials() async {
    final token = await SecurePrefs.getToken();
    return TailorHomeService().fetchTailorMaterials(token ?? "");
  }

  Future<void> _refreshMaterials() async {
    setState(() {
      _materialsFuture = _fetchMaterials();
    });
    await _materialsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: TailorAppBar(
        title: "Project Hub",
        onRefresh: _refreshMaterials,
        onProfileClick: () {
          Nav.push(context, UserProfileView());
        },
      ),
      body: SafeArea(
        child: FutureBuilder<TailorMaterialResponse>(
          future: _materialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return ErrorDisplay(
                error: snapshot.error,
                onRetry: _refreshMaterials,
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refreshMaterials,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: const [
                    _TailorHeroCard(
                      title: "No active attire requests",
                      subtitle:
                          "Fresh customer materials will appear here as soon as they are assigned to you.",
                      icon: Icons.inbox_outlined,
                    ),
                  ],
                ),
              );
            }

            final materials = [...snapshot.data!.data]..sort(
              (a, b) =>
                  _parseDate(b.createdAt).compareTo(_parseDate(a.createdAt)),
            );
            final filteredMaterials =
                materials.where((item) {
                  switch (_filter) {
                    case _AttireFilter.pending:
                      return !item.isDelivered;
                    case _AttireFilter.delivered:
                      return item.isDelivered;
                    case _AttireFilter.all:
                      return true;
                  }
                }).toList();
            final deliveredCount =
                materials.where((item) => item.isDelivered).length;
            final pendingCount = materials.length - deliveredCount;

            return RefreshIndicator(
              onRefresh: _refreshMaterials,
              color: AppColors.accent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      _TailorHeroCard(
                        title: "New Projects",
                        subtitle:
                            "Access client materials, measurements, and delivery progress in one streamlined view.",
                        icon: Icons.design_services_outlined,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _MetricPill(
                              label: "Active Projects",
                              value: "${materials.length}",
                            ),
                            const SizedBox(width: 8),
                            _MetricPill(
                              label: "Awaiting Action",
                              value: "$pendingCount",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SummaryStrip(
                        items: [
                          _SummaryItem(
                            label: "Completed",
                            value: "$deliveredCount",
                            icon: Icons.verified_rounded,
                            color: AppColors.success,
                          ),
                          _SummaryItem(
                            label: "In Progress",
                            value: "$pendingCount",
                            icon: Icons.timelapse_rounded,
                            color: AppColors.warning,
                          ),
                          _SummaryItem(
                            label: "Due Today",
                            value: "${materials.take(6).length}",
                            icon: Icons.auto_awesome_rounded,
                            color: AppColors.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _FilterRow(
                        activeFilter: _filter,
                        totalCount: materials.length,
                        pendingCount: pendingCount,
                        deliveredCount: deliveredCount,
                        onChanged: (filter) {
                          setState(() {
                            _filter = filter;
                          });
                        },
                      ),
                      const SizedBox(height: 18),
                      if (filteredMaterials.isEmpty)
                        const _DashboardEmptyState()
                      else if (isWide)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                childAspectRatio: 0.9,
                              ),
                          itemCount: filteredMaterials.length,
                          itemBuilder:
                              (context, index) => TailorMaterialCard(
                                material: filteredMaterials[index],
                                onTap:
                                    () => _showMaterialDetails(
                                      context,
                                      filteredMaterials[index],
                                    ),
                              ),
                        )
                      else
                        ...filteredMaterials.map(
                          (material) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TailorMaterialCard(
                              material: material,
                              onTap:
                                  () => _showMaterialDetails(context, material),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  /// Bottom sheet for details (widgetized in its own file)
  void _showMaterialDetails(BuildContext context, TailorMaterialItem material) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TailorMaterialDetailSheet(material: material),
    );
  }

  DateTime _parseDate(String value) {
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }
}

enum _AttireFilter { all, pending, delivered }

class _TailorHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget? trailing;

  const _TailorHeroCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFCF7), Color(0xFFF3ECFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
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
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: AppColors.accent, size: 26),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          CustomText(
            title,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          CustomText(
            subtitle,
            fontSize: 13,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;

  const _MetricPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        children: [
          CustomText(
            value,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          CustomText(label, fontSize: 11, color: AppColors.subtext),
        ],
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final List<_SummaryItem> items;

  const _SummaryStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:
          items
              .map(
                (item) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: item == items.last ? 0 : 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(item.icon, color: item.color, size: 22),
                        const SizedBox(height: 10),
                        CustomText(
                          item.value,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                        const SizedBox(height: 3),
                        CustomText(
                          item.label,
                          fontSize: 11,
                          color: AppColors.subtext,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(),
    );
  }
}

class _SummaryItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _FilterRow extends StatelessWidget {
  final _AttireFilter activeFilter;
  final int totalCount;
  final int pendingCount;
  final int deliveredCount;
  final ValueChanged<_AttireFilter> onChanged;

  const _FilterRow({
    required this.activeFilter,
    required this.totalCount,
    required this.pendingCount,
    required this.deliveredCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomText(
          "Filter Projects",
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FilterChip(
              label: "All Projects",
              count: totalCount,
              selected: activeFilter == _AttireFilter.all,
              onTap: () => onChanged(_AttireFilter.all),
            ),
            _FilterChip(
              label: "Awaiting Action",
              count: pendingCount,
              selected: activeFilter == _AttireFilter.pending,
              onTap: () => onChanged(_AttireFilter.pending),
            ),
            _FilterChip(
              label: "Completed",
              count: deliveredCount,
              selected: activeFilter == _AttireFilter.delivered,
              onTap: () => onChanged(_AttireFilter.delivered),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: selected ? AppColors.accent : AppColors.ink,
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    selected
                        ? AppColors.accent.withValues(alpha: 0.12)
                        : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: CustomText(
                "$count",
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? AppColors.accent : AppColors.subtext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardEmptyState extends StatelessWidget {
  const _DashboardEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.subtext, size: 24),
          SizedBox(height: 10),
          CustomText(
            "No attires match this filter yet.",
            fontSize: 13,
            color: AppColors.subtext,
          ),
        ],
      ),
    );
  }
}
