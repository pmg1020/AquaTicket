import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 intl 패키지 필요
import '../../models/show.dart';
import '../seat_selection/show_time_selector.dart';
import '../seat_selection/captcha_dialog.dart';
import '../seat_selection/main_hall_canvas_page.dart'; // MainHallCanvasPage 임포트

class ShowDetailPage extends StatelessWidget {
  final Show show;

  const ShowDetailPage({super.key, required this.show});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          show.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.event, size: 80, color: Colors.black87),
            ),
            const SizedBox(height: 32),
            Text(
              show.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.category, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '유형: ${show.type}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.place, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '장소: ${show.location}',
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // 예매 가능 최대 수 추가
            Row(
              children: [
                const Icon(Icons.confirmation_num, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '예매 가능 최대 수: ${show.maxTicketsPerUser}매',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('날짜:', style: TextStyle(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 4),
                // 날짜 포맷팅 수정
                ...show.date.map((dateString) {
                  try {
                    final dateTime = DateTime.parse(dateString);
                    final formattedDate = DateFormat('yyyy년 MM월 dd일').format(dateTime);
                    final formattedTime = DateFormat('HH시mm분').format(dateTime);
                    final dayOfWeek = _getDayOfWeek(dateTime.weekday);
                    return Padding(
                      padding: const EdgeInsets.only(left: 28.0), // 아이콘과 같은 들여쓰기
                      child: Text(
                        '$formattedDate ($dayOfWeek) $formattedTime',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  } catch (e) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Text(
                        dateString, // 파싱 실패 시 원본 문자열 표시
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                      ),
                    );
                  }
                }).toList(),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showShowTimePicker(
                    context: context,
                    showId: show.id,
                    onTimeSelected: (selectedTime) {
                      showCaptchaDialog(
                        context: context,
                        onVerified: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainHallCanvasPage(
                                showId: show.id,
                                showTitle: show.title,
                                selectedDateTime: selectedTime,
                                venueId: show.venueId,
                                maxTicketsPerUser: show.maxTicketsPerUser, // show 데이터에서 가져온 값 전달
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('예매하기', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
