import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/show.dart';
import '../seat_selection/show_time_selector.dart';
import '../seat_selection/captcha_dialog.dart';
import '../seat_selection/main_hall_canvas_page.dart';

class ShowDetailPage extends StatelessWidget {
  final Show show;

  const ShowDetailPage({super.key, required this.show});

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

  // 통화 포맷터 헬퍼 함수
  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(amount);
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.0, 24.0, 24.0, MediaQuery.of(context).padding.bottom + 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 180,
                  height: 240,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: show.posterImageUrl != null && show.posterImageUrl!.isNotEmpty
                      ? Image.network(
                    show.posterImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.broken_image, size: 80, color: Colors.grey[400]);
                    },
                  )
                      : Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
                ),
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
              // ✅ 기본 가격 표시 추가
              Row(
                children: [
                  const Icon(Icons.monetization_on, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '기본 좌석 가격: ${_formatCurrency(show.basePrice)}원',
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
                  ...show.date.map((dateString) {
                    try {
                      final dateTime = DateTime.parse(dateString.replaceFirst(' ', 'T'));
                      final formattedDate = DateFormat('yyyy년 MM월 dd일').format(dateTime);
                      final formattedTime = DateFormat('HH시mm분').format(dateTime);
                      final dayOfWeek = _getDayOfWeek(dateTime.weekday);
                      return Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(
                          '$formattedDate ($dayOfWeek) $formattedTime',
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    } catch (e) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 28.0),
                        child: Text(
                          dateString,
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                      );
                    }
                  }).toList(),
                ],
              ),
              const SizedBox(height: 24),
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
                                  maxTicketsPerUser: show.maxTicketsPerUser,
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
      ),
    );
  }
}
