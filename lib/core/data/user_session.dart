import 'package:fellow_traveller_mobile/core/data/user_session_storage.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';

class UserSession {
  UserSession(this._storage);

  final UserSessionStorage _storage;

  UserRole _role = UserRole.passenger;
  String? _email;

  UserRole get role => _role;
  String? get email => _email;

  bool get isDriver => _role == UserRole.driver;
  bool get isPassenger => _role == UserRole.passenger;

  Future<void> load() async {
    final storedRole = await _storage.getRole();
    _role = UserRoleExtension.fromApiValue(storedRole);
    _email = await _storage.getEmail();
  }

  Future<void> setFromAuth(AuthResponse response, {String? fallbackRole}) async {
    final roleValue = response.currentRole ?? fallbackRole ?? 'passenger';
    _role = UserRoleExtension.fromApiValue(roleValue);
    _email = response.email;

    await _storage.saveRole(_role.name);
    if (_email != null) {
      await _storage.saveEmail(_email!);
    }
  }

  Future<void> clear() async {
    _role = UserRole.passenger;
    _email = null;
    await _storage.clear();
  }
}
