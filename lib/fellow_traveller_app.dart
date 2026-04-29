import 'package:fellow_traveller_mobile/core/router/router.dart';
import 'package:flutter/material.dart';

class FellowTravellerApp extends StatelessWidget {
  const FellowTravellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: 'Fellow Traveller Mobile',
    );
  }
}
