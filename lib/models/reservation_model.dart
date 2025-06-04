class Reservation {
  final String showId;
  final String dateTime;
  final String section;
  final List<String> seats;
  final int totalPrice;
  final String userId;

  Reservation({
    required this.showId,
    required this.dateTime,
    required this.section,
    required this.seats,
    required this.totalPrice,
    required this.userId,
  });

  Map<String, dynamic> toMap() => {
    "showId": showId,
    "dateTime": dateTime,
    "section": section,
    "seats": seats,
    "totalPrice": totalPrice,
    "userId": userId,
  };
}