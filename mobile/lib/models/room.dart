class Room {
  final int id;
  final String code;
  final String? name;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.code,
    required this.name,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
