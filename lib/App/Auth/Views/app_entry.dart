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
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EntryState>(
      future: _entryState,
      builder: (context, snapshot) {
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

  const _EntryState._({
    required this.type,
    this.screen,
    this.lastEmail,
  });

  factory _EntryState.onboarding({String? lastEmail}) {
    return _EntryState._(
      type: _EntryType.onboarding,
      lastEmail: lastEmail,
    );
  }

  factory _EntryState.signin({String? lastEmail}) {
    return _EntryState._(
      type: _EntryType.signin,
      lastEmail: lastEmail,
    );
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
      body: Center(
        child: Container(
          width: 240,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF7F1FF), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.accent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'House of Glam',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Preparing your workspace...',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subtext,
                ),
              ),
              const SizedBox(height: 18),
              const CircularProgressIndicator(color: AppColors.accent),
            ],
          ),
        ),
      ),
    );
  }
}
