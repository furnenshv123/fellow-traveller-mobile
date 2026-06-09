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
    this.driverProfileId,
    this.driverPhoto,
    this.driverCarModel,
    this.driverCarColor,
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
  final int? driverProfileId;
  final String? driverPhoto;
  final String? driverCarModel;
  final String? driverCarColor;

  String get routeLabel => '${fromPoint.name} → ${toPoint.name}';

  PassengerRideRequestModel copyWith({
    int? driverProfileId,
    String? driverName,
    double? driverRating,
    String? driverPhone,
    String? driverPhoto,
    String? driverCarModel,
    String? driverCarColor,
  }) {
    return PassengerRideRequestModel(
      id: id,
      rideId: rideId,
      status: status,
      seatsRequested: seatsRequested,
      fromPoint: fromPoint,
      toPoint: toPoint,
      date: date,
      time: time,
      price: price,
      driverName: driverName ?? this.driverName,
      driverRating: driverRating ?? this.driverRating,
      driverPhone: driverPhone ?? this.driverPhone,
      driverProfileId: driverProfileId ?? this.driverProfileId,
      driverPhoto: driverPhoto ?? this.driverPhoto,
      driverCarModel: driverCarModel ?? this.driverCarModel,
      driverCarColor: driverCarColor ?? this.driverCarColor,
    );
  }

  bool get isUpcoming =>
      status == RideRequestStatus.pending || status == RideRequestStatus.accepted;

  bool get canRateDriver {
    if (status != RideRequestStatus.accepted || driverProfileId == null) {
      return false;
    }
    final parts = date.split('-');
    if (parts.length != 3) {
      return false;
    }
    final rideDate = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return !rideDate.isAfter(todayDate);
  }
}

class DriverPassengerRequestModel {
  const DriverPassengerRequestModel({
    required this.id,
    required this.passengerProfileId,
    required this.status,
    required this.seatsRequested,
    required this.passengerName,
    this.passengerRating,
    this.passengerPhone,
    this.passengerPhoto,
  });

  final int id;
  final int passengerProfileId;
  final RideRequestStatus status;
  final int seatsRequested;
  final String passengerName;
  final double? passengerRating;
  final String? passengerPhone;
  final String? passengerPhoto;
}
