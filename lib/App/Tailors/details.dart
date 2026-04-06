import 'package:flutter/material.dart';
import 'package:hog/App/Home/Api/home.dart';
import 'package:hog/App/Home/Model/vendor.dart';
import 'package:hog/components/button.dart';
import 'package:hog/components/customAppbar.dart';
import 'package:hog/theme/app_theme.dart';

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

  void _showRatingBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildRatingSheet(),
    );
  }

  Widget _buildRatingSheet() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Rate ${widget.vendor.businessName}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "How was your experience with this designer?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.subtext),
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _selectedRating = index + 1;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        index < _selectedRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 38,
                        color: index < _selectedRating
                            ? Colors.amber
                            : AppColors.border,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                title: "Rate Designer",
                onPressed:
                    _selectedRating == 0 || _isSubmittingRating
                        ? null
                        : () => _submitRating(setModalState),
                isLoading: _isSubmittingRating,
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: AppColors.subtext),
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

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Thanks for rating ${widget.vendor.businessName}!"),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to submit rating. Please try again."),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = widget.vendor;
    final userProfile = widget.userProfile;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: CustomAppBar(
        title: vendor.businessName,
        enableAction: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  userProfile.image.isNotEmpty
                      ? CircleAvatar(
                          radius: 46,
                          backgroundImage: NetworkImage(userProfile.image),
                        )
                      : CircleAvatar(
                          radius: 46,
                          backgroundColor: AppColors.accentSoft,
                          child: Text(
                            userProfile.fullName.isNotEmpty
                                ? userProfile.fullName[0].toUpperCase()
                                : "?",
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                  const SizedBox(height: 14),
                  Text(
                    userProfile.fullName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    vendor.description.isEmpty
                        ? "No description provided yet."
                        : vendor.description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.subtext,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.star_rounded,
                        label: "${vendor.totalRatings} reviews",
                      ),
                      _StatChip(
                        icon: Icons.workspace_premium_outlined,
                        label: "${vendor.rate}/5 rating",
                      ),
                      _StatChip(
                        icon: Icons.work_outline_rounded,
                        label: "${vendor.yearOfExperience} yrs",
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoSection(
              title: "Business Information",
              children: [
                _InfoTile(
                  icon: Icons.location_on_outlined,
                  title: "Business Address",
                  subtitle: vendor.address,
                ),
                _InfoTile(
                  icon: Icons.location_city_outlined,
                  title: "City",
                  subtitle: vendor.city,
                ),
                _InfoTile(
                  icon: Icons.map_outlined,
                  title: "State",
                  subtitle: vendor.state,
                ),
                _InfoTile(
                  icon: Icons.call_outlined,
                  title: "Business Phone",
                  subtitle: vendor.businessPhone,
                ),
                _InfoTile(
                  icon: Icons.mail_outline_rounded,
                  title: "Business Email",
                  subtitle: vendor.businessEmail,
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoSection(
              title: "Profile",
              children: [
                _InfoTile(
                  icon: Icons.person_outline_rounded,
                  title: "Full Name",
                  subtitle: userProfile.fullName,
                ),
                _InfoTile(
                  icon: Icons.phone_outlined,
                  title: "Phone Number",
                  subtitle: userProfile.phoneNumber,
                ),
                _InfoTile(
                  icon: Icons.home_outlined,
                  title: "Address",
                  subtitle: userProfile.address,
                ),
                _InfoTile(
                  icon: Icons.alternate_email_rounded,
                  title: "Email",
                  subtitle: userProfile.email,
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
        child: CustomButton(
          title: "Rate Designer",
          onPressed: _showRatingBottomSheet,
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.subtext,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle.isEmpty ? "Not provided" : subtitle,
                    style: const TextStyle(fontSize: 14, height: 1.45),
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

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.accent),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
