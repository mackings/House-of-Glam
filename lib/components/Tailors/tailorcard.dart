import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';


class TailorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating; // optional rating
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const TailorCard({
    Key? key,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    this.rating = 4.5,
    this.onTap,
    this.onFavoriteTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.4),
        color: Colors.white, // brighter background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image with circular avatar style
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: const Icon(Icons.favorite_border, color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),

            // Tailor Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  CustomText(
                    name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    specialty,
                    fontSize: 13,
                    color: Colors.grey[600]!,
                  ),
                  const SizedBox(height: 8),

                  // Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      if (index < rating.floor()) {
                        return const Icon(Icons.star, size: 16, color: Colors.amber);
                      } else if (index < rating) {
                        return const Icon(Icons.star_half, size: 16, color: Colors.amber);
                      }
                      return const Icon(Icons.star_border, size: 16, color: Colors.amber);
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


