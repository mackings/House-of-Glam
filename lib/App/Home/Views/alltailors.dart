import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/App/Tailors/details.dart';
import 'package:hog/components/Tailors/tailorcard.dart';
import 'package:hog/components/texts.dart';

class Alltailors extends ConsumerStatefulWidget {
  final List<Tailor> tailors;

  const Alltailors({super.key, required this.tailors});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlltailorsState();
}

class _AlltailorsState extends ConsumerState<Alltailors> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const CustomText(
          "All tailors",
          fontSize: 18,
          color: Colors.white,
        ),
        backgroundColor: Colors.purple,
      ),
      body: SafeArea(
        child:
            widget.tailors.isEmpty
                ? const Center(child: Text("No tailors available"))
                : GridView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: widget.tailors.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final tailor = widget.tailors[index];
                    return TailorCard(
                      name: tailor.user?.fullName ?? "Unknown",
                      specialty: tailor.businessName ?? "N/A",
                      imageUrl:
                          tailor.user?.image ??
                          tailor.nepaBill ??
                          "https://i.pravatar.cc/150?img=5",
                      onTap: () async{
                        print("Tapped on ${tailor.user?.fullName}");

                                                    print("Tapped on ${tailor.id}");

                            // fetch vendor details from API
                            final vendorDetails =
                                await HomeApiService.getVendorDetails(
                                  tailor.id,
                                );

                            if (vendorDetails != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => Details(
                                        vendor: vendorDetails.vendor,
                                        userProfile: vendorDetails.userProfile,
                                      ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Failed to load tailor details",
                                  ),
                                ),
                              );
                            }
                      },
                      id: tailor.id,
                    );
                  },
                ),
      ),
    );
  }
}
