import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';
import 'package:fellow_traveller_mobile/core/features/auth/data/models/auth_response.dart';

part 'auth_api.g.dart';

@RestApi()
abstract class ApiClientAuth {
  factory ApiClientAuth(Dio dio, {String? baseUrl}) = _ApiClientAuth;
  @POST('/auth/login')
  Future<AuthResponse> login({@Body() required AuthModel loginRequest});
  @POST('/auth/register')
  Future<AuthResponse> register({@Body() required AuthModel registerRequest});
  @POST('/auth/change-role')
  Future<AuthResponse> changeRole({@Body() required String userRole});
}
