import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/router/role_scope.dart';
import 'package:flutter/material.dart';

class RoleShell extends StatelessWidget {
  const RoleShell({
    required this.passenger,
    required this.driver,
    super.key,
  });

  final Widget passenger;
  final Widget driver;

  @override
  Widget build(BuildContext context) {
    return RoleScope.builder(
      builder: (UserRole role) =>
          role == UserRole.driver ? driver : passenger,
    );
  }
}
