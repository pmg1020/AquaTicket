import 'package:flutter/material.dart';
import '../../services/reservation_service.dart';
import '../../models/reservation_model.dart';
import 'package:intl/intl.dart'; // 통화 및 날짜 포맷팅을 위해 intl 패키지 필요

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
      final reservation = Reservation(
        showId: widget.showId,
        showTitle: widget.showTitle, // showTitle 포함
        dateTime: widget.selectedDateTime,
        section: widget.sectionName,
        seats: widget.selectedSeats,
        totalPrice: widget.totalPrice,
        userId: '', // 실제 사용자 ID는 서비스 내에서 가져옴
      );

      await _reservationService.reserveSeats(reservation);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ 예매가 완료되었습니다!')),
      );

      // 예매 완료 후 홈 또는 예매 내역 페이지로 이동
      Navigator.popUntil(context, (route) => route.isFirst); // 모든 스택 제거 후 홈으로
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReservationListPage())); // 예매 내역 페이지로 이동
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

  // 통화 포맷터 (pubspec.yaml에 intl: ^0.18.0 또는 최신 버전 추가 필요)
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(amount);
  }

  // 요일 변환 헬퍼 함수
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

  // 좌석 번호 포맷팅 헬퍼 함수
  String _formatSeatNumber(String seatNumber, String sectionName) {
    // 예: "N-1-10" -> "일반석 2층 N 구역 1열 10번"
    // 예: "ZONE1-1-16" -> "스탠딩석 ZONE 1열 16번"
    final parts = seatNumber.split('-');
    if (parts.length == 3) {
      final sectionPrefix = parts[0];
      final row = parts[1];
      final col = parts[2];

      String gradeType;
      String floorInfo = ""; // 층 정보

      // 섹션 이름 규칙에 따라 등급과 층 정보 분류
      if (sectionName.startsWith('ZONE')) {
        gradeType = "스탠딩석";
        // 스탠딩석은 "ZONE1-행-열" 형식으로 오므로, "ZONE1 1열 16번"으로 표시
        return "$gradeType $sectionPrefix ${row}열 ${col}번";
      } else {
        // 2층 외곽 좌석은 'NORMAL_2F' 등급이 부여되지만, 여기서는 섹션 이름으로 판단
        gradeType = "일반석";
        floorInfo = "2층 "; // 일반석은 2층이라고 가정
        // "N-1-10" -> "일반석 2층 N 구역 1열 10번"
        return "$gradeType $floorInfo${sectionPrefix} 구역 ${row}열 ${col}번";
      }
    }
    return seatNumber; // 형식이 맞지 않으면 원본 반환
  }

  @override
  Widget build(BuildContext context) {
    // selectedDateTime을 DateTime 객체로 파싱하고 포맷팅
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
            _buildInfoRow("공연 일시", displayDateTime), // 포맷팅된 시간 사용
            _buildInfoRow("선택 구역", widget.sectionName),
            _buildInfoRow("선택 좌석 수", "${widget.selectedSeats.length}석"),
            // 좌석 번호 포맷팅 적용
            _buildInfoRow(
              "좌석 번호",
              // 각 좌석 번호를 포맷팅하고 줄 바꿈으로 여러 좌석 표시
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
            width: 100, // 라벨 너비 고정
            child: Text(
              "$label:",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.visible, // 텍스트 오버플로우 시 줄바꿈 등 처리
            ),
          ),
        ],
      ),
    );
  }
}
