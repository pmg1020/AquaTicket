class Show {
  final String id;
  final String title;
  final String type;
  final String location;
  final List<String> date;
  final String venueId;
  final int maxTicketsPerUser;
  final String? posterImageUrl; // ✅ 포스터 이미지 URL 필드 추가

  Show({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.date,
    required this.venueId,
    required this.maxTicketsPerUser,
    this.posterImageUrl, // ✅ 생성자에도 추가 (선택 사항)
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
      posterImageUrl: data['posterImageUrl'], // ✅ 매핑 추가
    );
  }
}
