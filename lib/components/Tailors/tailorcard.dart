import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/components/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';



class TailorCard extends StatefulWidget {
  final Tailor tailor;
  final VoidCallback? onTap;

  const TailorCard({
    Key? key,
    required this.tailor,
    this.onTap,
  }) : super(key: key);

  @override
  State<TailorCard> createState() => _TailorCardState();
}

class _TailorCardState extends State<TailorCard> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favoriteTailors') ?? [];
    setState(() {
      isFavorite = savedFavorites.contains(widget.tailor.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favoriteTailors') ?? [];

    setState(() {
      if (isFavorite) {
        savedFavorites.remove(widget.tailor.id);
        isFavorite = false;
      } else {
        savedFavorites.add(widget.tailor.id);
        isFavorite = true;
      }
      prefs.setStringList('favoriteTailors', savedFavorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tailor = widget.tailor;

    // ✅ Calculate average rating
    double avgRating = 0.0;
    if ((tailor.totalRatings ?? 0) > 0) {
      avgRating =
          (tailor.ratingSum ?? 0) / (tailor.totalRatings!.toDouble());
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.4),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼️ Image with favorite icon
            Stack(
              children: [
ClipRRect(
  borderRadius: const BorderRadius.vertical(
    top: Radius.circular(20),
  ),
  child: (tailor.user?.image != null && tailor.user!.image!.isNotEmpty)
      ? Image.network(
          tailor.user!.image!,
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // 🧍 Show person icon if image fails to load
            return Container(
              height: 120,
              width: double.infinity,
              color: Colors.grey[200],
              alignment: Alignment.center,
              child: const Icon(
                Icons.person,
                size: 60,
                color: Colors.grey,
              ),
            );
          },
        )
      : Container(
          height: 120,
          width: double.infinity,
          color: Colors.grey[200],
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.grey,
          ),
        ),
),

                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ✂️ Tailor Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  CustomText(
                    tailor.businessName ?? tailor.user?.fullName ?? "Unknown",
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    tailor.description ?? "No description",
                    fontSize: 11,
                    color: Colors.grey[600]!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // ⭐ Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...List.generate(5, (index) {
                        if (index < avgRating.floor()) {
                          return const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          );
                        } else if (index < avgRating) {
                          return const Icon(
                            Icons.star_half,
                            size: 16,
                            color: Colors.amber,
                          );
                        }
                        return const Icon(
                          Icons.star_border,
                          size: 16,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 5),
                      CustomText(
                        avgRating.toStringAsFixed(1),
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ],
                  ),

                  // 📦 Optional: Show total ratings count
                  if ((tailor.totalRatings ?? 0) > 0)
                    CustomText(
                      "(${tailor.totalRatings} reviews)",
                      fontSize: 11,
                      color: Colors.grey,
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
