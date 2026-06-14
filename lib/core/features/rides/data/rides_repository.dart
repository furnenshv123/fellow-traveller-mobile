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
    final rides = data
        .map((dynamic e) => RideModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return _withPendingRequestCounts(rides);
  }

  Future<List<RideModel>> _withPendingRequestCounts(List<RideModel> rides) async {
    if (rides.isEmpty) {
      return rides;
    }

    final counts = await Future.wait(
      rides.map((RideModel ride) async {
        try {
          final requests = await getRideRequests(ride.id);
          return requests
              .where(
                (DriverPassengerRequestModel r) =>
                    r.status == RideRequestStatus.pending,
              )
              .length;
        } catch (_) {
          return ride.pendingRequestsCount;
        }
      }),
    );

    return List<RideModel>.generate(
      rides.length,
      (int index) => rides[index].copyWith(pendingRequestsCount: counts[index]),
    );
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

  Future<void> deleteRide(int rideId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      RidesMockData.driverMyRides.removeWhere((RideModel r) => r.id == rideId);
      RidesMockData.requestsByRideId.remove(rideId);
      return;
    }

    await _dio.delete<void>('/rides/$rideId');
  }

  Future<RideModel> updateRide(int rideId, RideUpdateParams params) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final index = RidesMockData.driverMyRides.indexWhere(
        (RideModel r) => r.id == rideId,
      );
      if (index == -1) {
        throw StateError('Ride not found');
      }
      final current = RidesMockData.driverMyRides[index];
      final from = params.fromPointId != null
          ? RidesMockData.points.firstWhere(
              (PointModel p) => p.id == params.fromPointId,
            )
          : current.fromPoint;
      final to = params.toPointId != null
          ? RidesMockData.points.firstWhere(
              (PointModel p) => p.id == params.toPointId,
            )
          : current.toPoint;
      final updated = RideModel(
        id: current.id,
        fromPoint: from,
        toPoint: to,
        date: params.date ?? current.date,
        time: params.time ?? current.time,
        price: params.price ?? current.price,
        availablePlaces: params.availablePlaces ?? current.availablePlaces,
        pendingRequestsCount: current.pendingRequestsCount,
      );
      RidesMockData.driverMyRides[index] = updated;
      return updated;
    }

    final response = await _dio.put<Map<String, dynamic>>(
      '/rides/$rideId',
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
    final requests = data.map(_mapPassengerRequest).toList();
    return _withResolvedDriverProfileIds(requests);
  }

  Future<List<PassengerRideRequestModel>> _withResolvedDriverProfileIds(
    List<PassengerRideRequestModel> requests,
  ) async {
    if (requests.isEmpty) {
      return requests;
    }

    return Future.wait(
      requests.map((PassengerRideRequestModel request) async {
        if (request.driverProfileId != null) {
          return request;
        }

        final ride = await getRideById(request.rideId);
        final driverProfileId = ride?.driverProfileId;
        if (driverProfileId == null) {
          return request;
        }

        return request.copyWith(
          driverProfileId: driverProfileId,
          driverName: request.driverName ?? ride?.driverName,
          driverRating: request.driverRating ?? ride?.driverRating,
          driverPhoto: request.driverPhoto ?? ride?.driverPhoto,
        );
      }),
    );
  }

  Future<void> createRideRequest({
    required int rideId,
    int seatsRequested = 1,
  }) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      RideModel? ride;
      for (final RideModel candidate in RidesMockData.availableRides) {
        if (candidate.id == rideId) {
          ride = candidate;
          break;
        }
      }
      for (final RideModel candidate in RidesMockData.driverMyRides) {
        if (candidate.id == rideId) {
          ride = candidate;
          break;
        }
      }
      if (ride == null) {
        return;
      }
      RidesMockData.passengerMyRequests.insert(
        0,
        PassengerRideRequestModel(
          id: 300 + RidesMockData.passengerMyRequests.length,
          rideId: rideId,
          status: RideRequestStatus.pending,
          seatsRequested: seatsRequested,
          fromPoint: ride.fromPoint,
          toPoint: ride.toPoint,
          date: ride.date,
          time: ride.time,
          price: ride.price,
          driverName: ride.driverName,
          driverRating: ride.driverRating,
          driverProfileId: ride.driverProfileId,
        ),
      );
      return;
    }

    await _dio.post<void>(
      '/ride-requests/',
      data: <String, dynamic>{
        'ride_id': rideId,
        'seats_requested': seatsRequested,
      },
    );
  }

  Future<void> cancelRideRequest(int requestId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      RidesMockData.passengerMyRequests.removeWhere(
        (PassengerRideRequestModel r) => r.id == requestId,
      );
      for (final entry in RidesMockData.requestsByRideId.entries) {
        entry.value.removeWhere(
          (DriverPassengerRequestModel r) => r.id == requestId,
        );
      }
      return;
    }

    await _dio.delete<void>('/ride-requests/$requestId');
  }

  Future<void> acceptRideRequest(int requestId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _updateMockRequestStatus(requestId, RideRequestStatus.accepted);
      return;
    }

    await _dio.put<void>('/ride-requests/$requestId/accept');
  }

  Future<void> rejectRideRequest(int requestId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      _updateMockRequestStatus(requestId, RideRequestStatus.rejected);
      return;
    }

    await _dio.put<void>('/ride-requests/$requestId/reject');
  }

  void _updateMockRequestStatus(int requestId, RideRequestStatus status) {
    for (final entry in RidesMockData.requestsByRideId.entries) {
      final index = entry.value.indexWhere(
        (DriverPassengerRequestModel r) => r.id == requestId,
      );
      if (index == -1) {
        continue;
      }
      final current = entry.value[index];
      entry.value[index] = DriverPassengerRequestModel(
        id: current.id,
        passengerProfileId: current.passengerProfileId,
        status: status,
        seatsRequested: current.seatsRequested,
        passengerName: current.passengerName,
        passengerRating: current.passengerRating,
        passengerPhone: current.passengerPhone,
        passengerPhoto: current.passengerPhoto,
      );
      break;
    }
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

  Future<RideModel?> getRideById(int rideId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      for (final RideModel ride in RidesMockData.driverMyRides) {
        if (ride.id == rideId) {
          return ride;
        }
      }
      for (final RideModel ride in RidesMockData.availableRides) {
        if (ride.id == rideId) {
          return ride;
        }
      }
      return null;
    }

    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/rides/$rideId');
      final data = response.data;
      if (data == null) {
        return null;
      }
      return RideModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<int?> resolveDriverProfileId(PassengerRideRequestModel request) async {
    if (request.driverProfileId != null) {
      return request.driverProfileId;
    }

    final ride = await getRideById(request.rideId);
    return ride?.driverProfileId;
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
      driverProfileId: map['driver_profile_id'] as int?,
      driverPhoto: map['driver_photo'] as String?,
      driverCarModel: map['driver_car_model'] as String?,
      driverCarColor: map['driver_car_color'] as String?,
    );
  }

  DriverPassengerRequestModel _mapDriverRequest(dynamic json) {
    final map = json as Map<String, dynamic>;
    return DriverPassengerRequestModel(
      id: map['id'] as int,
      passengerProfileId: map['passenger_profile_id'] as int? ?? 0,
      status: RideRequestStatusX.fromApi(map['status'] as String?),
      seatsRequested: map['seats_requested'] as int? ?? 1,
      passengerName: map['passenger_name'] as String? ?? 'Попутчик',
      passengerRating: (map['passenger_rating'] as num?)?.toDouble(),
      passengerPhone: map['passenger_phone'] as String?,
      passengerPhoto: map['passenger_photo'] as String?,
    );
  }
}
