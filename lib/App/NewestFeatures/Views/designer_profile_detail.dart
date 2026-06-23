import 'package:flutter/material.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class DesignerProfileDetail extends StatefulWidget {
  final String designerId;
  final Map<String, dynamic>? initialData;

  const DesignerProfileDetail({
    super.key,
    required this.designerId,
    this.initialData,
  });

  @override
  State<DesignerProfileDetail> createState() => _DesignerProfileDetailState();
}

class _DesignerProfileDetailState extends State<DesignerProfileDetail> {
  late Future<ApiResult> _future;
  bool _showPortfolio = false;

  @override
  void initState() {
    super.initState();
    _future = NewestFeatureService.getDesignerProfile(widget.designerId);
  }

  Future<void> _launchWhatsApp(String phone) async {
    final normalizedPhone = phone.replaceAll(RegExp(r'\D'), '');
    if (normalizedPhone.isEmpty) {
      _showSnackBar('No WhatsApp number is available for this designer.');
      return;
    }

    final url = Uri.parse('https://wa.me/$normalizedPhone');
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showSnackBar('Could not open WhatsApp');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Designer Profile'),
        backgroundColor: AppColors.canvas,
        surfaceTintColor: Colors.transparent,
      ),
      body: FutureBuilder<ApiResult>(
        future: _future,
        builder: (context, snapshot) {
          final profile =
              snapshot.hasData && snapshot.data!.success
                  ? apiMap(snapshot.data!.data)
                  : widget.initialData ?? const <String, dynamic>{};

          if (snapshot.connectionState == ConnectionState.waiting &&
              profile.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final name =
              profile['businessName']?.toString() ??
              profile['fullName']?.toString() ??
              profile['name']?.toString() ??
              'Designer';
          final bio = profile['bio']?.toString() ?? 'No bio added yet.';
          final verified = profile['isVerifiedDesigner'] == true;
          final tags =
              (profile['specializationTags'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const <String>[];
          final socialProof = apiMap(profile['socialProof']);
          final gallery = _portfolioGallery(profile);
          final sections = apiMap(profile['categorizedWorkSections']);
          final phone = _profilePhone(profile);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            name,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        if (verified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.accentSoft,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: AppColors.accent,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                      bio,
                      color: AppColors.subtext,
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          Icons.schedule_rounded,
                          profile['turnaroundTime']?.toString() ??
                              'Turnaround not set',
                        ),
                        _InfoChip(
                          Icons.event_available_rounded,
                          profile['availabilityStatus']?.toString() ??
                              'Availability not set',
                        ),
                        _InfoChip(
                          Icons.work_history_outlined,
                          '${profile['yearsOfExperience'] ?? 0} years',
                        ),
                      ],
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            tags
                                .map(
                                  (tag) => Chip(
                                    label: Text(tag),
                                    backgroundColor: AppColors.surfaceMuted,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (phone != null) ...[
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const ValueKey('designer_whatsapp_button'),
                    onPressed: () => _launchWhatsApp(phone),
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Chat on WhatsApp'),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              _SocialProof(socialProof: socialProof),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('view_designer_portfolio'),
                  onPressed:
                      () => setState(() => _showPortfolio = !_showPortfolio),
                  icon: Icon(
                    _showPortfolio
                        ? Icons.expand_less_rounded
                        : Icons.photo_library_outlined,
                  ),
                  label: Text(
                    _showPortfolio ? 'Hide portfolio' : 'View portfolio',
                  ),
                ),
              ),
              if (_showPortfolio) ...[
                const SizedBox(height: 14),
                _GallerySection(title: 'Portfolio Gallery', urls: gallery),
                const SizedBox(height: 14),
                ...sections.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _GallerySection(
                      title: _sectionLabel(entry.key),
                      urls:
                          entry.value is List
                              ? (entry.value as List)
                                  .map((e) => e.toString())
                                  .toList()
                              : const <String>[],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  List<String> _portfolioGallery(Map<String, dynamic> profile) {
    final gallery = profile['portfolioGallery'];
    if (gallery is List) {
      return gallery
          .map((item) {
            if (item is Map) return item['imageUrl']?.toString() ?? '';
            return item?.toString() ?? '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String? _profilePhone(Map<String, dynamic> profile) {
    final nestedUser = apiMap(profile['user']);
    final candidates = [
      profile['whatsappNumber'],
      profile['whatsAppNumber'],
      profile['businessPhone'],
      profile['phoneNumber'],
      profile['phone'],
      profile['contactPhone'],
      nestedUser['phoneNumber'],
      nestedUser['phone'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString().trim() ?? '';
      if (value.replaceAll(RegExp(r'\D'), '').isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String _sectionLabel(String key) {
    switch (key) {
      case 'nativeWear':
        return 'Native Wear';
      case 'menswear':
        return 'Menswear';
      case 'womenswear':
        return 'Womenswear';
      default:
        return key.isEmpty
            ? 'Section'
            : '${key[0].toUpperCase()}${key.substring(1)}';
    }
  }
}

class _SocialProof extends StatelessWidget {
  final Map<String, dynamic> socialProof;

  const _SocialProof({required this.socialProof});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Completed',
        socialProof['completedOrders'] ?? socialProof['orders'] ?? 0,
      ),
      ('Reviews', socialProof['reviews'] ?? socialProof['reviewCount'] ?? 0),
      ('Ratings', socialProof['ratings'] ?? socialProof['averageRating'] ?? 0),
    ];

    return Row(
      children:
          items
              .map(
                (item) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        CustomText(
                          item.$2.toString(),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                        const SizedBox(height: 4),
                        CustomText(
                          item.$1,
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

class _GallerySection extends StatelessWidget {
  final String title;
  final List<String> urls;

  const _GallerySection({required this.title, required this.urls});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          if (urls.isEmpty)
            const CustomText(
              'No work added yet.',
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: urls.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder:
                  (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      urls[index],
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            color: AppColors.surfaceMuted,
                            child: const Icon(Icons.broken_image_outlined),
                          ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
