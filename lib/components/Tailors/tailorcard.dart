import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/components/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TailorCard extends StatefulWidget {
  final Tailor tailor;
  final VoidCallback? onTap;

  const TailorCard({Key? key, required this.tailor, this.onTap})
    : super(key: key);

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

  // Helper function to shorten description
  String _getShortDescription(String? description) {
    if (description == null || description.isEmpty) {
      return "No description";
    }

    // Shorten to max 40 characters
    if (description.length > 30) {
      return '${description.substring(0, 30)}...';
    }

    return description;
  }

  @override
  Widget build(BuildContext context) {
    final tailor = widget.tailor;

    // ✅ Calculate average rating
    if ((tailor.totalRatings ?? 0) > 0) {}

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🖼️ Image with favorite icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child:
                      (tailor.user?.image != null &&
                              tailor.user!.image!.isNotEmpty)
                          ? Image.network(
                            tailor.user!.image!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
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
                        size: 18,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Business Name
                  
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CustomText(
                      tailor.businessName ?? tailor.user?.fullName ?? "Unknown",
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Description - Shortened

                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CustomText(
                      _getShortDescription(tailor.description),
                      fontSize: 12,
                      color: Colors.grey[600]!,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ⭐ Rating Row
                  Container(
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Stars
                        // Row(
                        // mainAxisSize: MainAxisSize.min,
                        // children: List.generate(5, (index) {
                        // if (index < avgRating.floor()) {
                        // return const Icon(
                        // Icons.star,
                        // size: 16,
                        // color: Colors.amber,
                        // );
                        // } else if (index < avgRating) {
                        // return const Icon(
                        // Icons.star_half,
                        // size: 16,
                        // color: Colors.amber,
                        // );
                        // }
                        // return const Icon(
                        // Icons.star_border,
                        // size: 16,
                        // color: Colors.amber,
                        // );
                        // }),
                        // ),
                        const SizedBox(width: 6),

                        // Rating number
                        // CustomText(
                        // avgRating.toStringAsFixed(1),
                        // fontSize: 13,
                        // fontWeight: FontWeight.w600,
                        // color: Colors.black87,
                        // ),
                      ],
                    ),
                  ),

                  // 📦 Total ratings count
                  if ((tailor.totalRatings ?? 0) > 0)
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: CustomText(
                        "${tailor.totalRatings} reviews",
                        fontSize: 11,
                        color: Colors.grey,
                        textAlign: TextAlign.center,
                      ),
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
