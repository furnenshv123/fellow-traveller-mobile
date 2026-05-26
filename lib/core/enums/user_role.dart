enum UserRole { passenger, driver }

extension UserRoleExtension on UserRole {
  String get name => toString().split('.').last;
}
