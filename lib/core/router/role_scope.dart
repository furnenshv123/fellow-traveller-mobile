import 'package:fellow_traveller_mobile/core/data/user_session.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:flutter/material.dart';

class RoleScope extends StatefulWidget {
  const RoleScope({required Widget child, super.key})
      : _child = child,
        _builder = null;

  const RoleScope.builder({
    required Widget Function(UserRole role) builder,
    super.key,
  })  : _child = null,
        _builder = builder;

  final Widget? _child;
  final Widget Function(UserRole role)? _builder;

  @override
  State<RoleScope> createState() => _RoleScopeState();
}

class _RoleScopeState extends State<RoleScope> {
  static const Duration _duration = Duration(milliseconds: 550);

  late final UserSession _session = AppDependencies.instance.userSession;

  @override
  void initState() {
    super.initState();
    _session.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    setState(() {});
  }

  Widget _contentForRole(UserRole role) {
    final builder = widget._builder;
    return builder != null ? builder(role) : widget._child as Widget;
  }

  @override
  Widget build(BuildContext context) {
    final role = _session.role;

    return AnimatedSwitcher(
      duration: _duration,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: <Widget>[
            ...previousChildren,
            ?currentChild,
          ],
        );
      },
      transitionBuilder: (Widget child, Animation<double> animation) {
        final childRole = _roleFromChildKey(child.key);
        final begin = childRole == UserRole.driver
            ? const Offset(0.18, 0)
            : const Offset(-0.18, 0);

        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              curved,
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<UserRole>(role),
        child: _contentForRole(role),
      ),
    );
  }

  UserRole? _roleFromChildKey(Key? key) {
    if (key is ValueKey<UserRole>) {
      return key.value;
    }
    return null;
  }
}
