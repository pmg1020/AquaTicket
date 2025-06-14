import 'package:flutter/material.dart';
import '../../services/reservation_service.dart';
import '../../models/reservation_model.dart';
import 'package:intl/intl.dart'; // 통화 및 날짜 포맷팅을 위해 intl 패키지 필요
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth 임포트

class ReservationConfirmationPage extends StatefulWidget {
  final String showId;
  final String showTitle;
  final String selectedDateTime;
  final String sectionName;
  final List<String> selectedSeats;
  final int totalPrice;

  const ReservationConfirmationPage({
    super.key,
    required this.showId,
    required this.showTitle,
    required this.selectedDateTime,
    required this.sectionName,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  State<ReservationConfirmationPage> createState() => _ReservationConfirmationPageState();
}

class _ReservationConfirmationPageState extends State<ReservationConfirmationPage> {
  final ReservationService _reservationService = ReservationService();
  bool _isReserving = false;

  Future<void> _processReservation() async {
    setState(() {
      _isReserving = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser; // ✅ 현재 사용자 UID 가져오기
      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다. 예매를 진행할 수 없습니다.");
      }

      final reservation = Reservation(
        showId: widget.showId,
        showTitle: widget.showTitle,
        dateTime: widget.selectedDateTime,
        section: widget.sectionName,
        seats: widget.selectedSeats,
        totalPrice: widget.totalPrice,
        userId: currentUser.uid, // ✅ 현재 사용자 UID 사용
      );

      await _reservationService.reserveSeats(reservation);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 예매가 완료되었습니다!')),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      print("예매 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예매 실패: $e')),
      );
    } finally {
      setState(() {
        _isReserving = false;
      });
    }
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(amount);
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return '월';
      case DateTime.tuesday:
        return '화';
      case DateTime.wednesday:
        return '수';
      case DateTime.thursday:
        return '목';
      case DateTime.friday:
        return '금';
      case DateTime.saturday:
        return '토';
      case DateTime.sunday:
        return '일';
      default:
        return '';
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
    DateTime parsedDateTime = DateTime.parse(widget.selectedDateTime.replaceAll(' ', 'T'));
    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(parsedDateTime);
    final formattedTime = DateFormat('HH시mm분').format(parsedDateTime);
    final dayOfWeek = _getDayOfWeek(parsedDateTime.weekday);
    final displayDateTime = '$formattedDate ($dayOfWeek) $formattedTime';

    return Scaffold(
      appBar: AppBar(
        title: const Text("예매 확인 및 결제"),
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
              "예매 상세 정보",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildInfoRow("공연 제목", widget.showTitle),
            _buildInfoRow("공연 일시", displayDateTime),
            _buildInfoRow("선택 구역", widget.sectionName),
            _buildInfoRow("선택 좌석 수", "${widget.selectedSeats.length}석"),
            _buildInfoRow(
              "좌석 번호",
              widget.selectedSeats.map((seatNum) => _formatSeatNumber(seatNum, widget.sectionName)).join(',\n'),
            ),
            const Divider(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "총 결제 금액",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatCurrency(widget.totalPrice) + "원",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isReserving ? null : _processReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isReserving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "결제하기",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
