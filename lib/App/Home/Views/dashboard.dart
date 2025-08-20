import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/categoryslider.dart';
import 'package:hog/components/header.dart';
import 'package:hog/components/search.dart';
import 'package:hog/components/slideritem.dart';
import 'package:hog/components/sliders.dart';


class Home extends ConsumerStatefulWidget {
  const Home({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeState();
}

class _HomeState extends ConsumerState<Home> {

  TextEditingController searchController = TextEditingController();


  @override
void initState() {
  super.initState();
  searchController = TextEditingController();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20), // add nice spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Header(
                userName: "Mac Kingsley",
                avatarUrl: "https://i.pravatar.cc/150?img=3",
                onNotificationTap: () {
                  print("Notifications tapped!");
                },
              ),
              const SizedBox(height: 20),
              
CustomSearchBar(
  controller: searchController,
  hintText: "Search item",
  onChanged: (value) => print("Search: $value"),
  onFilterTap: () => print("Filter tapped!"),
),

const SizedBox(height: 30),


CarouselSlider(
  height: 180,
  items: const [
CarouselItemWidget(
          title: "",
           assetImage: 'assets/Img/suits.png',
        ),
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
          assetImage: 'assets/Img/corporate.png',
        ),
  ],
),

            const SizedBox(height: 30),

  CategorySlider(
  categories: const [
    {"title": "Shirts", "imageUrl": "https://i.pravatar.cc/150?img=10"},
    {"title": "Jeans", "imageUrl": "https://i.pravatar.cc/150?img=20"},
    {"title": "Shoes", "imageUrl": "https://i.pravatar.cc/150?img=30"},
    {"title": "Hats", "imageUrl": "https://i.pravatar.cc/150?img=40"},
    {"title": "Jackets", "imageUrl": "https://i.pravatar.cc/150?img=50"},
  ],
  onCategoryTap: (index) {
    print("Tapped category $index");
  },
),



            ],
          ),
        ),
      ),
    );
  }
}
