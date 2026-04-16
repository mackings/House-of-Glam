import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/app_entry.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/components/Navigator.dart';
import 'package:hog/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  final String? initialEmail;

  const OnboardingScreen({super.key, this.initialEmail});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      title: 'Designers and users, in one polished flow',
      description:
          'Move smoothly between discovery, tailoring, and customer orders with clearer journeys for both sides.',
      icon: Icons.checkroom_rounded,
      accent: AppColors.accent,
      highlight: 'Built for both buyers and designers',
    ),
    _OnboardingItem(
      title: 'Style conversations that work across the world',
      description:
          'Coordinate orders, reviews, and marketplace activity whether your customers are local or international.',
      icon: Icons.public_rounded,
      accent: AppColors.warning,
      highlight: 'Support for a global audience',
    ),
    _OnboardingItem(
      title: 'Seamless negotiations from quote to agreement',
      description:
          'Keep pricing conversations structured, track changes clearly, and close decisions with less friction.',
      icon: Icons.handshake_rounded,
      accent: AppColors.accentDeep,
      highlight: 'Cleaner offer and counter-offer flow',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await SecurePrefs.saveOnboardingSeen(true);
    if (!mounted) return;
    Nav.pushReplacementAll(context, AppEntryGate());
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentPage];
    final isLastPage = _currentPage == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'House of Glam',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Skip',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.subtext,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemBuilder: (context, index) {
                    final page = _items[index];
                    return _OnboardingCard(item: page);
                  },
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _items.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? item.accent
                              : AppColors.border,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isLastPage) {
                            await _completeOnboarding();
                            return;
                          }
                          await _pageController.nextPage(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.accent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isLastPage ? 'Start Exploring' : 'Continue',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Nav.pushReplacementAll(
                          context,
                          Signin(initialEmail: widget.initialEmail),
                        );
                      },
                      child: Text(
                        'I already have an account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingItem item;

  const _OnboardingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;
        final titleSize = compact ? 22.0 : 26.0;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(compact ? 20 : 26),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [item.accent.withValues(alpha: 0.12), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: compact ? 64 : 74,
                  height: compact ? 64 : 74,
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.accent,
                    size: compact ? 32 : 36,
                  ),
                ),
                SizedBox(height: compact ? 16 : 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    item.highlight,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: item.accent,
                    ),
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),
                Text(
                  item.title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  item.description,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: compact ? 14 : 15,
                    height: 1.6,
                    color: AppColors.subtext,
                  ),
                ),
                SizedBox(height: compact ? 18 : 24),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(compact ? 14 : 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.bolt_rounded, color: item.accent, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Cleaner journeys, better account continuity, and a more intentional marketplace experience.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accent;
  final String highlight;

  const _OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
    required this.highlight,
  });
}
