import 'package:flutter/material.dart';
import 'package:hog/theme/app_theme.dart';

class PasswordRequirements extends StatelessWidget {
  final String password;
  final String? confirmPassword;

  const PasswordRequirements({
    super.key,
    required this.password,
    this.confirmPassword,
  });

  bool get _hasMinLength => password.length >= 8;
  bool get _hasUppercase => RegExp(r'[A-Z]').hasMatch(password);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(password);
  bool get _hasSpecialCharacter =>
      RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password);
  bool get _passwordsMatch =>
      confirmPassword == null ||
      (confirmPassword!.isNotEmpty && confirmPassword == password);

  @override
  Widget build(BuildContext context) {
    final requirements = [
      _PasswordRequirement(
        met: _hasMinLength,
        unmetText: 'Add at least 8 characters',
        metText: '8 characters added',
      ),
      _PasswordRequirement(
        met: _hasUppercase,
        unmetText: 'Add an uppercase letter',
        metText: 'Uppercase letter added',
      ),
      _PasswordRequirement(
        met: _hasNumber,
        unmetText: 'Add a number',
        metText: 'Number added',
      ),
      _PasswordRequirement(
        met: _hasSpecialCharacter,
        unmetText: 'Add a special character or symbol',
        metText: 'Special character added',
      ),
      if (confirmPassword != null)
        _PasswordRequirement(
          met: _passwordsMatch,
          unmetText: 'Confirm password must match',
          metText: 'Passwords match',
        ),
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 2, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password checklist',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ...requirements.map((requirement) {
            final color =
                requirement.met ? AppColors.success : AppColors.subtext;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    requirement.met
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      requirement.met
                          ? requirement.metText
                          : requirement.unmetText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight:
                            requirement.met ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PasswordRequirement {
  final bool met;
  final String unmetText;
  final String metText;

  const _PasswordRequirement({
    required this.met,
    required this.unmetText,
    required this.metText,
  });
}
