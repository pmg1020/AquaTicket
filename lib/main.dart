import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart'; // 날짜 포맷팅 초기화를 위해 추가

import 'firebase_options.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

void main() async {
  // Flutter 엔진과 위젯 바인딩이 초기화되었는지 확인합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 앱을 초기화합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 사용할 로케일의 날짜 포맷팅 데이터를 초기화합니다.
  // 'ko_KR'은 한국어를 의미합니다. 다른 로케일을 사용한다면 해당 코드로 변경하세요.
  await initializeDateFormatting('ko_KR', null);
  // 필요하다면 다른 로케일도 초기화할 수 있습니다.
  // await initializeDateFormatting('en_US', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AquaTicket',
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      theme: ThemeData(primarySwatch: Colors.blue),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Firebase 인증 상태 스트림
        builder: (context, snapshot) {
          // 연결 상태 확인
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중이면 중앙에 원형 프로그레스 바 표시
            return const Center(child: CircularProgressIndicator());
          }
          // 인증 데이터가 있는지 (로그인 상태인지) 확인
          else if (snapshot.hasData) {
            // 로그인 상태이면 HomePage로 이동
            return const HomePage();
          }
          // 인증 데이터가 없으면 (비로그인 상태이면)
          else {
            // 비로그인 상태이면 LoginPage로 이동
            return const LoginPage();
          }
        },
      ),
    );
  }
}
