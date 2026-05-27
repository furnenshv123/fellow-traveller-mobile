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
    if (_session.role == UserRole.driver) {
      return BlocProvider(
        create: (_) => AppDependencies.instance.createDriverHomeBloc()
          ..add(const DriverHomeStarted()),
        child: const DriverHomeScreen(),
      );
    }

    return BlocProvider(
      create: (_) => AppDependencies.instance.createPassengerHomeBloc()
        ..add(const PassengerHomeStarted()),
      child: const PassengerHomeScreen(),
    );
  }
}
