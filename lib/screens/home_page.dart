import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login_page.dart';
import 'show/show_list_page.dart';
import 'reservation/reservation_list_page.dart';
import '../admin/admin_venue_setup_page.dart';
import '../admin/admin_show_create_page.dart';
import '../admin/main_hall_seat_initializer_page.dart';
import 'seat_selection/main_hall_canvas_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user?.email == 'admin@example.com'; // 관리자 판별

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          'AquaTicket',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: '로그아웃',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 60),
            const Text(
              '환영합니다!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShowListPage()),
                );
              },
              icon: const Icon(Icons.theaters),
              label: const Text('공연 목록 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReservationListPage()),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('예매 목록 보기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const Spacer(),

            // 관리자 전용 버튼
            if (isAdmin) ...[
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminVenueSetupPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('공연장 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainHallSeatInitializerPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.event_seat),
                label: const Text('메인홀 좌석 초기화'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ✅ 캔버스 좌석도 보기 버튼 (테스트용 더미 데이터 전달 - 실제 예매된 값으로 변경)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainHallCanvasPage(
                        showId: 'HOzESJZICTCIeLvITbGO', // ✅ 실제 예매된 showId
                        showTitle: '테스트', // ✅ 실제 예매된 showTitle
                        selectedDateTime: '2025-06-11 20:00', // ✅ 실제 예매된 dateTime
                        venueId: 'main_hall', // ✅ Firebase에 초기화된 venueId
                        maxTicketsPerUser: 4,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('메인홀 좌석 배치도 보기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminShowCreatePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_business),
                label: const Text('공연 등록'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              '즐거운 관람 되세요 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
