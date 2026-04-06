import 'package:flutter/material.dart';
import 'package:hog/App/Home/Model/tailor.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TailorCard extends StatefulWidget {
  final Tailor tailor;
  final VoidCallback? onTap;
  final String? imageUrl;

  const TailorCard({Key? key, required this.tailor, this.onTap, this.imageUrl})
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

  String _getShortDescription(String? description) {
    if (description == null || description.isEmpty) {
      return "No description";
    }
    if (description.length > 52) {
      return '${description.substring(0, 52)}...';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    final tailor = widget.tailor;
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 64) / 2;
    final imageHeight = cardWidth * 0.74;
    final isSmallScreen = screenWidth < 360;
    final imageToUse = (widget.imageUrl != null && widget.imageUrl!.trim().isNotEmpty)
        ? widget.imageUrl!.trim()
        : ((tailor.user?.image != null && tailor.user!.image!.trim().isNotEmpty)
            ? tailor.user!.image!.trim()
            : null);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),
                  child: imageToUse != null
                      ? Image.network(
                          imageToUse,
                          height: imageHeight,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _placeholder(imageHeight);
                          },
                        )
                      : _placeholder(imageHeight),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: _toggleFavorite,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? AppColors.danger : AppColors.subtext,
                        size: isSmallScreen ? 16 : 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 10.0 : 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          tailor.businessName ??
                              tailor.user?.fullName ??
                              "Unknown",
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 6),
                        CustomText(
                          _getShortDescription(tailor.description),
                          fontSize: isSmallScreen ? 11 : 12,
                          color: AppColors.subtext,
                          textAlign: TextAlign.left,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    if ((tailor.totalRatings ?? 0) > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            CustomText(
                              "${tailor.totalRatings} reviews",
                              fontSize: isSmallScreen ? 10 : 11,
                              color: AppColors.subtext,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.left,
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

  Widget _placeholder(double imageHeight) {
    final initialsSource =
        widget.tailor.businessName ??
        widget.tailor.user?.fullName ??
        "T";
    final initials =
        initialsSource.trim().isEmpty ? "T" : initialsSource.trim()[0].toUpperCase();

    return Container(
      height: imageHeight,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF0ECF8), Color(0xFFE7F1F8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: imageHeight * 0.28,
          fontWeight: FontWeight.w700,
          color: AppColors.subtext,
        ),
      ),
    );
  }
}
