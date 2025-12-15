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

    // Shorten to max 30 characters
    if (description.length > 30) {
      return '${description.substring(0, 30)}...';
    }

    return description;
  }

  @override
  Widget build(BuildContext context) {
    final tailor = widget.tailor;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // 📱 Calculate responsive sizes
    final cardWidth = (screenWidth - 64) / 2; // Accounting for padding
    final imageHeight = cardWidth * 0.7; // 70% of card width
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🖼️ Image with favorite icon
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: (tailor.user?.image != null &&
                          tailor.user!.image!.isNotEmpty)
                      ? Image.network(
                          tailor.user!.image!,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: double.infinity,
                              color: Colors.grey[200],
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.person,
                                size: imageHeight * 0.4,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          height: imageHeight,
                          width: double.infinity,
                          color: Colors.grey[200],
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person,
                            size: imageHeight * 0.4,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                        size: isSmallScreen ? 16 : 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ✂️ Tailor Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 8.0 : 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        // Business Name
                        CustomText(
                          tailor.businessName ??
                              tailor.user?.fullName ??
                              "Unknown",
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 6),

                        // Description - Shortened
                        CustomText(
                          _getShortDescription(tailor.description),
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.grey[600]!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),

                    // 📦 Total ratings count
                    if ((tailor.totalRatings ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            CustomText(
                              "${tailor.totalRatings} reviews",
                              fontSize: isSmallScreen ? 10 : 11,
                              color: Colors.grey[700]!,
                              fontWeight: FontWeight.w500,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
