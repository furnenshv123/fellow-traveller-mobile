import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'light_theme.dart';
import 'theme_implementation.dart';

class CustomTheme extends InheritedWidget {
  final CustomThemeState state = CustomThemeState();

  ThemeImplementation get theme => state.theme;

  CustomTheme({Key? key, child}) : super(key: key, child: child) {
    changeTheme();
    WidgetsBinding.instance.window.onPlatformBrightnessChanged = () {
      changeTheme();
    };
  }

  static CustomTheme of(BuildContext context) {
    var result = context.dependOnInheritedWidgetOfExactType<CustomTheme>();
    if (result == null) {
      throw Exception('custom theme is null');
    } else {
      return result;
    }
  }

  double platformLetterSpacing() {
    double letterSpacing = 0;
    if (Platform.isIOS) {
      letterSpacing = -0.43;
    } else if (Platform.isMacOS) {
      letterSpacing = -0.175;
    } else if (Platform.isWindows) {
      letterSpacing = 0.175;
    }
    return letterSpacing;
  }

  TextStyle mainTextStyle({double? fontSize, Color? textColor}) {
    double lineHeight = 1.21;
    if (Platform.isIOS) {
      lineHeight = 1.29;
    } else if (Platform.isAndroid) {
      lineHeight = 1.125;
    } else if (Platform.isMacOS) {
      lineHeight = 1.21;
    } else if (Platform.isWindows) {
      lineHeight = 1.234;
    }

    double platformFontSize = 14;
    if (Platform.isIOS) {
      platformFontSize = 17;
    } else if (Platform.isAndroid) {
      platformFontSize = 16;
    } else if (Platform.isWindows) {
      platformFontSize = 15;
    }

    return TextStyle(
      height: lineHeight,
      color: textColor ?? const Color(0xff262A2f),
      letterSpacing: platformLetterSpacing(),
      fontSize: fontSize ?? platformFontSize,
    );
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }

  void changeTheme() {
    bool isDarkTheme;
    Brightness? sysBrightness =
        WidgetsBinding.instance.window.platformBrightness;
    isDarkTheme = sysBrightness == Brightness.dark;
    if (isDarkTheme) {
      state.theme = LightTheme();
    } else {
      state.theme = LightTheme();
    }
    state.isDarkTheme = isDarkTheme;
  }

  static void setupMobileUi({Color statusBarColor = Colors.transparent}) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      CustomTheme.darkStatusBarIcons(statusBarColor: statusBarColor),
    );
  }

  static SystemUiOverlayStyle darkStatusBarIcons({
    Color statusBarColor = Colors.transparent,
  }) => SystemUiOverlayStyle(
    statusBarColor: statusBarColor,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
  );

  static SystemUiOverlayStyle lightStatusBarIcons() =>
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
      );
}

class CustomThemeState {
  late ThemeImplementation theme;
  late bool isDarkTheme;
}
