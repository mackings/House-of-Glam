/// The five staff roles on the admin side of the platform.
///
/// Each role has a strictly scoped set of permissions server-side; this enum
/// mirrors that so the client can make the same decisions (e.g. which roles
/// a given staff member is allowed to invite) without re-deriving them from
/// raw role strings scattered across the app.
enum AdminRole {
  superAdmin,
  admin,
  finance,
  customerService,
  listingManager,
  unknown;

  static AdminRole fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'superadmin':
        return AdminRole.superAdmin;
      case 'admin':
        return AdminRole.admin;
      case 'finance':
        return AdminRole.finance;
      case 'customerservice':
        return AdminRole.customerService;
      case 'listingmanager':
        return AdminRole.listingManager;
      default:
        return AdminRole.unknown;
    }
  }

  /// The exact casing the backend expects in API payloads (e.g. the invite
  /// `role` field), since the server treats role strings as case-sensitive.
  String get apiValue {
    switch (this) {
      case AdminRole.superAdmin:
        return 'superAdmin';
      case AdminRole.admin:
        return 'admin';
      case AdminRole.finance:
        return 'finance';
      case AdminRole.customerService:
        return 'customerService';
      case AdminRole.listingManager:
        return 'listingManager';
      case AdminRole.unknown:
        return '';
    }
  }

  String get label {
    switch (this) {
      case AdminRole.superAdmin:
        return 'Super Admin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.finance:
        return 'Finance';
      case AdminRole.customerService:
        return 'Customer Service';
      case AdminRole.listingManager:
        return 'Listing Manager';
      case AdminRole.unknown:
        return 'Team Member';
    }
  }

  /// Roles this role is permitted to invite, per the invite permission rules:
  /// - superAdmin can invite anyone, including other superAdmins.
  /// - admin can invite finance, customerService, and listingManager only.
  /// - finance, customerService, and listingManager cannot invite anyone.
  List<AdminRole> get invitableRoles {
    switch (this) {
      case AdminRole.superAdmin:
        return const [
          AdminRole.superAdmin,
          AdminRole.admin,
          AdminRole.finance,
          AdminRole.customerService,
          AdminRole.listingManager,
        ];
      case AdminRole.admin:
        return const [
          AdminRole.finance,
          AdminRole.customerService,
          AdminRole.listingManager,
        ];
      case AdminRole.finance:
      case AdminRole.customerService:
      case AdminRole.listingManager:
      case AdminRole.unknown:
        return const [];
    }
  }

  bool get canInviteTeamMembers => invitableRoles.isNotEmpty;
}
