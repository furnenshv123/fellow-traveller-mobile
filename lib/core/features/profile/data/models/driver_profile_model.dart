class DriverProfileModel {
  const DriverProfileModel({
    required this.id,
    required this.userId,
    this.fullName,
    this.phone,
    this.avgRating = 0,
    this.photoUrl,
    this.carModel,
    this.carColor,
    this.carLicense,
  });

  final int id;
  final int userId;
  final String? fullName;
  final String? phone;
  final double avgRating;
  final String? photoUrl;
  final String? carModel;
  final String? carColor;
  final String? carLicense;

  bool get isComplete =>
      _hasText(fullName) &&
      _hasText(phone) &&
      _hasText(carModel) &&
      _hasText(carLicense);

  factory DriverProfileModel.fromJson(Map<String, dynamic> json) {
    return DriverProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      photoUrl: json['photo_url'] as String?,
      carModel: json['car_model'] as String?,
      carColor: json['car_color'] as String?,
      carLicense: json['car_license'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson({
    required String fullName,
    required String phone,
    required String carModel,
    required String carLicense,
    String? photoUrl,
    String? carColor,
  }) =>
      <String, dynamic>{
        'full_name': fullName,
        'phone': phone,
        'car_model': carModel,
        'car_license': carLicense,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
        if (carColor != null && carColor.isNotEmpty) 'car_color': carColor,
      };

  static bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}
