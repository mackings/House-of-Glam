import 'package:flutter/material.dart';
import 'package:hog/App/Auth/Api/secure.dart';
import 'package:hog/App/Auth/Views/signin.dart';
import 'package:hog/constants/navcontroller.dart';
import 'package:hog/theme/app_theme.dart';

class SessionExpiryHandler {
  static bool _isHandling = false;
  static bool _isSigningOut = false;

  static bool isSessionExpiredResponse({
    int? statusCode,
    String? responseBody,
    String? message,
  }) {
    final normalizedBody = responseBody?.toLowerCase() ?? '';
    final normalizedMessage = message?.toLowerCase() ?? '';

    if (statusCode == 401) {
      return true;
    }

    const expiredSignals = [
      'token has expired',
      'token expired',
      'invalid token',
      'jwt expired',
      'session expired',
    ];

    return expiredSignals.any(
      (signal) =>
          normalizedBody.contains(signal) || normalizedMessage.contains(signal),
    );
  }

  static Future<bool> handleIfExpired({
    int? statusCode,
    String? responseBody,
    String? message,
  }) async {
    if (!isSessionExpiredResponse(
      statusCode: statusCode,
      responseBody: responseBody,
      message: message,
    )) {
      return false;
    }

    await handleExpiredSession();
    return true;
  }

  static Future<void> handleExpiredSession() async {
    if (_isHandling) {
      return;
    }

    _isHandling = true;

    final navigator = NavigationController.navigatorKey.currentState;
    final overlayContext = navigator?.overlay?.context;

    if (navigator == null || overlayContext == null) {
      await _signOutAndNavigate();
      _isHandling = false;
      return;
    }

    try {
      await showModalBottomSheet<void>(
        context: overlayContext,
        useRootNavigator: true,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.accentSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.lock_clock_outlined,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'You\'ve been signed out',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'For security, you\'ve been signed out. Please sign in to continue.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.subtext,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSigningOut ? null : _signOutAndNavigate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Sign in'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } finally {
      _isHandling = false;
    }
  }

  static Future<void> _signOutAndNavigate() async {
    if (_isSigningOut) {
      return;
    }

    _isSigningOut = true;

    try {
      await SecurePrefs.clearAll();

      final navigator = NavigationController.navigatorKey.currentState;
      if (navigator == null) {
        return;
      }

      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const Signin()),
        (route) => false,
      );
    } finally {
      _isSigningOut = false;
    }
  }
}
