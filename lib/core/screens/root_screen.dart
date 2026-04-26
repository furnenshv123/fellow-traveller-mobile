import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({required this.currentPath, required this.child, super.key});

  final String currentPath;
  final Widget child;

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _currentIndexFromPath(String path) {
    if (path.startsWith(AppRoutesEnum.driverMain.path)) {
      return 1;
    }
    return 0;
  }

  void _onItemTap(int index) {
    final String targetPath = index == 0
        ? AppRoutesEnum.passengerMain.path
        : AppRoutesEnum.driverMain.path;
    if (widget.currentPath != targetPath) {
      context.go(targetPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _currentIndexFromPath(widget.currentPath);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onItemTap,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Passenger',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_filled_rounded),
            label: 'Driver',
          ),
        ],
      ),
    );
  }
}
