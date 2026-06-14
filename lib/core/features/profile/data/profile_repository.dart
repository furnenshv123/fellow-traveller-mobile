import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/config/app_config.dart';
import 'package:fellow_traveller_mobile/core/data/user_session.dart';
import 'package:fellow_traveller_mobile/core/enums/user_role.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/driver_profile_model.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/passenger_profile_model.dart';
import 'package:fellow_traveller_mobile/core/features/profile/data/models/photo_upload_response.dart';

class ProfileRepository {
  ProfileRepository({
    required Dio dio,
    required UserSession userSession,
    bool? useMock,
  })  : _dio = dio,
        _userSession = userSession,
        _useMock = useMock ?? AppConfig.useMockData;

  final Dio _dio;
  final UserSession _userSession;
  final bool _useMock;

  DriverProfileModel? _mockDriverProfile;
  PassengerProfileModel? _mockPassengerProfile;

  Future<bool> isProfileComplete() async {
    if (_userSession.isDriver) {
      final profile = await _fetchDriverProfile();
      return profile?.isComplete ?? false;
    }
    final profile = await _fetchPassengerProfile();
    return profile?.isComplete ?? false;
  }

  Future<DriverProfileModel?> getDriverProfile() => _fetchDriverProfile();

  Future<PassengerProfileModel?> getPassengerProfile() => _fetchPassengerProfile();

  Future<DriverProfileModel?> getDriverProfileById(int driverProfileId) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return DriverProfileModel(
        id: driverProfileId,
        userId: driverProfileId,
        fullName: 'Водитель #$driverProfileId',
        phone: '+375 29 000 00 00',
        avgRating: 4.8,
        carModel: 'Toyota Camry',
        carColor: 'Белый',
        carLicense: 'A123BC01',
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/profile/driver/$driverProfileId',
      );
      final data = response.data;
      if (data == null) {
        return null;
      }
      return DriverProfileModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<PassengerProfileModel?> getPassengerProfileById(
    int passengerProfileId,
  ) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return PassengerProfileModel(
        id: passengerProfileId,
        userId: passengerProfileId,
        fullName: 'Попутчик #$passengerProfileId',
        phone: '+375 29 111 11 11',
        avgRating: 4.7,
      );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/passenger/profile/$passengerProfileId',
      );
      final data = response.data;
      if (data == null) {
        return null;
      }
      return PassengerProfileModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> createDriverProfile({
    required String fullName,
    required String phone,
    required String carModel,
    required String carLicense,
    String? photoUrl,
    String? carColor,
  }) async {
    final body = DriverProfileModel(
      id: 0,
      userId: 0,
    ).toCreateJson(
      fullName: fullName.trim(),
      phone: phone.trim(),
      carModel: carModel.trim(),
      carLicense: carLicense.trim(),
      photoUrl: photoUrl?.trim(),
      carColor: carColor?.trim(),
    );

    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _mockDriverProfile = DriverProfileModel(
        id: 1,
        userId: 1,
        fullName: fullName.trim(),
        phone: phone.trim(),
        carModel: carModel.trim(),
        carLicense: carLicense.trim(),
        photoUrl: photoUrl?.trim(),
        carColor: carColor?.trim(),
      );
      return;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/driver/profile',
      data: body,
    );
    _mockDriverProfile = DriverProfileModel.fromJson(response.data!);
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      const mockUrl = 'https://picsum.photos/seed/profile/200';
      if (_userSession.isDriver) {
        _mockDriverProfile = _mockDriverProfile?.copyWithPhoto(mockUrl) ??
            DriverProfileModel(
              id: 1,
              userId: 1,
              fullName: 'Водитель',
              phone: '+375 29 000 00 00',
              photoUrl: mockUrl,
            );
      } else {
        _mockPassengerProfile =
            _mockPassengerProfile?.copyWithPhoto(mockUrl) ??
                PassengerProfileModel(
                  id: 1,
                  userId: 1,
                  fullName: 'Попутчик',
                  phone: '+375 29 000 00 00',
                  photoUrl: mockUrl,
                );
      }
      return mockUrl;
    }

    final formData = FormData.fromMap(<String, dynamic>{
      'photo': await MultipartFile.fromFile(filePath),
    });

    final response = await _dio.post<Map<String, dynamic>>(
      '/profile/photo',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data;
    if (data == null) {
      throw DioException(
        requestOptions: response.requestOptions,
        message: 'Empty photo upload response',
      );
    }

    return PhotoUploadResponse.fromJson(data).photoUrl;
  }

  Future<void> deleteProfilePhoto() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (_userSession.isDriver) {
        _mockDriverProfile = _mockDriverProfile?.copyWithPhoto(null);
      } else {
        _mockPassengerProfile = _mockPassengerProfile?.copyWithPhoto(null);
      }
      return;
    }

    await _dio.delete<void>('/profile/photo');
  }

  Future<void> createPassengerProfile({
    required String fullName,
    required String phone,
    String? photoUrl,
  }) async {
    final body = PassengerProfileModel(
      id: 0,
      userId: 0,
    ).toCreateJson(
      fullName: fullName.trim(),
      phone: phone.trim(),
      photoUrl: photoUrl?.trim(),
    );

    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _mockPassengerProfile = PassengerProfileModel(
        id: 1,
        userId: 1,
        fullName: fullName.trim(),
        phone: phone.trim(),
        photoUrl: photoUrl?.trim(),
      );
      return;
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/passenger/profile',
      data: body,
    );
    _mockPassengerProfile = PassengerProfileModel.fromJson(response.data!);
  }

  Future<DriverProfileModel?> _fetchDriverProfile() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _mockDriverProfile ??
          const DriverProfileModel(
            id: 1,
            userId: 1,
            fullName: 'Нурсултан Кулов',
            phone: '+7 700 111 2233',
            avgRating: 4.8,
            carModel: 'Toyota Camry',
            carColor: 'Белый',
            carLicense: 'A123BC01',
          );
    }

    try {
      final response = await _dio.get<Map<String, dynamic>>('/driver/profile');
      final data = response.data;
      if (data == null) {
        return null;
      }
      return DriverProfileModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<PassengerProfileModel?> _fetchPassengerProfile() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return _mockPassengerProfile ??
          const PassengerProfileModel(
            id: 1,
            userId: 1,
            fullName: 'Алина Смирнова',
            phone: '+7 701 222 3344',
            avgRating: 4.7,
          );
    }

    try {
      final response =
          await _dio.get<Map<String, dynamic>>('/passenger/profile');
      final data = response.data;
      if (data == null) {
        return null;
      }
      return PassengerProfileModel.fromJson(data);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  bool hintNeedsSetupFromAuth({
    required UserRole role,
    bool? hasDriverProfile,
    bool? hasPassengerProfile,
  }) {
    if (role == UserRole.driver) {
      return hasDriverProfile != true;
    }
    return hasPassengerProfile != true;
  }
}
