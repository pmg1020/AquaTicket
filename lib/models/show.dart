class Show {
  final String id;
  final String title;
  final String type;
  final String location;
  final List<String> date;
  final String venueId; // ✅ 추가

  Show({
    required this.id,
    required this.title,
    required this.type,
    required this.location,
    required this.date,
    required this.venueId, // ✅ 생성자에도 추가
  });

  factory Show.fromMap(String id, Map<String, dynamic> data) {
    return Show(
      id: id,
      title: data['title'] ?? '',
      type: data['type'] ?? '',
      location: data['location'] ?? '',
      date: List<String>.from(data['date'] ?? []),
      venueId: data['venueId'] ?? '', // ✅ 매핑 추가
    );
  }
}
