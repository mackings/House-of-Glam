import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final userProfile = widget.userProfile;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: CustomText(
          "${vendor.businessName}",
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
            _buildInfoTile(Icons.email, "Business Email", vendor.businessEmail),
            _buildInfoTile(Icons.phone, "Business Phone", ""),

            //vendor.businessPhone
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
            _buildInfoTile(
              Icons.home_repair_service,
              "Owner Email",
              userProfile.email,
            ),
            // _buildInfoTile(
            //   Icons.person,
            //   "Owner Phone",
            //   userProfile.phoneNumber,
            // ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Hire request sent to ${widget.vendor.businessName}!",
                  ),
                ),
              );
            },
            icon: const Icon(Icons.design_services, color: Colors.white),
            label: const CustomText("Hire Designer", color: Colors.white),
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
