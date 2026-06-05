import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/App/Tailors/details.dart';
import 'package:hog/components/Tailors/tailorcard.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

class Alltailors extends ConsumerStatefulWidget {
  final List<Tailor> tailors;

  const Alltailors({super.key, required this.tailors});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlltailorsState();
}

class _AlltailorsState extends ConsumerState<Alltailors> {
  final Set<String> _openingTailorIds = <String>{};
  final Map<String, String> _prefetchedVendorImages = {};
  late List<Tailor> _tailors;

  @override
  void initState() {
    super.initState();
    _tailors = List<Tailor>.from(widget.tailors);
    _primeVendorProfiles();
  }

  void _primeVendorProfiles() {
    for (final tailor in _tailors) {
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

  Future<void> _refreshTailors() async {
    final tailors = await HomeApiService.getAllTailors();
    if (!mounted) return;
    setState(() => _tailors = tailors);
    _primeVendorProfiles();
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
              onRatingUpdated: _refreshTailors,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: const CustomAppBar(
        title: "Browse Designers",
        enableAction: false,
      ),
      body: SafeArea(
        child:
            _tailors.isEmpty
                ? const Center(child: Text("No designers available"))
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 6, 20, 0),
                      child: CustomText(
                        "Find and connect with skilled designers near you.",
                        textAlign: TextAlign.left,
                        color: AppColors.subtext,
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _tailors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.69,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
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
                    ),
                  ],
                ),
      ),
    );
  }
}
