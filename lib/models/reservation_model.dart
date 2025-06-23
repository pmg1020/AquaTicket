class Reservation {
  final String showId;
  final String showTitle;
  final String dateTime;
  final String section;
  final List<String> seats;
  final int totalPrice;
  final String userId;
  final String? posterImageUrl; // ✅ 포스터 이미지 URL 필드 추가

  Reservation({
    required this.showId,
    required this.showTitle,
    required this.dateTime,
    required this.section,
    required this.seats,
    required this.totalPrice,
    required this.userId,
    this.posterImageUrl, // ✅ 생성자에도 추가
  });

  Map<String, dynamic> toMap() => {
    "showId": showId,
    "showTitle": showTitle,
    "dateTime": dateTime,
    "section": section,
    "seats": seats,
    "totalPrice": totalPrice,
    "userId": userId,
    "posterImageUrl": posterImageUrl, // ✅ toMap에도 추가
  };
}
