import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/config/app_config.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/mock/rides_mock_data.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';

class RidesRepository {
  RidesRepository({required Dio dio, bool? useMock})
      : _dio = dio,
        _useMock = useMock ?? AppConfig.useMockData;

  final Dio _dio;
  final bool _useMock;

  int _nextRideId = 500;

  Future<List<PointModel>> getPoints() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return RidesMockData.points;
    }

    final response = await _dio.get<List<dynamic>>('/points/');
    final data = response.data ?? <dynamic>[];
    return data
        .map((dynamic e) => PointModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<PointModel>> searchPoints(String query) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      final normalized = query.trim().toLowerCase();
      if (normalized.isEmpty) {
        return RidesMockData.points;
      }
      return RidesMockData.points
          .where((PointModel p) => p.name.toLowerCase().contains(normalized))
          .toList();
    }

    final response = await _dio.get<List<dynamic>>(
      '/points/search',
      queryParameters: <String, dynamic>{'q': query},
    );
    final data = response.data ?? <dynamic>[];
    return data
        .map((dynamic e) => PointModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RideModel>> searchRides(RideSearchParams params) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return RidesMockData.search(
        fromPointId: params.fromPointId,
        toPointId: params.toPointId,
        date: params.date,
      );
    }

    final response = await _dio.get<List<dynamic>>(
      '/rides/search',
      queryParameters: <String, dynamic>{
        'from_point_id': params.fromPointId,
        'to_point_id': params.toPointId,
        'date': params.date,
        if (params.maxPrice != null) 'max_price': params.maxPrice,
        'min_places': params.minPlaces,
      },
    );
    final data = response.data ?? <dynamic>[];
    return data
        .map((dynamic e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<RideModel>> getMyRides() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return List<RideModel>.from(RidesMockData.driverMyRides);
    }

    final response = await _dio.get<List<dynamic>>('/rides/my-rides');
    final data = response.data ?? <dynamic>[];
    return data
        .map((dynamic e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<RideModel> createRide(RideCreateParams params) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final from = RidesMockData.points.firstWhere(
        (PointModel p) => p.id == params.fromPointId,
      );
      final to = RidesMockData.points.firstWhere(
        (PointModel p) => p.id == params.toPointId,
      );
      final ride = RideModel(
        id: _nextRideId++,
        fromPoint: from,
        toPoint: to,
        date: params.date,
        time: params.time,
        price: params.price,
        availablePlaces: params.availablePlaces,
        pendingRequestsCount: 0,
      );
      RidesMockData.driverMyRides.insert(0, ride);
      return ride;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/rides/',
      data: params.toJson(),
    );
    return RideModel.fromJson(response.data!);
  }

  Future<List<PassengerRideRequestModel>> getMyPassengerRequests() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return List<PassengerRideRequestModel>.from(
        RidesMockData.passengerMyRequests,
      );
    }

    final response = await _dio.get<List<dynamic>>('/ride-requests/my-requests');
    final data = response.data ?? <dynamic>[];
    return data.map(_mapPassengerRequest).toList();
  }

  Future<List<DriverPassengerRequestModel>> getRideRequests(int rideId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return List<DriverPassengerRequestModel>.from(
        RidesMockData.requestsByRideId[rideId] ?? <DriverPassengerRequestModel>[],
      );
    }

    final response = await _dio.get<List<dynamic>>('/ride-requests/ride/$rideId');
    final data = response.data ?? <dynamic>[];
    return data.map(_mapDriverRequest).toList();
  }

  PassengerRideRequestModel _mapPassengerRequest(dynamic json) {
    final map = json as Map<String, dynamic>;
    return PassengerRideRequestModel(
      id: map['id'] as int,
      rideId: map['driver_ride_id'] as int,
      status: RideRequestStatusX.fromApi(map['status'] as String?),
      seatsRequested: map['seats_requested'] as int? ?? 1,
      fromPoint: map['from_point'] != null
          ? PointModel.fromJson(map['from_point'] as Map<String, dynamic>)
          : const PointModel(id: 0, name: ''),
      toPoint: map['to_point'] != null
          ? PointModel.fromJson(map['to_point'] as Map<String, dynamic>)
          : const PointModel(id: 0, name: ''),
      date: map['date'] as String? ?? '',
      time: map['time'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      driverName: map['driver_name'] as String?,
      driverRating: (map['driver_rating'] as num?)?.toDouble(),
      driverPhone: map['driver_phone'] as String?,
    );
  }

  DriverPassengerRequestModel _mapDriverRequest(dynamic json) {
    final map = json as Map<String, dynamic>;
    return DriverPassengerRequestModel(
      id: map['id'] as int,
      status: RideRequestStatusX.fromApi(map['status'] as String?),
      seatsRequested: map['seats_requested'] as int? ?? 1,
      passengerName: map['passenger_name'] as String? ?? 'Пассажир',
      passengerRating: (map['passenger_rating'] as num?)?.toDouble(),
      passengerPhone: map['passenger_phone'] as String?,
    );
  }
}
