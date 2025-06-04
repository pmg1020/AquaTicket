import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/show.dart'; // Show 모델 정의 위치
import '../../screens/seat_selection/show_time_selector.dart';
import '../../screens/seat_selection/captcha_dialog.dart';
import '../../screens/seat_selection/section_selection_page.dart'; // 다음 단계에서 만들 파일

class ReservePage extends StatelessWidget {
  final Show show; // Firestore에서 받아온 Show 정보

  const ReservePage({super.key, required this.show});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('예매하기')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(show.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Text("공연 장소: ${show.location}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 40),
            Center(
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
                              builder: (context) => SectionSelectionPage(
                                showId: show.id,
                                selectedDateTime: selectedTime,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                child: const Text("예매하기"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
