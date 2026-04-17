import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hog/App/Admin/Views/adminHome.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/onboarding.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/TailorApp/TailorMain.dart';
import 'package:hog/components/index.dart';
import 'package:hog/theme/app_theme.dart';

class AppEntryGate extends StatefulWidget {
  const AppEntryGate({super.key});

  @override
  State<AppEntryGate> createState() => _AppEntryGateState();
}

class _AppEntryGateState extends State<AppEntryGate> {
  late final Future<_EntryState> _entryState;

  @override
  void initState() {
    super.initState();
    _entryState = _resolveEntryState();
  }

  Future<_EntryState> _resolveEntryState() async {
    try {
      final onboardingSeen = await SecurePrefs.getOnboardingSeen();
      final token = await SecurePrefs.getToken();
      final userData = await SecurePrefs.getUserData();
      final lastEmail = await SecurePrefs.getLastEmail();

      if (!onboardingSeen) {
        return _EntryState.onboarding(lastEmail: lastEmail);
      }

      if (token != null && token.isNotEmpty && userData != null) {
        final role = (userData['role'] ?? '').toString().toLowerCase();
        final isVendorEnabled = userData['isVendorEnabled'] == true;

        if (role == 'tailor') {
          return _EntryState.home(
            screen: TailorMainPage(isVendorEnabled: isVendorEnabled),
          );
        }

        if (role == 'admin' || role == 'superadmin') {
          return _EntryState.home(screen: const AdminHome());
        }

        return _EntryState.home(screen: const MainPage());
      }

      return _EntryState.signin(lastEmail: lastEmail);
    } catch (_) {
      return _EntryState.signin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EntryState>(
      future: _entryState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Signin();
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const _LaunchSplash();
        }

        final state = snapshot.data;
        if (state == null) {
          return const Signin();
        }

        switch (state.type) {
          case _EntryType.onboarding:
            return OnboardingScreen(initialEmail: state.lastEmail);
          case _EntryType.signin:
            return Signin(initialEmail: state.lastEmail);
          case _EntryType.home:
            return state.screen ?? const MainPage();
        }
      },
    );
  }
}

enum _EntryType { onboarding, signin, home }

class _EntryState {
  final _EntryType type;
  final Widget? screen;
  final String? lastEmail;

  const _EntryState._({required this.type, this.screen, this.lastEmail});

  factory _EntryState.onboarding({String? lastEmail}) {
    return _EntryState._(type: _EntryType.onboarding, lastEmail: lastEmail);
  }

  factory _EntryState.signin({String? lastEmail}) {
    return _EntryState._(type: _EntryType.signin, lastEmail: lastEmail);
  }

  factory _EntryState.home({required Widget screen}) {
    return _EntryState._(type: _EntryType.home, screen: screen);
  }
}

class _LaunchSplash extends StatelessWidget {
  const _LaunchSplash();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            right: -40,
            child: _LaunchAura(
              size: 300,
              color: AppColors.secondary.withValues(alpha: 0.18),
            ),
          ),
          Positioned(
            left: -60,
            bottom: 40,
            child: _LaunchAura(
              size: 240,
              color: AppColors.accent.withValues(alpha: 0.18),
            ),
          ),
          Center(
            child: Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 34),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFFCF6), Colors.white, Color(0xFFF5F1E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(34),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 28,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.secondary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'House of GLAME',
                    style: GoogleFonts.cormorantGaramond(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Where Culture Meets Couture',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.subtext,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const CircularProgressIndicator(color: AppColors.accent),
                  const SizedBox(height: 18),
                  Text(
                    'Authentically African • Globally Styled',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.subtext,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LaunchAura extends StatelessWidget {
  final double size;
  final Color color;

  const _LaunchAura({required this.size, required this.color});

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
