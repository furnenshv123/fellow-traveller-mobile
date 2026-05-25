// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ride _$RideFromJson(Map<String, dynamic> json) => Ride(
  email: json['email'] as String?,
  password: json['password'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$RideToJson(Ride instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
  'role': instance.role,
};
