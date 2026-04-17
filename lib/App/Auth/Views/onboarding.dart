import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/auth_choice.dart';
import 'package:hog/App/Auth/Views/signin.dart';
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
      tag: 'Where Culture Meets Couture',
      heading: 'Shop African fashion with confidence',
      body:
          'Discover custom-made, ready-to-wear, and pre-loved styles from skilled designers across Africa and beyond.',
      highlight: 'Elegant fashion. Trusted creators. Seamless experience.',
      buttonLabel: 'Start Exploring',
      icon: Icons.diamond_outlined,
      accent: AppColors.secondary,
      features: ['Custom-Made', 'Ready-to-Wear', 'Pre-Loved'],
    ),
    _OnboardingItem(
      tag: 'Tailored Around Your Vision',
      heading: 'Request quotes with clarity and confidence',
      body:
          'Share your inspiration, measurements, and finishing details, then compare refined quotations before you commit.',
      highlight: 'Clear quote flow. Transparent pricing. Beautiful outcomes.',
      buttonLabel: 'Explore Quote Flow',
      icon: Icons.draw_outlined,
      accent: AppColors.accent,
      features: ['Measurements', 'Quote Flow', 'Approvals'],
    ),
    _OnboardingItem(
      tag: 'Luxury That Travels Well',
      heading: 'Follow every order from approval to delivery',
      body:
          'Track each piece through production, shipping, and arrival with polished updates for local and international delivery.',
      highlight: 'Smooth delivery updates. Premium care. Peace of mind.',
      buttonLabel: 'See Delivery Flow',
      icon: Icons.local_shipping_outlined,
      accent: AppColors.secondaryDeep,
      features: ['Production', 'Tracking', 'Delivery'],
    ),
    _OnboardingItem(
      tag: 'Built for a Global Community',
      heading: 'One platform for designers and fashion lovers',
      body:
          'From Nigeria to the diaspora, House of GLAME connects creativity, culture, and commerce in one refined marketplace.',
      highlight: 'Designed for discovery, growth, and global African fashion.',
      buttonLabel: 'Choose Your Experience',
      icon: Icons.public_rounded,
      accent: AppColors.accentDeep,
      features: ['Designers', 'Discovery', 'Global Style'],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await SecurePrefs.saveOnboardingSeen(true);
    if (!mounted) {
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AuthChoiceScreen(showBackButton: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentPage];
    final isLastPage = _currentPage == _items.length - 1;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -20,
              child: _Aura(
                size: 280,
                color: AppColors.secondary.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              left: -70,
              top: 80,
              child: _Aura(
                size: 220,
                color: AppColors.accent.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -90,
              right: 10,
              child: _Aura(
                size: 240,
                color: AppColors.accentDeep.withValues(alpha: 0.12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'House of GLAME',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.subtext,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        return _OnboardingCard(item: _items[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 30 : 8,
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
                      color: const Color(0xFFFFFCF6),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 24,
                          offset: Offset(0, 14),
                        ),
                      ],
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
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: item.accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Text(
                              item.buttonLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => Signin(
                                      initialEmail: widget.initialEmail,
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            'I already have an account',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
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
          ],
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
        final compact = constraints.maxHeight < 680;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: EdgeInsets.all(compact ? 22 : 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                item.accent.withValues(alpha: 0.08),
                const Color(0xFFFFFCF6),
              ],
            ),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 26,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: compact ? 74 : 88,
                height: compact ? 74 : 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      item.accent.withValues(alpha: 0.18),
                      item.accent.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(color: item.accent.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  item.icon,
                  color: item.accent,
                  size: compact ? 34 : 40,
                ),
              ),
              SizedBox(height: compact ? 18 : 22),
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
                  item.tag,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: item.accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              SizedBox(height: compact ? 18 : 22),
              Text(
                item.heading,
                style: GoogleFonts.cormorantGaramond(
                  fontSize: compact ? 38 : 46,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 0.98,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.body,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: compact ? 14 : 15,
                  fontWeight: FontWeight.w500,
                  height: 1.65,
                  color: AppColors.subtext,
                ),
              ),
              SizedBox(height: compact ? 16 : 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    item.features
                        .map(
                          (feature) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: item.accent.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              feature,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: item.accent,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(compact ? 16 : 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFCF6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: item.accent.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✦',
                      style: TextStyle(
                        fontSize: compact ? 18 : 20,
                        color: item.accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.highlight,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
        );
      },
    );
  }
}

class _Aura extends StatelessWidget {
  final double size;
  final Color color;

  const _Aura({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }
}

class _OnboardingItem {
  final String tag;
  final String heading;
  final String body;
  final String highlight;
  final String buttonLabel;
  final IconData icon;
  final Color accent;
  final List<String> features;

  const _OnboardingItem({
    required this.tag,
    required this.heading,
    required this.body,
    required this.highlight,
    required this.buttonLabel,
    required this.icon,
    required this.accent,
    required this.features,
  });
}
