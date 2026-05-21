sealed class UserRole {
  const UserRole();
}

final class OwnerRole extends UserRole {
  const OwnerRole();
}

final class StaffRole extends UserRole {
  const StaffRole(this.permissions, {this.societyId});
  final Map<String, bool> permissions;
  final String? societyId;

  bool can(String perm) => permissions[perm] == true;
}

final class CustomerRole extends UserRole {
  const CustomerRole(this.customerId);
  final String customerId;
}

final class UnknownRole extends UserRole {
  const UnknownRole();
}

extension UserRoleName on UserRole {
  String get displayName => switch (this) {
        OwnerRole() => 'Owner',
        StaffRole() => 'Staff',
        CustomerRole() => 'Customer',
        UnknownRole() => 'Unknown',
      };
}
