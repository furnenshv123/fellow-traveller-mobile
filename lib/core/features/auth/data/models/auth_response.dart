import 'package:json_annotation/json_annotation.dart';
part 'auth_response.g.dart';

@JsonSerializable()
class Ride {
  @JsonKey(name: "access_token")
  final String? accessToken;
  @JsonKey(name: "token_type")
  final String? tokenType;
  @JsonKey(name: "user_id")
  final int? userId;
  @JsonKey(name: "email")
  final String? email;
  @JsonKey(name: "current_role")
  final String? currentRole;
  @JsonKey(name: "has_driver_profile")
  final bool? hasDriverProfile;
  @JsonKey(name: "has_passenger_profile")
  final bool? hasPassengerProfile;

  Ride({
    this.accessToken,
    this.tokenType,
    this.userId,
    this.email,
    this.currentRole,
    this.hasDriverProfile,
    this.hasPassengerProfile,
  });

  Ride copyWith({
    String? accessToken,
    String? tokenType,
    int? userId,
    String? email,
    String? currentRole,
    bool? hasDriverProfile,
    bool? hasPassengerProfile,
  }) => Ride(
    accessToken: accessToken ?? this.accessToken,
    tokenType: tokenType ?? this.tokenType,
    userId: userId ?? this.userId,
    email: email ?? this.email,
    currentRole: currentRole ?? this.currentRole,
    hasDriverProfile: hasDriverProfile ?? this.hasDriverProfile,
    hasPassengerProfile: hasPassengerProfile ?? this.hasPassengerProfile,
  );

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);

  Map<String, dynamic> toJson() => _$RideToJson(this);
}
