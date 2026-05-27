part of 'driver_home_bloc.dart';

@immutable
sealed class DriverHomeEvent {
  const DriverHomeEvent();
}

class DriverHomeStarted extends DriverHomeEvent {
  const DriverHomeStarted();
}

class DriverHomeRideSubmitted extends DriverHomeEvent {
  const DriverHomeRideSubmitted({
    required this.from,
    required this.to,
    required this.dateIso,
    required this.time,
    required this.seats,
    required this.price,
  });

  final PointModel? from;
  final PointModel? to;
  final String? dateIso;
  final String? time;
  final int seats;
  final double price;
}
