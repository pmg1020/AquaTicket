import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      theme: ThemeData(
        // ✅ 기본 primarySwatch를 무채색 계열로 변경 (테마의 기본 색상 영향 최소화)
          primarySwatch: Colors.grey, // 기본 파란색 대신 회색 계열로 변경하여 보라색 영향 최소화

          // ✅ ColorScheme을 명시적으로 정의하여 앱의 주요 색상을 제어
          colorScheme: const ColorScheme.light(
            primary: Colors.black, // 기본 강조색을 검은색으로
            onPrimary: Colors.white, // 검은색 위에 올라올 색상 (텍스트 등)
            secondary: Colors.grey, // 보조 색상 (필요시 조정)
            onSecondary: Colors.white,
            surface: Colors.white, // 카드, 시트 등의 표면 색상
            onSurface: Colors.black, // 표면 위에 올라올 텍스트 등
            background: Colors.white, // 기본 배경색
            onBackground: Colors.black,
            error: Colors.red,
            onError: Colors.white,
          ),

          // ✅ TextField의 기본 스타일을 전역적으로 제어 (연보라색 밑줄/포커스 제거)
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            // 포커스 시 테두리 색상 명시적 제어
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2.0), // 포커스 시 검은색 테두리
            ),
            // 활성 상태의 테두리 색상 (포커스 되지 않았지만 활성화된 상태)
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1.0), // 활성화 시 얇은 회색 테두리
            ),
            // 에러 상태의 테두리 색상
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            // 포커스 된 에러 상태의 테두리 색상
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2.0),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            // 텍스트 필드 내부의 커서 색상도 제어
            // cursorColor: Colors.black, // 이 값을 사용하면 커서가 검은색이 됩니다.
          ),
          // ✅ TextSelectionTheme을 사용하여 텍스트 선택 핸들 및 커서 색상 제어
          textSelectionTheme: const TextSelectionThemeData(
            cursorColor: Colors.black, // 커서 색상
            selectionColor: Colors.grey, // 선택된 텍스트 배경색 (너무 어둡지 않게)
            selectionHandleColor: Colors.black, // 텍스트 선택 핸들 색상
          )
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), // Firebase 인증 상태 스트림
        builder: (context, snapshot) {
          // 연결 상태 확인
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 로딩 중이면 중앙에 원형 프로그레스 바 표시
            return const Center(child: CircularProgressIndicator(color: Colors.black)); // ✅ 로딩바 색상 명시
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
