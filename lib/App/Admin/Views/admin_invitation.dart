import 'package:flutter/material.dart';
import 'package:hog/App/Admin/Api/admin_invitation_service.dart';
import 'package:hog/components/texts.dart';
import 'package:hog/theme/app_theme.dart';

typedef AdminInvitationSender =
    Future<AdminInvitationResult> Function({
      required String fullName,
      required String email,
      required String role,
      String? phoneNumber,
      String? country,
      String? address,
      List<String> responsibilities,
    });

class AdminInvitationPage extends StatefulWidget {
  final bool isSuperAdmin;
  final AdminInvitationSender invitationSender;

  const AdminInvitationPage({
    super.key,
    required this.isSuperAdmin,
    this.invitationSender = AdminInvitationService.sendInvitation,
  });

  @override
  State<AdminInvitationPage> createState() => _AdminInvitationPageState();
}

class _AdminInvitationPageState extends State<AdminInvitationPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController(text: 'Nigeria');
  final _address = TextEditingController();
  final List<TextEditingController> _responsibilities = [];
  String _role = 'admin';
  bool _sending = false;

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _country.dispose();
    _address.dispose();
    for (final controller in _responsibilities) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addResponsibility() {
    if (_responsibilities.length >= 10) return;
    setState(() => _responsibilities.add(TextEditingController()));
  }

  void _removeResponsibility(int index) {
    setState(() {
      _responsibilities.removeAt(index).dispose();
    });
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    final responsibilities =
        _responsibilities
            .map((controller) => controller.text.trim())
            .where((value) => value.isNotEmpty)
            .toList();
    final result = await widget.invitationSender(
      fullName: _fullName.text,
      email: _email.text,
      role: _role,
      phoneNumber: _phone.text,
      country: _country.text,
      address: _address.text,
      responsibilities: responsibilities,
    );
    if (!mounted) return;
    setState(() => _sending = false);

    if (result.success) {
      _showSuccess(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _showSuccess(AdminInvitationResult result) {
    final user =
        result.data['user'] is Map
            ? Map<String, dynamic>.from(result.data['user'] as Map)
            : const <String, dynamic>{};
    showDialog<void>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Invitation sent'),
            content: Text(
              '${user['fullName'] ?? _fullName.text} will receive temporary login credentials by email and must change the password after signing in.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context, true);
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Invite Administrator')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            _InvitationHero(isSuperAdmin: widget.isSuperAdmin),
            const SizedBox(height: 14),
            _FormPanel(
              title: 'Account details',
              children: [
                TextFormField(
                  key: const ValueKey('invite_full_name'),
                  controller: _fullName,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator:
                      (value) =>
                          (value ?? '').trim().isEmpty
                              ? 'Full name is required'
                              : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  key: const ValueKey('invite_email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  key: const ValueKey('invite_role'),
                  initialValue: _role,
                  isExpanded: true,
                  menuMaxHeight: 320,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: [
                    const DropdownMenuItem(
                      value: 'admin',
                      child: Text('Admin'),
                    ),
                    if (widget.isSuperAdmin)
                      const DropdownMenuItem(
                        value: 'superAdmin',
                        child: Text('Super Admin'),
                      ),
                  ],
                  onChanged:
                      (value) => setState(() => _role = value ?? 'admin'),
                ),
                if (!widget.isSuperAdmin) ...[
                  const SizedBox(height: 8),
                  const CustomText(
                    'Only a Super Admin can invite another Super Admin.',
                    fontSize: 11,
                    color: AppColors.subtext,
                    textAlign: TextAlign.left,
                  ),
                ],
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone number (optional)',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _country,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(
                    labelText: 'Address (optional)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormPanel(
              title: 'Responsibilities',
              subtitle:
                  'Optional. Leave empty to use the backend defaults for this role.',
              children: [
                for (
                  var index = 0;
                  index < _responsibilities.length;
                  index++
                ) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('invite_responsibility_$index'),
                          controller: _responsibilities[index],
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Responsibility ${index + 1}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: 'Remove responsibility',
                        onPressed: () => _removeResponsibility(index),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                OutlinedButton.icon(
                  key: const ValueKey('add_invite_responsibility'),
                  onPressed:
                      _responsibilities.length >= 10
                          ? null
                          : _addResponsibility,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    _responsibilities.isEmpty
                        ? 'Add responsibility'
                        : 'Add another (${_responsibilities.length}/10)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('send_admin_invitation'),
              onPressed: _sending ? null : _send,
              icon:
                  _sending
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.send_rounded),
              label: Text(
                _sending ? 'Sending invitation...' : 'Send invitation',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
            const SizedBox(height: 10),
            const CustomText(
              'The temporary password is generated securely and delivered only by email.',
              fontSize: 11,
              color: AppColors.subtext,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvitationHero extends StatelessWidget {
  final bool isSuperAdmin;

  const _InvitationHero({required this.isSuperAdmin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEFF4FF), Colors.white],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.accentSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomText(
                  'Invite a privileged account',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5),
                CustomText(
                  isSuperAdmin
                      ? 'Invite an Admin or Super Admin. Credentials are delivered by email.'
                      : 'Invite an Admin. Credentials are delivered by email.',
                  fontSize: 12,
                  color: AppColors.subtext,
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _FormPanel({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            title,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.left,
          ),
          if ((subtitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            CustomText(
              subtitle!,
              fontSize: 11,
              color: AppColors.subtext,
              textAlign: TextAlign.left,
            ),
          ],
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

String? _validateEmail(String? value) {
  final email = (value ?? '').trim();
  if (email.isEmpty) return 'Email is required';
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  return valid ? null : 'Enter a valid email address';
}
