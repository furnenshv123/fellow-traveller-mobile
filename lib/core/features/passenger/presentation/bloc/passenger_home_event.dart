part of 'passenger_home_bloc.dart';

@immutable
sealed class PassengerHomeEvent {
  const PassengerHomeEvent();
}

class PassengerHomeStarted extends PassengerHomeEvent {
  const PassengerHomeStarted();
}

class PassengerHomeSearchSubmitted extends PassengerHomeEvent {
  const PassengerHomeSearchSubmitted({
    required this.from,
    required this.to,
    required this.dateIso,
  });

  final PointModel? from;
  final PointModel? to;
  final String? dateIso;
}
