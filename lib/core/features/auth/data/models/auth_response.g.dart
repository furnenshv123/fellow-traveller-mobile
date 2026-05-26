// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  accessToken: json['access_token'] as String?,
  tokenType: json['token_type'] as String?,
  userId: (json['user_id'] as num?)?.toInt(),
  email: json['email'] as String?,
  currentRole: json['current_role'] as String?,
  hasDriverProfile: json['has_driver_profile'] as bool?,
  hasPassengerProfile: json['has_passenger_profile'] as bool?,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'token_type': instance.tokenType,
      'user_id': instance.userId,
      'email': instance.email,
      'current_role': instance.currentRole,
      'has_driver_profile': instance.hasDriverProfile,
      'has_passenger_profile': instance.hasPassengerProfile,
    };
