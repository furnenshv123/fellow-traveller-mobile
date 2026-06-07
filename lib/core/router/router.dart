import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/app_routes.dart';
import 'package:fellow_traveller_mobile/core/features/auth/presentation/screens/auth_screen.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/screens/my_drives_screen.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/screens/profile_screen.dart';
import 'package:fellow_traveller_mobile/core/features/passenger/presentation/screens/my_drives_screen.dart';
import 'package:fellow_traveller_mobile/core/features/passenger/presentation/screens/profile_screen.dart';
import 'package:fellow_traveller_mobile/core/features/profile/presentation/screens/create_profile_screen.dart';
import 'package:fellow_traveller_mobile/core/features/profile/presentation/screens/user_driver_profile_screen.dart';
import 'package:fellow_traveller_mobile/core/features/profile/presentation/screens/user_passenger_profile_screen.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/driver_profile_model.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/passenger_profile_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/presentation/screens/driver_ride_requests_screen.dart';
import 'package:fellow_traveller_mobile/core/router/role_shell.dart';
import 'package:fellow_traveller_mobile/core/screens/main_screen.dart';
import 'package:fellow_traveller_mobile/core/screens/root_screen.dart';
import 'package:fellow_traveller_mobile/core/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  redirect: (BuildContext context, GoRouterState state) {
    final path = state.uri.path;
    final session = AppDependencies.instance.userSession;

    if (path == AppRoutesEnum.splash.path) {
      return null;
    }

    if (session.needsProfileSetup &&
        path != AppRoutesEnum.createProfile.path &&
        path != AppRoutesEnum.auth.path) {
      return AppRoutesEnum.createProfile.path;
    }

    if (!session.needsProfileSetup &&
        path == AppRoutesEnum.createProfile.path) {
      return AppRoutesEnum.main.path;
    }

    return null;
  },
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutesEnum.splash.path,
  routes: <RouteBase>[
    GoRoute(
      path: AppRoutesEnum.splash.path,
      name: AppRoutesEnum.splash.name,
      builder: (context, state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: AppRoutesEnum.auth.path,
      name: AppRoutesEnum.auth.name,
      builder: (context, state) {
        return BlocProvider(
          create: (_) => AppDependencies.instance.createAuthBloc(),
          child: const AuthScreen(),
        );
      },
    ),
    GoRoute(
      path: AppRoutesEnum.createProfile.path,
      name: AppRoutesEnum.createProfile.name,
      builder: (BuildContext context, GoRouterState state) {
        return const CreateProfileScreen();
      },
    ),
    GoRoute(
      path: AppRoutesEnum.driverRideRequests.path,
      name: AppRoutesEnum.driverRideRequests.name,
      builder: (BuildContext context, GoRouterState state) {
        final ride = state.extra! as RideModel;
        return DriverRideRequestsScreen(ride: ride);
      },
    ),
    GoRoute(
      path: '${AppRoutesEnum.userDriverProfile.path}/:profileId',
      name: AppRoutesEnum.userDriverProfile.name,
      builder: (BuildContext context, GoRouterState state) {
        final profile = state.extra! as DriverProfileModel;
        return UserDriverProfileScreen(profile: profile);
      },
    ),
    GoRoute(
      path: '${AppRoutesEnum.userPassengerProfile.path}/:profileId',
      name: AppRoutesEnum.userPassengerProfile.name,
      builder: (BuildContext context, GoRouterState state) {
        final profile = state.extra! as PassengerProfileModel;
        return UserPassengerProfileScreen(profile: profile);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell child,
          ) {
            return RootScreen(currentPath: state.uri.path, child: child);
          },
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutesEnum.main.path,
              name: AppRoutesEnum.main.name,
              builder: (BuildContext context, GoRouterState state) {
                return const MainScreen();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutesEnum.rides.path,
              name: AppRoutesEnum.rides.name,
              builder: (BuildContext context, GoRouterState state) {
                return const RoleShell(
                  passenger: PassengerMyRidesScreen(),
                  driver: DriverMyRidesScreen(),
                );
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutesEnum.profile.path,
              name: AppRoutesEnum.profile.name,
              builder: (BuildContext context, GoRouterState state) {
                return const RoleShell(
                  passenger: PassengerProfileScreen(),
                  driver: DriverProfileScreen(),
                );
              },
            ),
          ],
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
