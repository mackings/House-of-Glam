import 'package:flutter/material.dart';
import 'package:hog/TailorApp/Home/Api/publishservice.dart';
import 'package:hog/TailorApp/Home/Model/PublishedModel.dart';
import 'package:hog/TailorApp/Home/Views/Publish.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:intl/intl.dart';

class Myworks extends StatefulWidget {
  const Myworks({super.key});

  @override
  State<Myworks> createState() => _MyworksState();
}

class _MyworksState extends State<Myworks> {
  final _service = PublishedService();
  late Future<TailorPublishedResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.getAllPublished();
  }

  Future<void> _reload() async {
    setState(() {
      _future = _service.getAllPublished();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.ink),
        title: const CustomText(
          "My Works",
          color: AppColors.ink,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () => Nav.push(context, PublishMaterial()),
              icon: const Icon(Icons.add_photo_alternate_outlined),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.ink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<TailorPublishedResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: CustomText(
                  "Error: ${snapshot.error}",
                  color: AppColors.danger,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return RefreshIndicator(
                onRefresh: _reload,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: const [
                    _WorksHeroCard(
                      totalWorks: "0",
                      title: "No published looks yet",
                      subtitle:
                          "Your finished pieces will appear here after you publish them for clients to browse.",
                    ),
                  ],
                ),
              );
            }

            final works = snapshot.data!.data;

            return RefreshIndicator(
              onRefresh: _reload,
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                children: [
                  _WorksHeroCard(
                    totalWorks: "${works.length}",
                    title: "Published portfolio",
                    subtitle:
                        "Keep your best pieces updated so buyers and admins always see your strongest work.",
                  ),
                  const SizedBox(height: 16),
                  ...works.map(
                    (work) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _PublishedWorkCard(work: work),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _WorksHeroCard extends StatelessWidget {
  final String totalWorks;
  final String title;
  final String subtitle;

  const _WorksHeroCard({
    required this.totalWorks,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFF4ECFF)],
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
                child: const Icon(
                  Icons.workspace_premium_outlined,
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
                child: Column(
                  children: [
                    CustomText(
                      totalWorks,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    const CustomText(
                      "Pieces",
                      fontSize: 11,
                      color: AppColors.subtext,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          CustomText(
            title,
            fontSize: 21,
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

class _PublishedWorkCard extends StatelessWidget {
  final TailorPublished work;

  const _PublishedWorkCard({required this.work});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("d MMM y • h:mm a").format(work.createdAt);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child:
                  work.sampleImage.isNotEmpty
                      ? Image.network(
                        work.sampleImage.first,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => _fallbackImage(),
                      )
                      : _fallbackImage(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CustomText(
                        work.clothPublished,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        textAlign: TextAlign.left,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F7F0),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const CustomText(
                        "Live",
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip(Icons.checkroom_outlined, work.attireType),
                    _chip(Icons.shopping_bag_outlined, work.brand),
                    _chip(Icons.palette_outlined, work.color),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.accentSoft,
                        backgroundImage:
                            work.user?.image != null
                                ? NetworkImage(work.user!.image!)
                                : null,
                        child:
                            work.user?.image == null
                                ? const Icon(
                                  Icons.person_outline_rounded,
                                  color: AppColors.accent,
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              work.user?.fullName ?? "Unknown owner",
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              textAlign: TextAlign.left,
                            ),
                            if ((work.user?.address ?? "").isNotEmpty)
                              CustomText(
                                work.user!.address!,
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.subtext,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: CustomText(
                        formattedDate,
                        fontSize: 12,
                        color: AppColors.subtext,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.subtext),
          const SizedBox(width: 6),
          CustomText(
            text.isEmpty ? "N/A" : text,
            fontSize: 11,
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.image_outlined,
          color: AppColors.accent,
          size: 30,
        ),
      ),
    );
  }
}
