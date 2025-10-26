import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/vendor.dart';
import 'package:hog/components/texts.dart';

class Details extends StatefulWidget {
  final Vendor vendor;
  final UserProfile userProfile;

  const Details({super.key, required this.vendor, required this.userProfile});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int _selectedRating = 0;
  bool _isSubmittingRating = false;

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            subtitle.isNotEmpty ? subtitle : "Not provided",
            style: const TextStyle(color: Colors.black87, fontSize: 14),
          ),
        ),
        const Divider(thickness: 1, height: 0),
      ],
    );
  }

  void _showRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildRatingSheet(),
    );
  }

  Widget _buildRatingSheet() {
    // Use StatefulBuilder to manage local state within the bottom sheet
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Text(
                "Rate ${widget.vendor.businessName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 16),

              // Rating Description
              const Text(
                "How was your experience with this designer?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        size: 40,
                        color:
                            index < _selectedRating
                                ? Colors.amber
                                : Colors.grey,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Rating Text
              Text(
                _selectedRating == 0
                    ? "Tap a star to rate"
                    : _selectedRating == 1
                    ? "Poor"
                    : _selectedRating == 2
                    ? "Fair"
                    : _selectedRating == 3
                    ? "Good"
                    : _selectedRating == 4
                    ? "Very Good"
                    : "Excellent",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 32),

              // Rate Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      _selectedRating == 0 || _isSubmittingRating
                          ? null
                          : () => _submitRating(setModalState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    disabledBackgroundColor: Colors.purple.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child:
                      _isSubmittingRating
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                          : const Text(
                            "Rate Designer",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 12),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitRating(StateSetter setModalState) async {
    setModalState(() {
      _isSubmittingRating = true;
    });

    final success = await HomeApiService.rateVendor(
      widget.vendor.id,
      _selectedRating,
    );

    setModalState(() {
      _isSubmittingRating = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Thanks for rating ${widget.vendor.businessName}!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to submit rating. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final userProfile = widget.userProfile;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: CustomText(
          vendor.businessName,
          color: Colors.white,
          fontSize: 20,
        ),
        centerTitle: true,
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Image or Fallback Avatar
            Container(
              padding: const EdgeInsets.all(16),
              child:
                  userProfile.image.isNotEmpty
                      ? CircleAvatar(
                        radius: 60,
                        backgroundImage: NetworkImage(userProfile.image),
                      )
                      : CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blueAccent,
                        child: Text(
                          userProfile.fullName.isNotEmpty
                              ? userProfile.fullName[0].toUpperCase()
                              : "?",
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
            ),

            // Name
            Text(
              userProfile.fullName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // Business Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                vendor.description,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(thickness: 1),

            // Details with icons
           // _buildInfoTile(Icons.email, "Business Email", vendor.businessEmail),
         //   _buildInfoTile(Icons.phone, "Business Phone", ""),
            _buildInfoTile(
              Icons.location_on,
              "Business Address",
              vendor.address,
            ),
            _buildInfoTile(Icons.location_city, "City", vendor.city),
            _buildInfoTile(Icons.map, "State", vendor.state),
            _buildInfoTile(
              Icons.work,
              "Experience",
              "${vendor.yearOfExperience} years",
            ),
            _buildInfoTile(
              Icons.star,
              "Ratings",
              "${vendor.totalRatings} (${vendor.rate}/5)",
            ),
            // _buildInfoTile(
            //   Icons.home_repair_service,
            //   "Owner Email",
            //   userProfile.email,
            // ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: _showRatingBottomSheet,
            icon: const Icon(Icons.star, color: Colors.white),
            label: const CustomText("Rate Designer", color: Colors.white),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
