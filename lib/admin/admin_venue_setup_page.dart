import 'package:flutter/material.dart';
import 'package:aquaticket/admin/venue_initializer.dart'; // ✅ 이 줄 추가

class AdminVenueSetupPage extends StatelessWidget {
  const AdminVenueSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("공연장 초기화")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await initializeVenues();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("공연장 등록 완료")),
            );
          },
          child: const Text("🎫 공연장 데이터 Firestore에 등록"),
        ),
      ),
    );
  }
}
