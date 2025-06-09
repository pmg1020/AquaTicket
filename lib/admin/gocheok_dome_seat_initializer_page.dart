import 'package:flutter/material.dart';
import 'gocheok_dome_seat_initializer.dart';

class GocheokDomeSeatInitializerPage extends StatelessWidget {
  const GocheokDomeSeatInitializerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('고척돔 좌석 초기화')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await initializeGocheokDomeSeatsByGrade(); // 함수명이 이것이라면
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
