import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/reservation_model.dart'; // Reservation 모델 임포트

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

    final batch = _firestore.batch(); // 배치 쓰기 시작

    // Show ID를 통해 venueId를 가져옵니다.
    final showDoc = await _firestore.collection('shows').doc(reservation.showId).get();
    final venueId = showDoc.data()?['venueId'] as String?;
    if (venueId == null) {
      throw Exception("공연 정보에서 공연장 ID를 찾을 수 없습니다.");
    }

    // 1. 선택된 각 좌석의 isReserved 상태를 true로 업데이트
    for (String seatNumber in reservation.seats) {
      // seatNumber 형식: "ZONE1-1-1" 또는 "I-1-1" 등
      final parts = seatNumber.split('-');
      if (parts.length < 3) {
        throw Exception("잘못된 좌석 번호 형식: $seatNumber");
      }
      final sectionName = parts[0];


      final seatRef = _firestore
          .collection('venues')
          .doc(venueId) // 실제 venueId 사용
          .collection('sections')
          .doc(sectionName)
          .collection('seats')
          .doc(seatNumber);

      // 이미 예약된 좌석인지 한 번 더 확인 (경쟁 조건 방지)
      final seatSnapshot = await seatRef.get();
      if (seatSnapshot.exists && (seatSnapshot.data()?['isReserved'] == true)) {
        throw Exception("선택하신 좌석 $seatNumber는 이미 예약되었습니다. 다시 시도해주세요.");
      }

      batch.update(seatRef, {
        'isReserved': true,
        'reservedBy': user.uid,
        'reservationTime': FieldValue.serverTimestamp(),
        'showId': reservation.showId,
        'selectedDateTime': reservation.dateTime,
      });
    }

    // 2. reservation 컬렉션에 예매 정보 추가
    // Reservation 모델의 toMap() 메서드를 사용
    batch.set(_firestore.collection('reservations').doc(), reservation.toMap());


    await batch.commit(); // 모든 배치 작업 원자적으로 실행
  }

  // 예매 조회
  Future<List<Map<String, dynamic>>> getMyReservations() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('로그인이 필요합니다.');

    final snapshot = await _firestore
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .orderBy('reservedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id; // 🔥 문서 ID 추가
      return data;
    }).toList();
  }
}
