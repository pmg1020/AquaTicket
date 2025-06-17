import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReservationDetailPage extends StatefulWidget {
  final Map<String, dynamic> reservation;

  const ReservationDetailPage({super.key, required this.reservation});

  @override
  State<ReservationDetailPage> createState() => _ReservationDetailPageState();
}

class _ReservationDetailPageState extends State<ReservationDetailPage> {
  String? _userNickname;

  @override
  void initState() {
    super.initState();
    _loadUserNickname();
  }

  // ✅ 사용자 닉네임을 Firestore에서 불러오는 함수 (경로 일치)
  Future<void> _loadUserNickname() async {
    final userId = widget.reservation['userId'];
    if (userId != null && userId.isNotEmpty) {
      try {
        // 사용자 정보 조회 경로: users/{userId} (AuthService에서 저장하는 경로와 일치)
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          setState(() {
            _userNickname = userDoc.data()?['nickname'] ?? '알 수 없음';
          });
        } else {
          setState(() {
            _userNickname = '사용자 정보 없음';
          });
        }
      } catch (e) {
        print("닉네임 로딩 오류: $e");
        if (e is FirebaseException) {
          print("Firebase Exception Code (Nickname): ${e.code}");
          print("Firebase Exception Message (Nickname): ${e.message}");
        }
        setState(() {
          _userNickname = '닉네임 불러오기 오류';
        });
      }
    } else {
      setState(() {
        _userNickname = 'ID 없음';
      });
    }
  }

  Future<void> _cancelReservation(BuildContext context) async {
    final reservationId = widget.reservation['id'];
    if (reservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예약 ID가 없어 취소할 수 없습니다.')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예매 취소'),
        content: const Text('정말 이 예매를 취소하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('아니요'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('예, 취소합니다'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final userId = widget.reservation['userId'];
      final appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

      final batch = FirebaseFirestore.instance.batch();

      final reservationDocRef = FirebaseFirestore.instance
          .collection('artifacts')
          .doc(appId)
          .collection('users')
          .doc(userId)
          .collection('reservations')
          .doc(reservationId);
      batch.delete(reservationDocRef);

      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('예매가 성공적으로 취소되었습니다.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      print('예매 취소 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예매 취소 실패: $e')),
      );
    }
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday: return '월';
      case DateTime.tuesday: return '화';
      case DateTime.wednesday: return '수';
      case DateTime.thursday: return '목';
      case DateTime.friday: return '금';
      case DateTime.saturday: return '토';
      case DateTime.sunday: return '일';
      default: return '';
    }
  }

  String _formatSeatNumber(String seatNumber, String sectionName) {
    final parts = seatNumber.split('-');
    if (parts.length == 3) {
      final sectionPrefix = parts[0];
      final row = parts[1];
      final col = parts[2];

      String gradeType;
      String floorInfo = "";

      if (sectionName.startsWith('ZONE')) {
        gradeType = "스탠딩석";
        return "$gradeType $sectionPrefix ${row}열 ${col}번";
      } else {
        gradeType = "일반석";
        floorInfo = "2층 ";
        return "$gradeType $floorInfo${sectionPrefix} 구역 ${row}열 ${col}번";
      }
    }
    return seatNumber;
  }

  @override
  Widget build(BuildContext context) {
    final String showTitle = widget.reservation['showTitle'] ?? '정보 없음';
    final String dateTimeString = widget.reservation['dateTime'] ?? '';
    final String sectionName = widget.reservation['section'] ?? '정보 없음';
    final List<dynamic> rawSeats = widget.reservation['seats'] ?? [];
    final int totalPrice = widget.reservation['totalPrice'] ?? 0;
    final reservedAtTimestamp = widget.reservation['reservedAt'] as Timestamp?;
    final reservedAt = reservedAtTimestamp?.toDate();

    String displayDateTime = '정보 없음';
    if (dateTimeString.isNotEmpty) {
      try {
        final parsedDateTime = DateTime.parse(dateTimeString.replaceAll(' ', 'T'));
        final formattedDate = DateFormat('yyyy년 MM월 dd일').format(parsedDateTime);
        final formattedTime = DateFormat('HH시mm분').format(parsedDateTime);
        final dayOfWeek = _getDayOfWeek(parsedDateTime.weekday);
        displayDateTime = '$formattedDate ($dayOfWeek) $formattedTime';
      } catch (e) {
        print("예매 일시 파싱 오류: $e");
        displayDateTime = dateTimeString;
      }
    }

    final formattedSeats = rawSeats.map((seatNum) => _formatSeatNumber(seatNum as String, sectionName)).join(',\n');
    final String numberOfSeats = rawSeats.length.toString();

    bool isPast = false;
    if (dateTimeString.isNotEmpty) {
      try {
        final showStartDateTime = DateTime.parse(dateTimeString.replaceAll(' ', 'T'));
        isPast = showStartDateTime.isBefore(DateTime.now());
      } catch (e) {
        print("공연 시작 시간 파싱 오류 (취소 버튼 로직): $e");
        isPast = false;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('예매 상세 내역'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "예매 정보",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _infoRow('공연 제목', showTitle),
            _infoRow('공연 일시', displayDateTime),
            _infoRow('선택 구역', sectionName),
            _infoRow('좌석 수', '$numberOfSeats석'),
            _infoRow('좌석 번호', formattedSeats),
            _infoRow('총 결제 금액', '${NumberFormat('#,###', 'ko_KR').format(totalPrice)}원'),
            _infoRow('예매자 닉네임', _userNickname ?? '로딩 중...'),
            _infoRow('예매 일시', reservedAt?.toString().substring(0, 19) ?? 'N/A'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPast ? null : () => _cancelReservation(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPast ? Colors.grey : Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isPast ? '취소 불가 (공연 종료)' : '예매 취소',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }
}
