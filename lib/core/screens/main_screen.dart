import 'package:fellow_traveller_mobile/core/components/app_screen_body.dart';
import 'package:fellow_traveller_mobile/core/components/main_screen_background.dart';
import 'package:fellow_traveller_mobile/core/data/user_session.dart';
import 'package:fellow_traveller_mobile/core/di/app_dependencies.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/bloc/driver_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/driver/presentation/screens/driver_home_screen.dart';
import 'package:fellow_traveller_mobile/core/features/passenger/presentation/bloc/passenger_home_bloc.dart';
import 'package:fellow_traveller_mobile/core/features/passenger/presentation/screens/passenger_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  UserSession get _session => AppDependencies.instance.userSession;

  @override
  Widget build(BuildContext context) {
    final Widget home;
    if (_session.role == UserRole.driver) {
      home = BlocProvider(
        create: (_) => AppDependencies.instance.createDriverHomeBloc()
          ..add(const DriverHomeStarted()),
        child: const DriverHomeScreen(),
      );
    } else {
      home = BlocProvider(
        create: (_) => AppDependencies.instance.createPassengerHomeBloc()
          ..add(const PassengerHomeStarted()),
        child: const PassengerHomeScreen(),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const MainScreenBackground(),
        AppScreenBody(withBottomNav: true, child: home),
      ],
    );
  }
}
