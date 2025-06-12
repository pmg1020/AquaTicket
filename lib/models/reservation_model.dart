class Reservation {
  final String showId;
  final String showTitle; // ✅ showTitle 필드 추가
  final String dateTime;
  final String section;
  final List<String> seats;
  final int totalPrice;
  final String userId;

  Reservation({
    required this.showId,
    required this.showTitle, // ✅ 생성자에도 추가
    required this.dateTime,
    required this.section,
    required this.seats,
    required this.totalPrice,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    "showId": showId,
    "showTitle": showTitle, // ✅ toMap에도 추가
    "dateTime": dateTime,
    "section": section,
    "seats": seats,
    "totalPrice": totalPrice,
    "userId": userId,
  };
}
