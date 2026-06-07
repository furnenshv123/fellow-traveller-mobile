class PassengerProfileModel {
  const PassengerProfileModel({
    required this.id,
    required this.userId,
    this.fullName,
    this.phone,
    this.avgRating = 0,
    this.photoUrl,
  });

  final int id;
  final int userId;
  final String? fullName;
  final String? phone;
  final double avgRating;
  final String? photoUrl;

  bool get isComplete => _hasText(fullName) && _hasText(phone);

  factory PassengerProfileModel.fromJson(Map<String, dynamic> json) {
    return PassengerProfileModel(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      avgRating: (json['avg_rating'] as num?)?.toDouble() ?? 0,
      photoUrl: json['photo_url'] as String?,
    );
  }

  Map<String, dynamic> toCreateJson({
    required String fullName,
    required String phone,
    String? photoUrl,
  }) =>
      <String, dynamic>{
        'full_name': fullName,
        'phone': phone,
        if (photoUrl != null && photoUrl.isNotEmpty) 'photo_url': photoUrl,
      };

  static bool _hasText(String? value) => value != null && value.trim().isNotEmpty;
}
