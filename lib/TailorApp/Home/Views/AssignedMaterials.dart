import 'package:flutter/material.dart';
import 'package:hog/App/Home/Views/Offers/Views/OfferHome.dart';
import 'package:hog/TailorApp/Home/Api/TailorHomeservice.dart';
import 'package:hog/TailorApp/Home/Model/AssignedMaterial.dart';
import 'package:hog/TailorApp/Widgets/tailorAssignedCard.dart';
import 'package:hog/TailorApp/Widgets/tailorModalsheetdetails.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class AssignedMaterials extends StatefulWidget {
  const AssignedMaterials({super.key});

  @override
  State<AssignedMaterials> createState() => _AssignedMaterialsState();
}

class _AssignedMaterialsState extends State<AssignedMaterials> {
  late Future<TailorAssignedMaterialsResponse> _futureAssignedMaterials;
  final TailorHomeService _service = TailorHomeService();

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    setState(() {
      _futureAssignedMaterials = _service.fetchAssignedMaterials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: AppColors.canvas,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "Project Materials",
          fontSize: 18,
          color: AppColors.ink,
          fontWeight: FontWeight.w700,
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Nav.push(context, OfferHome());
            },
            icon: const Icon(Icons.local_offer_outlined, color: AppColors.ink),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<TailorAssignedMaterialsResponse>(
          future: _futureAssignedMaterials,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "❌ Error: ${snapshot.error}",
                  color: AppColors.danger,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.reviews.isEmpty) {
              return RefreshIndicator(
                onRefresh: _loadMaterials,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: CustomText(
                        "No project materials found",
                        fontSize: 16,
                        color: AppColors.subtext,
                      ),
                    ),
                  ],
                ),
              );
            }

            final materials = snapshot.data!.reviews;
            final quoted =
                materials
                    .where((item) => item.resolvedVendorBaseTotal > 0)
                    .length;

            return RefreshIndicator(
              onRefresh: _loadMaterials,
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _TailorIntroCard(
                    title: "Approved Projects",
                    subtitle:
                        "Review quotations, delivery timelines, and final production specifications.",
                    primaryLabel: "Active Projects",
                    primaryValue: "${materials.length}",
                    secondaryLabel: "Quoted",
                    secondaryValue: "$quoted",
                  ),
                  const SizedBox(height: 16),
                  ...materials.map((item) {
                    return TailorAssignedCard(
                      item: item,
                      onTap:
                          () => showTailorMaterialDetails(
                            context,
                            item,
                            () => _loadMaterials(),
                          ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TailorIntroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String primaryLabel;
  final String primaryValue;
  final String secondaryLabel;
  final String secondaryValue;

  const _TailorIntroCard({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: AppColors.accent,
                ),
              ),
              const Spacer(),
              _CompactStat(label: primaryLabel, value: primaryValue),
              const SizedBox(width: 8),
              _CompactStat(label: secondaryLabel, value: secondaryValue),
            ],
          ),
          const SizedBox(height: 18),
          CustomText(
            title,
            fontSize: 20,
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

class _CompactStat extends StatelessWidget {
  final String label;
  final String value;

  const _CompactStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CustomText(
            value,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          CustomText(label, fontSize: 11, color: AppColors.subtext),
        ],
      ),
    );
  }
}
