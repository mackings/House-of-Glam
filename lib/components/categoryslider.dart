import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/category.dart';

class CategorySlider extends StatelessWidget {
  final List<Map<String, String>> categories; // title + imageUrl
  final Function(int index)? onCategoryTap;

  const CategorySlider({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final imageUrl = category['imageUrl'] ?? '';
          return GestureDetector(
            onTap: () => onCategoryTap?.call(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      imageUrl.isEmpty || Category.isAssetImage(imageUrl)
                          ? null
                          : NetworkImage(imageUrl),
                  child:
                      Category.isAssetImage(imageUrl)
                          ? ClipOval(
                            child: Image.asset(
                              imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                            ),
                          )
                          : null,
                ),
                const SizedBox(height: 8),
                Text(
                  category['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
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
