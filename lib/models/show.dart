class Show {
  final String id;
  final String title;
  final String type;
  final String location;
  final List<String> date;
  final String venueId;
  final int maxTicketsPerUser;
  final String? posterImageUrl;
  final int basePrice; // ✅ 기본 가격 필드 추가

  Show({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.date,
    required this.venueId,
    required this.maxTicketsPerUser,
    this.posterImageUrl,
    this.basePrice = 70000, // ✅ 기본값 설정 (기본 가격 없으면 70000원)
  });

  factory Show.fromMap(String id, Map<String, dynamic> data) {
    return Show(
      id: id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      date: List<String>.from(data['date'] ?? []),
      venueId: data['venueId'] ?? '',
      maxTicketsPerUser: data['maxTicketsPerUser'] ?? 1,
      posterImageUrl: data['posterImageUrl'],
      basePrice: data['basePrice'] ?? 70000, // ✅ 매핑 추가
    );
  }
}
