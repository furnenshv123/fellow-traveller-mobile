class RatingCreateParams {
  const RatingCreateParams({
    required this.driverProfileId,
    required this.rating,
    this.comment,
  });

  final int driverProfileId;
  final int rating;
  final String? comment;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'driver_profile_id': driverProfileId,
        'rating': rating,
        if (comment != null && comment!.trim().isNotEmpty)
          'comment': comment!.trim(),
      };
}

class RatingModel {
  const RatingModel({
    required this.id,
    required this.driverProfileId,
    required this.rating,
    this.passengerProfileId,
    this.comment,
  });

  final int id;
  final int driverProfileId;
  final int? passengerProfileId;
  final int rating;
  final String? comment;

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as int,
      driverProfileId: json['driver_profile_id'] as int,
      passengerProfileId: json['passenger_profile_id'] as int?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
    );
  }
}

class RatingResponseModel {
  const RatingResponseModel({
    required this.message,
    required this.ratingId,
    required this.newAvgRating,
  });

  final String message;
  final int ratingId;
  final double newAvgRating;

  factory RatingResponseModel.fromJson(Map<String, dynamic> json) {
    return RatingResponseModel(
      message: json['message'] as String? ?? '',
      ratingId: json['rating_id'] as int,
      newAvgRating: (json['new_avg_rating'] as num).toDouble(),
    );
  }
}
