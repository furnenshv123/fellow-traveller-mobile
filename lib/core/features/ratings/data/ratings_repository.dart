import 'package:dio/dio.dart';
import 'package:fellow_traveller_mobile/core/config/app_config.dart';
import 'package:fellow_traveller_mobile/core/features/ratings/data/models/rating_model.dart';

class RatingsRepository {
  RatingsRepository({required Dio dio, bool? useMock})
      : _dio = dio,
        _useMock = useMock ?? AppConfig.useMockData;

  final Dio _dio;
  final bool _useMock;

  final List<RatingModel> _mockRatings = <RatingModel>[];

  Future<List<RatingModel>> getMyRatings() async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 150));
      return List<RatingModel>.from(_mockRatings);
    }

    final response = await _dio.get<List<dynamic>>('/ratings/my-ratings');
    final data = response.data ?? <dynamic>[];
    return data
        .map(
          (dynamic e) => RatingModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<bool> hasRatedDriver(int driverProfileId) async {
    final ratings = await getMyRatings();
    return ratings.any((RatingModel r) => r.driverProfileId == driverProfileId);
  }

  Future<RatingResponseModel> createRating(RatingCreateParams params) async {
    if (_useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final rating = RatingModel(
        id: _mockRatings.length + 1,
        driverProfileId: params.driverProfileId,
        rating: params.rating,
        comment: params.comment,
      );
      _mockRatings.add(rating);
      return RatingResponseModel(
        message: 'Спасибо за оценку!',
        ratingId: rating.id,
        newAvgRating: 4.8,
      );
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/ratings/',
      data: params.toJson(),
    );
    return RatingResponseModel.fromJson(response.data!);
  }
}
