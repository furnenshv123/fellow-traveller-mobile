import 'package:fellow_traveller_mobile/core/utils/colors/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final StatefulNavigationShell child;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late String _currentPath;

  @override
  void initState() {
    super.initState();
    _currentPath = widget.currentPath;
  }

  void onItemTapped(int index) {
    String newPath = _getPathFromIndex(index);
    if (_currentPath != newPath) {
      _currentPath = newPath;
      widget.child.goBranch(index);
    }
  }

  String _getPathFromIndex(int index) {
    switch (index) {
      case 0:
        return AppRoutesEnum.main.path;
      case 1:
        return AppRoutesEnum.rides.path;
      case 2:
        return AppRoutesEnum.profile.path;

      default:
        return AppRoutesEnum.main.path;
    }
  }

  int _currentIndexFromPath(String path) {
    if (path.startsWith(AppRoutesEnum.main.path)) {
      return 0;
    } else if (path.startsWith(AppRoutesEnum.rides.path)) {
      return 1;
    } else if (path.startsWith(AppRoutesEnum.profile.path)) {
      return 2;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: GlassBottomBar(
        selectedIconColor: AppColors.primary,
        unselectedIconColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryLight.withValues(alpha: 0.85),
        glassSettings: LiquidGlassSettings(
          blur: 20,
          thickness: 20,
          glassColor: AppColors.surface.withValues(alpha: 0.72),
          lightIntensity: 0.6,
          ambientStrength: 0.45,
          saturation: 1.1,
        ),
        tabs: const <GlassBottomBarTab>[
          GlassBottomBarTab(
            icon: Icon(CupertinoIcons.home),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Главная',
          ),
          GlassBottomBarTab(
            icon: Icon(Icons.drive_eta_outlined),
            activeIcon: Icon(Icons.drive_eta),
            label: 'Мои поездки',
          ),
          GlassBottomBarTab(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Профиль',
          ),
        ],
        selectedIndex: _currentIndexFromPath(widget.currentPath),
        onTabSelected: onItemTapped,
      ),
    );
  }
}
