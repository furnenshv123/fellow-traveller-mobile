import 'package:fellow_traveller_mobile/core/features/profile/data/models/driver_profile_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_model.dart';
import 'package:fellow_traveller_mobile/core/features/rides/data/models/ride_request_model.dart';

class ProfileUiMapper {
  ProfileUiMapper._();

  static DriverProfileModel fromRide(RideModel ride) {
    return DriverProfileModel(
      id: ride.driverProfileId ?? 0,
      userId: 0,
      fullName: ride.driverName,
      avgRating: ride.driverRating ?? 0,
      photoUrl: ride.driverPhoto,
    );
  }

  static DriverProfileModel fromPassengerRequest(PassengerRideRequestModel request) {
    return DriverProfileModel(
      id: request.driverProfileId ?? 0,
      userId: 0,
      fullName: request.driverName,
      phone: request.driverPhone,
      avgRating: request.driverRating ?? 0,
      photoUrl: request.driverPhoto,
      carModel: request.driverCarModel,
      carColor: request.driverCarColor,
    );
  }
}
