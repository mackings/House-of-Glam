import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hog/components/Tailors/tailorcard.dart';
import 'package:hog/components/categoryslider.dart';
import 'package:hog/components/header.dart';
import 'package:hog/components/navbar.dart';
import 'package:hog/components/search.dart';
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
    int _selectedIndex = 0;

    void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

      final tailors = [
      {
        "name": "John Doe",
        "specialty": "Suits",
        "image": "https://i.pravatar.cc/150?img=5"
      },
      {
        "name": "Mary Smith",
        "specialty": "Agbada",
        "image": "https://i.pravatar.cc/150?img=5"
      },
      {
        "name": "James Lee",
        "specialty": "Kaftan",
        "image": "https://i.pravatar.cc/150?img=7"
      },
      {
        "name": "Sophia Brown",
        "specialty": "Corporate",
        "image": "https://i.pravatar.cc/150?img=8"
      },
      {
        "name": "Michael Adams",
        "specialty": "Casuals",
        "image": "https://i.pravatar.cc/150?img=9"
      },
      {
        "name": "Angela White",
        "specialty": "Gowns",
        "image": "https://i.pravatar.cc/150?img=10"
      },
    ];


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
    CustomText("Top Categories", fontSize: 16, fontWeight: FontWeight.w500),
    Padding(
      padding: const EdgeInsets.only(left: 15,right: 15,top: 5, bottom: 5),
      child: CustomText("view more", fontSize: 15, fontWeight: FontWeight.w500, color: Colors.purple),
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

SizedBox(height: 20,),

Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    CustomText("Top rated Tailors", fontSize: 16, fontWeight: FontWeight.w500),
    Container(
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 15,right: 15,top: 5, bottom: 5),
        child: CustomText("See all", fontSize: 15, fontWeight: FontWeight.w500, color: Colors.white),
      ),),
  ],
),


SizedBox(height: 20,),

GridView.builder(
  itemCount: tailors.length,
  shrinkWrap: true, // Important: makes grid take only needed space
  physics: const NeverScrollableScrollPhysics(), // disable nested scroll
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // 2 cards per row
    childAspectRatio: 3 / 4, // card shape
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemBuilder: (context, index) {
    final tailor = tailors[index];
    return TailorCard(
      name: tailor["name"]!,
      specialty: tailor["specialty"]!,
      imageUrl: tailor["image"]!,
      onTap: () {
        // handle navigation later
        print("Tapped on ${tailor["name"]}");
      },
    );
  },
),




            ],
          ),
        ),
      ),

    );
  }
}
