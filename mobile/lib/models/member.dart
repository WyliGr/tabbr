class Member {
  final int id;
  final int roomId;
  final String name;
  final DateTime createdAt;

  const Member({
    required this.id,
    required this.roomId,
    required this.name,
    required this.createdAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      roomId: json['room_id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
