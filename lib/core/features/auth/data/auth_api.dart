// import 'package:dio/dio.dart';
// import 'package:retrofit/http.dart';

// @RestApi()
// abstract class ApiClientAuth {
//   factory ApiClientAuth(Dio dio, {String? baseUrl}) = _ApiClientAuth;
//   @GET('/api/user/user-info')
//   Future<UserInfoModel> getUserInfo();
//   @POST('/api/auth/sign-in')
//   Future<TokenModel> signIn(@Body() SignInRequest signInRequest);
//   @POST('/api/reset-password/get-code-to-reset-by-email')
//   Future<RequestErrorModel> getCodeToResetByEmail({
//     @Body() required EmailCodeModel email,
//   });
//   @POST('/api/reset-password/verify-code')
//   Future<RequestErrorModel> verifyCode({@Body() required EmailCodeModel email});
//   @PUT('/api/reset-password/reset-password')
//   Future<TokenModel> resetPassword({@Body() required EmailCodeModel email});
// }
