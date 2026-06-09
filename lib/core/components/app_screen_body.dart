import 'package:fellow_traveller_mobile/core/components/shell_insets.dart';
import 'package:flutter/material.dart';

class AppScreenBody extends StatelessWidget {
  const AppScreenBody({
    required this.child,
    this.withBottomNav = false,
    this.includeTopInset = true,
    super.key,
  });

  final Widget child;
  final bool withBottomNav;
  final bool includeTopInset;

  @override
  Widget build(BuildContext context) {
    final system = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.only(
        top: includeTopInset ? system.top : 0,
        bottom: (withBottomNav ? ShellInsets.bottomBarHeight : 0),
      ),
      child: child,
    );
  }
}
