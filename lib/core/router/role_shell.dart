import 'package:fellow_traveller_mobile/core/data/user_session.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:flutter/material.dart';

/// Picks passenger or driver widget based on persisted session role.
class RoleShell extends StatelessWidget {
  const RoleShell({
    required this.passenger,
    required this.driver,
    super.key,
  });

  final Widget passenger;
  final Widget driver;

  UserSession get _session => AppDependencies.instance.userSession;

  @override
  Widget build(BuildContext context) {
    if (_session.role == UserRole.driver) {
      return driver;
    }
    return passenger;
  }
}
