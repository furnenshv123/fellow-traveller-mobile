import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';

enum RideRequestStatus { pending, accepted, rejected, cancelled }

extension RideRequestStatusX on RideRequestStatus {
  String get apiValue => name;

  static RideRequestStatus fromApi(String? value) {
    return RideRequestStatus.values.firstWhere(
      (RideRequestStatus s) => s.name == value,
      orElse: () => RideRequestStatus.pending,
    );
  }

  String get labelRu {
    switch (this) {
      case RideRequestStatus.pending:
        return 'Ожидает';
      case RideRequestStatus.accepted:
        return 'Принят';
      case RideRequestStatus.rejected:
        return 'Отклонён';
      case RideRequestStatus.cancelled:
        return 'Отменён';
    }
  }
}

/// Passenger's booking request (GET /ride-requests/my-requests).
class PassengerRideRequestModel {
  const PassengerRideRequestModel({
    required this.id,
    required this.rideId,
    required this.status,
    required this.seatsRequested,
    required this.fromPoint,
    required this.toPoint,
    required this.date,
    required this.time,
    required this.price,
    this.driverName,
    this.driverRating,
    this.driverPhone,
  });

  final int id;
  final int rideId;
  final RideRequestStatus status;
  final int seatsRequested;
  final PointModel fromPoint;
  final PointModel toPoint;
  final String date;
  final String time;
  final double price;
  final String? driverName;
  final double? driverRating;
  final String? driverPhone;

  String get routeLabel => '${fromPoint.name} → ${toPoint.name}';

  bool get isUpcoming =>
      status == RideRequestStatus.pending || status == RideRequestStatus.accepted;
}

/// Driver-side passenger request (GET /ride-requests/ride/{id}).
class DriverPassengerRequestModel {
  const DriverPassengerRequestModel({
    required this.id,
    required this.status,
    required this.seatsRequested,
    required this.passengerName,
    this.passengerRating,
    this.passengerPhone,
  });

  final int id;
  final RideRequestStatus status;
  final int seatsRequested;
  final String passengerName;
  final double? passengerRating;
  final String? passengerPhone;
}
