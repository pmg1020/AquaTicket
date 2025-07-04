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

  Future<void> _loadUserNickname() async {
    final userId = widget.reservation['userId'];
    final String appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

    print("Debug UserProfile: Attempting to load nickname for userId: $userId, appId: $appId");

    if (userId != null && userId.isNotEmpty) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('artifacts')
            .doc(appId)
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          final userDataMap = userDoc.data() as Map<String, dynamic>?;
          _userNickname = userDataMap?['nickname'] ?? '알 수 없음';
          print("Debug UserProfile: Nickname loaded: $_userNickname");
          print("Debug UserProfile: Full user data from Firestore: $userDataMap");
        } else {
          _userNickname = '사용자 정보 없음';
          print("Debug UserProfile: User document not found at artifacts/$appId/users/$userId.");
        }
      } catch (e) {
        _userNickname = '닉네임 불러오기 오류';
        print("Debug UserProfile: 닉네임 로딩 오류 발생: $e");
        if (e is FirebaseException) {
          print("Debug UserProfile: Firebase Exception Code (Nickname): ${e.code}");
          print("Debug UserProfile: Firebase Exception Message (Nickname): ${e.message}");
        }
      }
    } else {
      _userNickname = 'ID 없음';
      print("Debug UserProfile: userId is null or empty for reservation.");
    }

    if (mounted) {
      setState(() {
        // _isLoading 상태는 이 위젯에서 사용되지 않으므로 제거합니다.
        // 대신 _userNickname 값의 유무로 로딩 상태를 판단합니다.
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

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(amount);
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
            _buildInfoRow('공연 제목', showTitle),
            _buildInfoRow('공연 일시', displayDateTime),
            _buildInfoRow('선택 구역', sectionName),
            _buildInfoRow('좌석 수', '$numberOfSeats석'),
            _buildInfoRow('좌석 번호', formattedSeats),
            _buildInfoRow('총 결제 금액', '${_formatCurrency(totalPrice)}원'),
            _buildInfoRow('예매자 닉네임', _userNickname ?? '로딩 중...'), // ✅ _userNickname 사용
            _buildInfoRow('예매 일시', reservedAt?.toString().substring(0, 19) ?? 'N/A'),
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
