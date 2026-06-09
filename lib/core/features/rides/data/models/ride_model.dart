import 'package:fellow_traveller_mobile/core/features/rides/data/models/point_model.dart';

class RideModel {
  const RideModel({
    required this.id,
    required this.fromPoint,
    required this.toPoint,
    required this.date,
    required this.time,
    required this.price,
    required this.availablePlaces,
    this.driverName,
    this.driverRating,
    this.driverProfileId,
    this.driverPhoto,
    this.distanceKm,
    this.pendingRequestsCount = 0,
  });

  final int id;
  final PointModel fromPoint;
  final PointModel toPoint;
  final String date;
  final String time;
  final double price;
  final int availablePlaces;
  final int? driverProfileId;
  final String? driverName;
  final double? driverRating;
  final String? driverPhoto;
  final String? distanceKm;
  final int pendingRequestsCount;

  String get routeLabel => '${fromPoint.name} → ${toPoint.name}';

  RideModel copyWith({
    int? pendingRequestsCount,
  }) {
    return RideModel(
      id: id,
      fromPoint: fromPoint,
      toPoint: toPoint,
      date: date,
      time: time,
      price: price,
      availablePlaces: availablePlaces,
      driverName: driverName,
      driverRating: driverRating,
      driverProfileId: driverProfileId,
      driverPhoto: driverPhoto,
      distanceKm: distanceKm,
      pendingRequestsCount: pendingRequestsCount ?? this.pendingRequestsCount,
    );
  }

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] as int,
      fromPoint: json['from_point'] != null
          ? PointModel.fromJson(json['from_point'] as Map<String, dynamic>)
          : PointModel(id: json['from_point_id'] as int? ?? 0, name: ''),
      toPoint: json['to_point'] != null
          ? PointModel.fromJson(json['to_point'] as Map<String, dynamic>)
          : PointModel(id: json['to_point_id'] as int? ?? 0, name: ''),
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      availablePlaces: json['available_places'] as int? ?? 0,
      driverProfileId: json['driver_profile_id'] as int?,
      driverName: json['driver_name'] as String?,
      driverRating: (json['driver_rating'] as num?)?.toDouble(),
      driverPhoto: json['driver_photo'] as String?,
      distanceKm: json['distance_km'] as String?,
      pendingRequestsCount: json['pending_requests_count'] as int? ??
          json['pending_request_count'] as int? ??
          0,
    );
  }
}

class RideCreateParams {
  const RideCreateParams({
    required this.fromPointId,
    required this.toPointId,
    required this.date,
    required this.time,
    required this.availablePlaces,
    required this.price,
  });

  final int fromPointId;
  final int toPointId;
  final String date;
  final String time;
  final int availablePlaces;
  final double price;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from_point_id': fromPointId,
        'to_point_id': toPointId,
        'date': date,
        'time': time,
        'available_places': availablePlaces,
        'price': price,
      };
}

class RideUpdateParams {
  const RideUpdateParams({
    this.fromPointId,
    this.toPointId,
    this.time,
    this.date,
    this.availablePlaces,
    this.price,
  });

  final int? fromPointId;
  final int? toPointId;
  final String? time;
  final String? date;
  final int? availablePlaces;
  final double? price;

  Map<String, dynamic> toJson() => <String, dynamic>{
        if (fromPointId != null) 'from_point_id': fromPointId,
        if (toPointId != null) 'to_point_id': toPointId,
        if (time != null) 'time': time,
        if (date != null) 'date': date,
        if (availablePlaces != null) 'available_places': availablePlaces,
        if (price != null) 'price': price,
      };
}

class RideSearchParams {
  const RideSearchParams({
    required this.fromPointId,
    required this.toPointId,
    required this.date,
    this.maxPrice,
    this.minPlaces = 1,
  });

  final int fromPointId;
  final int toPointId;
  final String date;
  final double? maxPrice;
  final int minPlaces;
}
