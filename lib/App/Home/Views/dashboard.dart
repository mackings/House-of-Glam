import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/App/Home/Views/alltailors.dart';
import 'package:hog/App/Home/Views/tracking.dart';
import 'package:hog/App/NewestFeatures/Views/feature_hub.dart';
import 'package:hog/App/Tailors/details.dart';
import 'package:hog/TailorApp/Home/Views/Tailorbusiness.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/Tailors/tailorcard.dart';
import 'package:hog/components/bankCard.dart';
import 'package:hog/components/header.dart';
import 'package:hog/components/slideritem.dart';
import 'package:hog/components/sliders.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  final TextEditingController searchController = TextEditingController();

  List<Tailor> _tailors = [];
  List<Category> _categories = [];

  bool _isLoadingTailors = true;
  bool _isLoadingCategories = true;
  final Set<String> _openingTailorIds = <String>{};
  final Map<String, String> _prefetchedVendorImages = {};

  String userName = "User";
  String userAvatar = "https://i.pravatar.cc/150";

  @override
  void initState() {
    super.initState();
    _fetchTailors();
    _fetchCategories();
    _loadUserData();
  }

  Future<void> _fetchTailors() async {
    try {
      final tailors = await HomeApiService.getAllTailors();
      setState(() {
        _tailors = tailors;
        _isLoadingTailors = false;
      });
      _primeVendorProfiles(tailors);
    } catch (_) {
      setState(() {
        _isLoadingTailors = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    final userData = await SecurePrefs.getUserData();
    if (userData != null) {
      setState(() {
        userName = userData["fullName"] ?? "User";
        userAvatar = userData["image"] ?? "https://i.pravatar.cc/150";
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final categories = await HomeApiService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (_) {
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingCategories = true;
      _isLoadingTailors = true;
    });
    await Future.wait([_fetchCategories(), _fetchTailors()]);
  }

  void _primeVendorProfiles(List<Tailor> tailors) {
    for (final tailor in tailors) {
      final cachedImage = HomeApiService.getCachedVendorImage(tailor.id);
      if (cachedImage != null && cachedImage.isNotEmpty) {
        _prefetchedVendorImages[tailor.id] = cachedImage;
      }

      unawaited(
        HomeApiService.getVendorDetails(tailor.id).then((details) {
          if (!mounted || details == null) {
            return;
          }
          final image = details.userProfile.image.trim();
          if (image.isEmpty || _prefetchedVendorImages[tailor.id] == image) {
            return;
          }
          setState(() {
            _prefetchedVendorImages[tailor.id] = image;
          });
        }),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _openTailor(Tailor tailor) async {
    if (_openingTailorIds.contains(tailor.id)) {
      return;
    }

    setState(() {
      _openingTailorIds.add(tailor.id);
    });

    final vendorDetails = await HomeApiService.getVendorDetails(tailor.id);

    if (!mounted) {
      return;
    }

    setState(() {
      _openingTailorIds.remove(tailor.id);
    });

    if (vendorDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load designer details")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => Details(
              vendor: vendorDetails.vendor,
              userProfile: vendorDetails.userProfile,
              onRatingUpdated: _fetchTailors,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(
                  userName: userName,
                  avatarUrl: userAvatar,
                  onNotificationTap: () {
                    Nav.push(context, TrackingDelivery());
                  },
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFEFBFF), Color(0xFFF0E9FB)],
                    ),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomText(
                        "Discover Africa's finest designers and fashion drops.",
                        textAlign: TextAlign.left,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      const SizedBox(height: 6),
                      const CustomText(
                        "Discover designers, explore collections, and manage your journey seamlessly.",
                        textAlign: TextAlign.left,
                        color: AppColors.subtext,
                        fontSize: 12,
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final stackActions = constraints.maxWidth < 320;
                          final primaryAction = SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: () {
                                Nav.push(
                                  context,
                                  Alltailors(tailors: _tailors),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                elevation: 1,
                                shadowColor: AppColors.shadow,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text(
                                "Explore Designers",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                          final secondaryAction = OutlinedButton(
                            onPressed: () {
                              Nav.push(context, const FeatureHub());
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.accent,
                              minimumSize: const Size.fromHeight(46),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Style Studio",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );

                          if (stackActions) {
                            return Column(
                              children: [
                                primaryAction,
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: secondaryAction,
                                ),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              Expanded(child: primaryAction),
                              const SizedBox(width: 12),
                              Expanded(
                                child: SizedBox(
                                  height: 46,
                                  child: secondaryAction,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: CustomText(
                          "Ready to sell your designs?",
                          textAlign: TextAlign.left,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Nav.push(context, TailorRegistrationPage());
                        },
                        child: const Text("Become a Designer"),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                CarouselSlider(
                  height: 150,
                  items: const [
                    BankDetailsCard(),
                    CarouselItemWidget(
                      eyebrow: "Vendors favourites",
                      title: "Spice up your Owambe with Agbada",
                      subtitle: "Agbada that rocks every footwear.",
                      ctaLabel: "Shop Now",
                      imageAsset: "assets/Img/category_agbada.jpg",
                      background: Color(0xFFF1F4FF),
                      accent: Color(0xFF3159D9),
                    ),
                    CarouselItemWidget(
                      eyebrow: "Women's top choice",
                      title: "Beautifully made Blouse and Gele",
                      subtitle: "Statement styles made for women.",
                      ctaLabel: "Explore Styles",
                      imageAsset: "assets/Img/category_iro_buba.jpg",
                      background: Color(0xFFFFF1F4),
                      accent: Color(0xFFC85372),
                    ),
                    CarouselItemWidget(
                      eyebrow: "Women's glam",
                      title: "Ready-to-wear Kaftans",
                      subtitle: "Professionally made and measurement based.",
                      ctaLabel: "View Collection",
                      imageAsset: "assets/Img/category_kaftan.jpg",
                      background: Color(0xFFF3F8F2),
                      accent: Color(0xFF397A50),
                    ),
                    CarouselItemWidget(
                      eyebrow: "Best selling",
                      title: "Tailored premium suits",
                      subtitle: "For business and formal occasions.",
                      ctaLabel: "Try It Out",
                      imageAsset: "assets/Img/category_ankara_fusion.jpg",
                      background: Color(0xFFFFF4E8),
                      accent: Color(0xFFD86618),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: "Top Categories",
                  actionLabel: "Explore",
                  onTap: () {
                    Nav.push(context, TailorRegistrationPage());
                  },
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 112,
                  child:
                      _isLoadingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              return Container(
                                width: 92,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child:
                                            Category.isAssetImage(cat.image)
                                                ? Image.asset(
                                                  cat.image,
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                )
                                                : Image.network(
                                                  cat.image.isNotEmpty
                                                      ? cat.image
                                                      : "https://via.placeholder.com/150",
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) => Container(
                                                        color:
                                                            AppColors
                                                                .surfaceMuted,
                                                        alignment:
                                                            Alignment.center,
                                                        child: const Icon(
                                                          Icons.image_outlined,
                                                          color:
                                                              AppColors.subtext,
                                                        ),
                                                      ),
                                                ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    CustomText(
                                      cat.name.isNotEmpty
                                          ? cat.name
                                          : "Unnamed",
                                      textAlign: TextAlign.center,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),
                const SizedBox(height: 18),
                _SectionHeader(
                  title: "Top Rated Designers",
                  actionLabel: "See all",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Alltailors(tailors: _tailors),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const CustomText(
                  "Trusted profiles with strong reviews and active portfolios.",
                  textAlign: TextAlign.left,
                  color: AppColors.subtext,
                ),
                const SizedBox(height: 18),
                _isLoadingTailors
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      itemCount: _tailors.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.69,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      itemBuilder: (context, index) {
                        final tailor = _tailors[index];
                        return TailorCard(
                          tailor: tailor,
                          imageUrl: _prefetchedVendorImages[tailor.id],
                          onTap: () => _openTailor(tailor),
                        );
                      },
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomText(
            title,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.left,
          ),
        ),
        TextButton(
          onPressed: onTap,
          child: Text(
            actionLabel,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
