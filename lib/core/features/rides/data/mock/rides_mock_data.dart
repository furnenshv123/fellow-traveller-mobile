import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';

class RidesMockData {
  RidesMockData._();

  static const List<PointModel> points = <PointModel>[
    PointModel(id: 1, name: 'Алматы'),
    PointModel(id: 2, name: 'Астана'),
    PointModel(id: 3, name: 'Бишкек'),
    PointModel(id: 4, name: 'Шымкент'),
    PointModel(id: 5, name: 'Караганда'),
    PointModel(id: 6, name: 'Тараз'),
  ];

  static final List<RideModel> availableRides = <RideModel>[
    RideModel(
      id: 101,
      fromPoint: points[0],
      toPoint: points[2],
      date: '2026-05-28',
      time: '09:00',
      price: 8500,
      availablePlaces: 2,
      driverName: 'Нурсултан',
      driverRating: 4.8,
      distanceKm: '235',
    ),
    RideModel(
      id: 102,
      fromPoint: points[5],
      toPoint: points[3],
      date: '2026-05-29',
      time: '14:30',
      price: 4500,
      availablePlaces: 3,
      driverName: 'Азамат',
      driverRating: 4.6,
      distanceKm: '180',
    ),
    RideModel(
      id: 103,
      fromPoint: points[1],
      toPoint: points[4],
      date: '2026-05-30',
      time: '11:00',
      price: 5000,
      availablePlaces: 1,
      driverName: 'Дана',
      driverRating: 4.9,
      distanceKm: '220',
    ),
    RideModel(
      id: 104,
      fromPoint: points[0],
      toPoint: points[3],
      date: '2026-05-28',
      time: '16:00',
      price: 6000,
      availablePlaces: 4,
      driverName: 'Ерлан',
      driverRating: 4.5,
      distanceKm: '680',
    ),
  ];

  static final List<RideModel> driverMyRides = <RideModel>[
    RideModel(
      id: 201,
      fromPoint: points[0],
      toPoint: points[2],
      date: '2026-05-28',
      time: '09:00',
      price: 8500,
      availablePlaces: 2,
      pendingRequestsCount: 3,
    ),
    RideModel(
      id: 202,
      fromPoint: points[1],
      toPoint: points[4],
      date: '2026-06-02',
      time: '08:30',
      price: 5000,
      availablePlaces: 3,
      pendingRequestsCount: 0,
    ),
  ];

  static final List<PassengerRideRequestModel> passengerMyRequests =
      <PassengerRideRequestModel>[
    PassengerRideRequestModel(
      id: 301,
      rideId: 101,
      status: RideRequestStatus.accepted,
      seatsRequested: 1,
      fromPoint: points[0],
      toPoint: points[2],
      date: '2026-05-28',
      time: '09:00',
      price: 8500,
      driverName: 'Нурсултан',
      driverRating: 4.8,
      driverPhone: '+7 700 111 2233',
    ),
    PassengerRideRequestModel(
      id: 302,
      rideId: 103,
      status: RideRequestStatus.pending,
      seatsRequested: 2,
      fromPoint: points[1],
      toPoint: points[4],
      date: '2026-05-30',
      time: '11:00',
      price: 5000,
      driverName: 'Дана',
      driverRating: 4.9,
    ),
    PassengerRideRequestModel(
      id: 303,
      rideId: 99,
      status: RideRequestStatus.accepted,
      seatsRequested: 1,
      fromPoint: points[1],
      toPoint: points[4],
      date: '2026-04-20',
      time: '10:00',
      price: 5000,
      driverName: 'Дана',
      driverRating: 4.5,
    ),
  ];

  static final Map<int, List<DriverPassengerRequestModel>> requestsByRideId =
      <int, List<DriverPassengerRequestModel>>{
    201: <DriverPassengerRequestModel>[
      const DriverPassengerRequestModel(
        id: 401,
        status: RideRequestStatus.pending,
        seatsRequested: 1,
        passengerName: 'Ольга К.',
        passengerRating: 4.9,
        passengerPhone: '+7 701 222 3344',
      ),
      const DriverPassengerRequestModel(
        id: 402,
        status: RideRequestStatus.pending,
        seatsRequested: 2,
        passengerName: 'Сергей П.',
        passengerRating: 4.6,
      ),
      const DriverPassengerRequestModel(
        id: 403,
        status: RideRequestStatus.pending,
        seatsRequested: 1,
        passengerName: 'Мария Л.',
        passengerRating: 4.3,
      ),
    ],
  };

  static List<RideModel> search({
    required int fromPointId,
    required int toPointId,
    required String date,
  }) {
    return availableRides
        .where(
          (RideModel r) =>
              r.fromPoint.id == fromPointId &&
              r.toPoint.id == toPointId &&
              r.date == date,
        )
        .toList();
  }
}
