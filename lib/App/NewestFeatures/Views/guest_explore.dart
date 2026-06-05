import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/App/NewestFeatures/Api/newest_feature_service.dart';
import 'package:hog/App/NewestFeatures/Views/feature_hub.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class GuestExplore extends StatefulWidget {
  const GuestExplore({super.key});

  @override
  State<GuestExplore> createState() => _GuestExploreState();
}

class _GuestExploreState extends State<GuestExplore> {
  late Future<List<ApiResult>> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([
      NewestFeatureService.getPublicListings(),
      NewestFeatureService.getPublicDesigners(),
    ]);
  }

  void _requireAccount() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'Create an account to continue',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                const CustomText(
                  'You can explore as a guest. Buying, saving styles, messaging designers, and custom requests need an account.',
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 18),
                CustomButton(
                  title: 'Sign in or create account',
                  onPressed: () {
                    Navigator.pop(context);
                    Nav.pushReplacement(context, const Signin());
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('House of GLAME'),
        actions: [
          TextButton(
            onPressed: () => Nav.push(context, const Signin()),
            child: const Text('Sign in'),
          ),
        ],
      ),
      body: FutureBuilder<List<ApiResult>>(
        future: _future,
        builder: (context, snapshot) {
          final listings =
              snapshot.hasData
                  ? apiList(snapshot.data![0].data)
                  : const <Map<String, dynamic>>[];
          final designers =
              snapshot.hasData
                  ? apiList(snapshot.data![1].data)
                  : const <Map<String, dynamic>>[];

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = Future.wait([
                  NewestFeatureService.getPublicListings(),
                  NewestFeatureService.getPublicDesigners(),
                ]);
              });
              await _future;
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              children: [
                _GuestHero(onAction: _requireAccount),
                const SizedBox(height: 16),
                _SectionHeader(
                  title: 'Explore Collections',
                  actionLabel: 'Filters',
                  onAction: _requireAccount,
                ),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _LoadingPanel()
                else if (listings.isEmpty)
                  const _EmptyPanel(text: 'No public listings available yet.')
                else
                  ...listings
                      .take(8)
                      .map(
                        (item) => _PublicResultCard(
                          item: item,
                          icon: Icons.checkroom_outlined,
                          onProtectedAction: _requireAccount,
                        ),
                      ),
                const SizedBox(height: 16),
                _SectionHeader(title: 'Featured Designers'),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const _LoadingPanel()
                else if (designers.isEmpty)
                  const _EmptyPanel(text: 'No public designers available yet.')
                else
                  ...designers
                      .take(8)
                      .map(
                        (item) => _PublicResultCard(
                          item: item,
                          icon: Icons.design_services_outlined,
                          onProtectedAction: _requireAccount,
                        ),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GuestHero extends StatelessWidget {
  final VoidCallback onAction;

  const _GuestHero({required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            'Explore designers and collections without registering.',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 8),
          const CustomText(
            'When you want to buy, save, message, or request a custom outfit, we will ask you to create an account.',
            color: AppColors.subtext,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  title: 'Start custom request',
                  onPressed: onAction,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () => Nav.push(context, const FeatureHub()),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Preview tools',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PublicResultCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final IconData icon;
  final VoidCallback onProtectedAction;

  const _PublicResultCard({
    required this.item,
    required this.icon,
    required this.onProtectedAction,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        item['title']?.toString() ??
        item['businessName']?.toString() ??
        item['fullName']?.toString() ??
        item['name']?.toString() ??
        'Fashion item';
    final subtitle =
        item['description']?.toString() ??
        item['bio']?.toString() ??
        item['category']?.toString() ??
        'Open an account to interact with this item.';
    final image = _firstImage(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                image == null
                    ? Container(
                      width: 72,
                      height: 72,
                      color: AppColors.surfaceMuted,
                      child: Icon(icon, color: AppColors.accent),
                    )
                    : Image.network(
                      image,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => Container(
                            width: 72,
                            height: 72,
                            color: AppColors.surfaceMuted,
                            child: Icon(icon, color: AppColors.accent),
                          ),
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  title,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 4),
                CustomText(
                  subtitle,
                  fontSize: 12,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onProtectedAction,
                    icon: const Icon(Icons.favorite_border_rounded, size: 18),
                    label: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _firstImage(Map<String, dynamic> item) {
    final images = item['images'];
    if (images is List && images.isNotEmpty) return images.first?.toString();
    final media = item['media'];
    if (media is Map &&
        media['styledLookPreviews'] is List &&
        media['styledLookPreviews'].isNotEmpty) {
      return media['styledLookPreviews'].first?.toString();
    }
    final gallery = item['portfolioGallery'];
    if (gallery is List && gallery.isNotEmpty && gallery.first is Map) {
      return (gallery.first as Map)['imageUrl']?.toString();
    }
    return item['image']?.toString();
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: CustomText(
              title,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.left,
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  final String text;

  const _EmptyPanel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: CustomText(text, color: AppColors.subtext),
    );
  }
}
