class PointModel {
  const PointModel({required this.id, required this.name});

  final int id;
  final String name;

  factory PointModel.fromJson(Map<String, dynamic> json) {
    return PointModel(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{'id': id, 'name': name};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PointModel && id == other.id && name == other.name;

  @override
  int get hashCode => Object.hash(id, name);
}
