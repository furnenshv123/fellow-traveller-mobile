import 'package:flutter/material.dart';

abstract final class ShellInsets {
  static const double bottomBarHeight = 84;

  static EdgeInsets contentPadding(BuildContext context) {
    final system = MediaQuery.paddingOf(context);
    return EdgeInsets.only(
      top: system.top,
      bottom: system.bottom + bottomBarHeight,
    );
  }

  static EdgeInsets listPadding(
    BuildContext context, {
    double horizontal = 16,
    double vertical = 16,
  }) {
    final shell = contentPadding(context);
    return EdgeInsets.fromLTRB(
      horizontal,
      vertical + shell.top,
      horizontal,
      vertical + shell.bottom,
    );
  }
}
