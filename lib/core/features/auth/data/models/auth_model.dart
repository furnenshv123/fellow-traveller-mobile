import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';
@JsonSerializable()
class Ride {
  @JsonKey(name: "email")
  final String? email;
  @JsonKey(name: "password")
  final String? password;
  @JsonKey(name: "role")
  final String? role;

  Ride({this.email, this.password, this.role});

  Ride copyWith({String? email, String? password, String? role}) => Ride(
    email: email ?? this.email,
    password: password ?? this.password,
    role: role ?? this.role,
  );

  factory Ride.fromJson(Map<String, dynamic> json) => _$RideFromJson(json);

  Map<String, dynamic> toJson() => _$RideToJson(this);
}
