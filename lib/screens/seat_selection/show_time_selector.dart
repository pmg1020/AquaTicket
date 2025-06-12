import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 intl 패키지 필요

void showShowTimePicker({
  required BuildContext context,
  required String showId,
  required Function(String selectedTime) onTimeSelected,
}) async {
  final doc = await FirebaseFirestore.instance
      .collection('shows')
      .doc(showId)
      .get();

  if (!doc.exists) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공연 정보를 불러오지 못했습니다.')),
    );
    return;
  }

  final data = doc.data();
  if (data == null || data['date'] == null) return;

  final List<dynamic> rawDates = data['date'];
  final List<String> showTimes = rawDates.cast<String>();

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

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text("회차를 선택해주세요", style: TextStyle(fontSize: 18)),
          const Divider(),
          ...showTimes.map((timeString) {
            DateTime dateTime;
            String formattedDisplay;
            try {
              dateTime = DateTime.parse(timeString);
              final formattedDate = DateFormat('yyyy년 MM월 dd일').format(dateTime);
              final formattedTime = DateFormat('HH시mm분').format(dateTime);
              final dayOfWeek = _getDayOfWeek(dateTime.weekday);
              formattedDisplay = '$formattedDate ($dayOfWeek) $formattedTime';
            } catch (e) {
              formattedDisplay = timeString; // 파싱 실패 시 원본 문자열 표시
            }

            return ListTile(
              title: Text(formattedDisplay),
              onTap: () {
                Navigator.pop(context);
                onTimeSelected(timeString); // 원본 시간 문자열을 콜백으로 전달
              },
            );
          }).toList(),
        ],
      );
    },
  );
}
