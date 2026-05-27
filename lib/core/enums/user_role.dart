enum UserRole { passenger, driver }

extension UserRoleExtension on UserRole {
  String get name => toString().split('.').last;

  static UserRole fromApiValue(String? value) {
    if (value == 'driver') {
      return UserRole.driver;
    }
    return UserRole.passenger;
  }
}
