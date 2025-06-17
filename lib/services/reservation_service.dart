import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart';

class ReservationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 기존 reserve 메서드는 그대로 둡니다 (혹시 다른 곳에서 사용될 수 있으므로)
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

  // 새로운 예매 메서드: 개별 좌석을 업데이트하고 예매 정보를 저장
  Future<void> reserveSeats(Reservation reservation) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("로그인된 사용자가 없습니다.");

    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');
    final String userId = user.uid;

    final batch = _firestore.batch();

    // Show ID를 통해 venueId를 가져옵니다.
    final showDoc = await _firestore.collection('shows').doc(reservation.showId).get();
    final venueId = showDoc.data()?['venueId'] as String?;
    if (venueId == null) {
      throw Exception("공연 정보에서 공연장 ID를 찾을 수 없습니다.");
    }

    // ⛔️ 중요: 좌석 문서의 isReserved 상태를 업데이트하는 로직을 제거했습니다.
    // 예약 상태는 이제 reservations 컬렉션의 데이터 존재 여부로 판단합니다.
    /*
    for (String seatNumber in reservation.seats) {
      final parts = seatNumber.split('-');
      if (parts.length < 3) {
        throw Exception("잘못된 좌석 번호 형식: $seatNumber");
      }
      final sectionName = parts[0];

      final seatRef = _firestore
          .collection('venues')
          .doc(venueId)
          .collection('sections')
          .doc(sectionName)
          .collection('seats')
          .doc(seatNumber);

      final seatSnapshot = await seatRef.get();
      if (seatSnapshot.exists && (seatSnapshot.data()?['isReserved'] == true)) {
        throw Exception("선택하신 좌석 $seatNumber는 이미 예약되었습니다. 다시 시도해주세요.");
      }

      batch.update(seatRef, {
        'isReserved': true,
        'reservedBy': userId,
        'reservationTime': FieldValue.serverTimestamp(),
        'showId': reservation.showId,
        'selectedDateTime': reservation.dateTime,
      });
    }
    */

    // 2. 사용자별 reservations 컬렉션에 예매 정보 추가
    // 경로를 artifacts/{appId}/users/{userId}/reservations 로 변경
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
    });

    await batch.commit(); // 모든 배치 작업 원자적으로 실행
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

      print("불러온 예매 내역 수: ${snapshot.docs.length}");
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print("예매 내역 불러오기 오류: $e");
      return [];
    }
  }
}
