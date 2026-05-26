import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';
@JsonSerializable()
class AuthModel {
  @JsonKey(name: "email")
  final String? email;
  @JsonKey(name: "password")
  final String? password;
  @JsonKey(name: "role")
  final String? role;

  AuthModel({this.email, this.password, this.role});

  AuthModel copyWith({String? email, String? password, String? role}) => AuthModel(
    email: email ?? this.email,
    password: password ?? this.password,
    role: role ?? this.role,
  );

  factory AuthModel.fromJson(Map<String, dynamic> json) => _$AuthModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}
