import 'package:flutter/material.dart';
import 'main_hall_seat_initializer.dart'; // ✅ 파일 이름에 맞게 임포트 경로 변경

class MainHallSeatInitializerPage extends StatelessWidget { // ✅ 클래스 이름 GocheokDomeSeatInitializerPage -> MainHallSeatInitializerPage 로 변경
  const MainHallSeatInitializerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('메인홀 좌석 초기화')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // 함수 호출명을 initializeMainHallSeatsByGrade로 변경
            await initializeMainHallSeatsByGrade();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ 좌석 초기화 완료')),
            );
          },
          child: const Text('좌석 데이터 Firebase에 업로드'),
        ),
      ),
    );
  }
}
