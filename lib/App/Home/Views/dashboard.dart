import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/category.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/App/Home/Views/alltailors.dart';
import 'package:hog/App/Home/Views/tracking.dart';
import 'package:hog/App/Tailors/details.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/components/Tailors/tailorcard.dart';
import 'package:hog/components/header.dart';
import 'package:hog/components/slideritem.dart';
import 'package:hog/components/sliders.dart';
import 'package:hog/components/texts.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {
  TextEditingController searchController = TextEditingController();

  List<Tailor> _tailors = [];
  List<Category> _categories = [];

  bool _isLoadingTailors = true;
  bool _isLoadingCategories = true;

  String userName = "User"; // default
  String userAvatar = "https://i.pravatar.cc/150"; // default

  void _onNavTap(int index) {
    setState(() {});
  }

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
    } catch (e) {
      print("❌ Error fetching tailors: $e");
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
      print("✅ Fetched ${categories.length} categories");
      if (categories.isNotEmpty) {
        print("📋 Category names: ${categories.map((c) => c.name).toList()}");
        print("🖼️ First category image: ${categories.first.image}");
      }
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      print("❌ Error fetching categories: $e");
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Reset loading state
            setState(() {
              _isLoadingCategories = true;
              _isLoadingTailors = true;
            });
            // Fetch both
            await Future.wait([_fetchCategories(), _fetchTailors()]);
          },
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(), // required for RefreshIndicator
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Header(
                  userName: userName,
                  avatarUrl: userAvatar,
                  onNotificationTap: () {
                    Nav.push(context, TrackingDelivery());
                    print("Notifications tapped!");
                  },
                ),

                //const SizedBox(height: 10),

                // CustomSearchBar(
                //   controller: searchController,
                //   hintText: "Search item",
                //   onChanged: (value) => print("Search: $value"),
                //   onFilterTap: () => print("Filter tapped!"),
                // ),
                const SizedBox(height: 30),

                CarouselSlider(
                  height: 150,
                  items: const [
                    CarouselItemWidget(
                      title: "",
                      assetImage: 'assets/Img/agbada.png',
                    ),
                    CarouselItemWidget(
                      title: "",
                      assetImage: 'assets/Img/gele.png',
                    ),
                    CarouselItemWidget(
                      title: "",
                      assetImage: 'assets/Img/kaftan.png',
                    ),
                    CarouselItemWidget(
                      title: "",
                      assetImage: 'assets/Img/suits.png',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      "Top Categories",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),

                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 15,
                    //     vertical: 5,
                    //   ),
                    //   child: CustomText(
                    //     "view more",
                    //     fontSize: 15,
                    //     fontWeight: FontWeight.w500,
                    //     color: Colors.purple,
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  height: 120,
                  child:
                      _isLoadingCategories
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            separatorBuilder:
                                (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final cat = _categories[index];
                              return GestureDetector(
                                onTap: () {
                                  print("Tapped category ${cat.name}");
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                            cat.image?.isNotEmpty == true
                                                ? cat.image!
                                                : "https://via.placeholder.com/150",
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      width: 80,
                                      child: CustomText(
                                        cat.name?.isNotEmpty == true
                                            ? cat.name!
                                            : "Unnamed",
                                        textAlign: TextAlign.center,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      "Top rated Tailors",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.purple,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Alltailors(tailors: _tailors),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 5,
                          ),
                          child: CustomText(
                            "See all",
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                _isLoadingTailors
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      itemCount: _tailors.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 3 / 4,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemBuilder: (context, index) {
                        final tailor = _tailors[index];
                        return TailorCard(
                          name: tailor.user?.fullName ?? "Unknown",
                          specialty: tailor.businessName ?? "N/A",
                          imageUrl:
                              tailor.user?.image ??
                              tailor.nepaBill ??
                              "https://i.pravatar.cc/150?img=5",
                          onTap: () async {
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
