import 'dart:async';

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
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<_OnboardingItem> _items = const [
    _OnboardingItem(
      tag: 'Where Culture Meets Couture',
      heading: 'Wear African fashion with confidence',
      body:
          'Curated custom-made, ready-to-wear, and pre-loved pieces from Africa’s finest designers.',
      highlight:
          'Luxury fashion. Trusted designers. Effortless from start to finish.',
      buttonLabel: 'Explore Collections',
      icon: Icons.diamond_outlined,
      accent: AppColors.secondary,
      features: ['Custom-Made', 'Ready-to-Wear', 'Pre-Loved'],
    ),
    _OnboardingItem(
      tag: 'Designed Around Your Vision',
      heading: 'Turn your vision into a perfect fit',
      body:
          'Share your ideas, compare refined quotes, and create with confidence.',
      highlight: 'From vision to masterpiece - simple, transparent, refined.',
      buttonLabel: 'Start Your Design',
      icon: Icons.draw_outlined,
      accent: AppColors.accent,
      features: ['Perfect Fit', 'Smart Quotes', 'Final Approval'],
    ),
    _OnboardingItem(
      tag: 'Luxury That Travels Well',
      heading: 'Track your style, every step of the way.',
      body:
          'Follow your order from design approval to delivery with clear, real-time updates - locally and globally.',
      highlight: 'Crafted with care. Delivered with confidence.',
      buttonLabel: 'Track Your Order',
      icon: Icons.local_shipping_outlined,
      accent: AppColors.secondaryDeep,
      features: ['Design', 'Tracking', 'Delivery'],
    ),
    _OnboardingItem(
      tag: 'Built for a Global Community',
      heading: 'Where African fashion meets the world.',
      body:
          'From Nigeria to the diaspora, discover designers, explore styles, and connect with a global community of fashion lovers.',
      highlight: 'Connecting culture, creativity, and global style.',
      buttonLabel: 'Get Started',
      icon: Icons.public_rounded,
      accent: AppColors.accentDeep,
      features: ['Designers', 'Styles', 'Global Reach'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _completeOnboarding() async {
    _autoScrollTimer?.cancel();
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
    final screenHeight = MediaQuery.sizeOf(context).height;
    final compactScreen = screenHeight < 820;
    final veryCompactScreen = screenHeight < 720;

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
              padding: EdgeInsets.fromLTRB(
                20,
                compactScreen ? 12 : 16,
                20,
                veryCompactScreen ? 18 : 24,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'House of GLAME',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: compactScreen ? 17 : 18,
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
                            fontSize: compactScreen ? 13 : 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.subtext,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage == 0) ...[
                    SizedBox(height: veryCompactScreen ? 8 : 10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: veryCompactScreen ? 10 : 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFCF6),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🌍 Join a global network of African fashion designers.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: compactScreen ? 13 : 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Connect with customers locally and internationally.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: compactScreen ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.subtext,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: veryCompactScreen ? 8 : 12),
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
                  SizedBox(height: veryCompactScreen ? 12 : 18),
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
                  SizedBox(height: veryCompactScreen ? 12 : 18),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(veryCompactScreen ? 14 : 18),
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
                          height: veryCompactScreen ? 50 : 54,
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
                                fontSize: veryCompactScreen ? 14 : 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: veryCompactScreen ? 8 : 12),
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
                              fontSize: veryCompactScreen ? 13 : 14,
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
        final compact = constraints.maxHeight < 720;
        final veryCompact = constraints.maxHeight < 620;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: EdgeInsets.all(
                veryCompact
                    ? 18
                    : compact
                    ? 22
                    : 28,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(compact ? 30 : 34),
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
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width:
                        veryCompact
                            ? 60
                            : compact
                            ? 70
                            : 88,
                    height:
                        veryCompact
                            ? 60
                            : compact
                            ? 70
                            : 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        veryCompact ? 20 : 28,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          item.accent.withValues(alpha: 0.18),
                          item.accent.withValues(alpha: 0.06),
                        ],
                      ),
                      border: Border.all(
                        color: item.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.accent,
                      size:
                          veryCompact
                              ? 28
                              : compact
                              ? 32
                              : 40,
                    ),
                  ),
                  SizedBox(
                    height:
                        veryCompact
                            ? 12
                            : compact
                            ? 16
                            : 22,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: veryCompact ? 10 : 12,
                      vertical: veryCompact ? 6 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      item.tag,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: veryCompact ? 10 : 12,
                        fontWeight: FontWeight.w800,
                        color: item.accent,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  SizedBox(
                    height:
                        veryCompact
                            ? 14
                            : compact
                            ? 18
                            : 22,
                  ),
                  Text(
                    item.heading,
                    style: GoogleFonts.cormorantGaramond(
                      fontSize:
                          veryCompact
                              ? 29
                              : compact
                              ? 36
                              : 46,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 0.96,
                    ),
                  ),
                  SizedBox(height: veryCompact ? 8 : 12),
                  Text(
                    item.body,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize:
                          veryCompact
                              ? 12.5
                              : compact
                              ? 13.5
                              : 15,
                      fontWeight: FontWeight.w500,
                      height: veryCompact ? 1.5 : 1.65,
                      color: AppColors.subtext,
                    ),
                  ),
                  SizedBox(
                    height:
                        veryCompact
                            ? 12
                            : compact
                            ? 16
                            : 20,
                  ),
                  Wrap(
                    spacing: veryCompact ? 8 : 10,
                    runSpacing: veryCompact ? 8 : 10,
                    children:
                        item.features
                            .map(
                              (feature) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: veryCompact ? 10 : 12,
                                  vertical: veryCompact ? 6 : 8,
                                ),
                                decoration: BoxDecoration(
                                  color: item.accent.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  feature,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: veryCompact ? 10 : 11,
                                    fontWeight: FontWeight.w700,
                                    color: item.accent,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(
                    height:
                        veryCompact
                            ? 14
                            : compact
                            ? 18
                            : 24,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      veryCompact
                          ? 12
                          : compact
                          ? 14
                          : 18,
                    ),
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
                            fontSize:
                                veryCompact
                                    ? 16
                                    : compact
                                    ? 18
                                    : 20,
                            color: item.accent,
                          ),
                        ),
                        SizedBox(width: veryCompact ? 8 : 10),
                        Expanded(
                          child: Text(
                            item.highlight,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: veryCompact ? 11.5 : 13,
                              fontWeight: FontWeight.w700,
                              height: veryCompact ? 1.35 : 1.45,
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
