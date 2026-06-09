import 'package:fellow_traveller_mobile/core/data/user_session_storage.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';
import 'package:flutter/foundation.dart';

class UserSession extends ChangeNotifier {
  UserSession(this._storage);

  final UserSessionStorage _storage;

  UserRole _role = UserRole.passenger;
  String? _email;
  bool _needsProfileSetup = true;

  UserRole get role => _role;
  String? get email => _email;
  bool get needsProfileSetup => _needsProfileSetup;

  bool get isDriver => _role == UserRole.driver;
  bool get isPassenger => _role == UserRole.passenger;

  Future<void> load() async {
    final storedRole = await _storage.getRole();
    _role = UserRoleExtension.fromApiValue(storedRole);
    _email = await _storage.getEmail();
    _needsProfileSetup = await _storage.getProfileComplete() != true;
  }

  Future<void> setFromAuth(
    AuthResponse response, {
    String? fallbackRole,
  }) async {
    final roleValue = response.currentRole ?? fallbackRole ?? 'passenger';
    _role = UserRoleExtension.fromApiValue(roleValue);
    _email = response.email;
    setProfileSetupHintFromAuth(response);

    await _storage.saveRole(_role.name);
    if (_email != null) {
      await _storage.saveEmail(_email!);
    }
    notifyListeners();
  }

  void setProfileSetupHintFromAuth(AuthResponse response) {
    if (_role == UserRole.driver) {
      _needsProfileSetup = response.hasDriverProfile != true;
    } else {
      _needsProfileSetup = response.hasPassengerProfile != true;
    }
  }

  Future<void> setProfileComplete(bool complete) async {
    _needsProfileSetup = !complete;
    await _storage.saveProfileComplete(complete);
    notifyListeners();
  }

  Future<void> clear() async {
    _role = UserRole.passenger;
    _email = null;
    _needsProfileSetup = true;
    await _storage.clear();
    notifyListeners();
  }
}
