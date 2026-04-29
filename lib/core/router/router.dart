import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/auth/presentation/screens/auth_screen.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/screens/my_drives_screen.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/screens/profile_screen.dart';
import 'package:fellow_traveller_mobile/core/screens/main_screen.dart';
import 'package:fellow_traveller_mobile/core/screens/root_screen.dart';
import 'package:fellow_traveller_mobile/core/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  redirect: (context, state) => null,
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutesEnum.splash.path,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutesEnum.splash.path,
      name: AppRoutesEnum.splash.name,
      builder: (context, state) {
        return SplashScreen();
      },
    ),
    GoRoute(
      path: AppRoutesEnum.auth.path,
      name: AppRoutesEnum.auth.name,
      builder: (context, state) {
        return AuthScreen();
      },
    ),
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return RootScreen(currentPath: state.uri.path, child: child);
      },
      routes: <RouteBase>[
        GoRoute(
          path: AppRoutesEnum.main.path,
          name: AppRoutesEnum.main.name,
          builder: (BuildContext context, GoRouterState state) {
            return const MainScreen(initialRole: MainScreenRole.passenger);
          },
        ),
        GoRoute(
          path: AppRoutesEnum.rides.path,
          name: AppRoutesEnum.rides.name,
          builder: (BuildContext context, GoRouterState state) {
            return const DriverMyRidesScreen();
          },
        ),
        GoRoute(
          path: AppRoutesEnum.profile.path,
          name: AppRoutesEnum.profile.name,
          builder: (BuildContext context, GoRouterState state) {
            return const DriverProfileScreen();
          },
        ),
      ],
    ),
  ],
);

class NoTransitionsBuilder extends PageTransitionsBuilder {
  const NoTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext? context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget? child,
  ) {
    return child!;
  }
}

extension GoRouterExtension on GoRouter {
  void clearStackAndNavigate(String location) {
    while (canPop()) {
      pop();
    }
    pushReplacement(location);
  }
}
