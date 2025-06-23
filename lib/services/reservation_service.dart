import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';
import '../models/show.dart'; // Show 모델 임포트 (posterImageUrl 가져오기 위함)

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이전에 사용되었던 'reserve' 메서드는 현재 'reserveSeats'로 대체되었으므로 제거합니다.
  // 만약 다른 곳에서 여전히 'reserve'를 사용한다면 이 메서드를 복원해야 합니다.
  /*
  Future<void> reserve({
    required String showId,
    required String showTitle,
    required String date,
    required int people,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    await _firestore.collection('reservations').add({
      'userId': user.uid,
      'showId': showId,
      'showTitle': showTitle,
      'date': date,
      'people': people,
      'reservedAt': FieldValue.serverTimestamp(),
    });
  }
  */

  // 새로운 예매 메서드: 개별 좌석을 업데이트하고 예매 정보를 저장
  Future<void> reserveSeats(Reservation reservation) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
    final String userId = user.uid;

    final batch = _firestore.batch();

    // Show ID를 통해 posterImageUrl을 가져옵니다.
    final showDoc = await _firestore.collection('shows').doc(reservation.showId).get();
    final String? showPosterImageUrl = showDoc.data()?['posterImageUrl'] as String?;

    // Show ID를 통해 venueId를 가져옵니다. (기존 로직 유지)
    final String? venueId = showDoc.data()?['venueId'] as String?;
    if (venueId == null) {
      throw Exception("공연 정보에서 공연장 ID를 찾을 수 없습니다.");
    }

    // 좌석 문서의 isReserved 상태를 업데이트하는 로직은 현재 모델에서 제거되었으므로,
    // 이전에 주석 처리된 해당 코드 블록도 제거합니다.

    final userReservationCollectionRef = _firestore
        .collection('artifacts')
        .doc(appId)
        .collection('users')
        .doc(userId)
        .collection('reservations');

    batch.set(userReservationCollectionRef.doc(), {
      'userId': userId,
      'showId': reservation.showId,
      'showTitle': reservation.showTitle,
      'dateTime': reservation.dateTime,
      'section': reservation.section,
      'seats': reservation.seats,
      'totalPrice': reservation.totalPrice,
      'reservedAt': FieldValue.serverTimestamp(),
      'posterImageUrl': showPosterImageUrl, // posterImageUrl 저장
    });

    await batch.commit();
    print("Debug ReserveSeats: Reservation batch committed successfully.");
  }

  // 예매 조회
  Future<List<Map<String, dynamic>>> getMyReservations() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("로그인된 사용자가 없어 예매 내역을 불러올 수 없습니다.");
      return [];
    }

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
    final String userId = user.uid;

    try {
      final snapshot = await _firestore
          .collection('artifacts')
          .doc(appId)
          .collection('users')
          .doc(userId)
          .collection('reservations')
          .orderBy('reservedAt', descending: true)
          .get();

      print("Debug GetMyReservations: 불러온 예매 내역 수: ${snapshot.docs.length}");
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("Debug GetMyReservations: 예매 내역 불러오기 오류: $e");
      if (e is FirebaseException) {
        print("Debug GetMyReservations: Firebase Exception Code: ${e.code}");
        print("Debug GetMyReservations: Firebase Exception Message: ${e.message}");
      }
      return [];
    }
  }
}
