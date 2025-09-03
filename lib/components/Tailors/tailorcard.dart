import 'package:flutter/material.dart';
import 'package:hog/components/texts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TailorCard extends StatefulWidget {
  final String id; // unique id for each tailor
  final String name;
  final String specialty;
  final String imageUrl;
  final double rating;
  final VoidCallback? onTap;

  const TailorCard({
    Key? key,
    required this.id,
    required this.name,
    required this.specialty,
    required this.imageUrl,
    this.rating = 4.5,
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
      isFavorite = savedFavorites.contains(widget.id);
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favoriteTailors') ?? [];

    setState(() {
      if (isFavorite) {
        savedFavorites.remove(widget.id);
        isFavorite = false;
      } else {
        savedFavorites.add(widget.id);
        isFavorite = true;
      }
      prefs.setStringList('favoriteTailors', savedFavorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        shadowColor: Colors.grey.withOpacity(0.4),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image with circular avatar style
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    widget.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
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

            // Tailor Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  CustomText(
                    widget.name,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    widget.specialty,
                    fontSize: 13,
                    color: Colors.grey[600]!,
                  ),
                  const SizedBox(height: 8),

                  // Rating Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      if (index < widget.rating.floor()) {
                        return const Icon(Icons.star, size: 16, color: Colors.amber);
                      } else if (index < widget.rating) {
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



