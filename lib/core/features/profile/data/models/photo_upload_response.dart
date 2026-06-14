class PhotoUploadResponse {
  const PhotoUploadResponse({
    required this.photoUrl,
    this.message,
  });

  final String photoUrl;
  final String? message;

  factory PhotoUploadResponse.fromJson(Map<String, dynamic> json) {
    return PhotoUploadResponse(
      photoUrl: json['photo_url'] as String,
      message: json['message'] as String?,
    );
  }
}
