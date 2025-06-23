import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/auth_service.dart'; // AuthService 임포트 확인
import 'package:uuid/uuid.dart'; // UUID 사용 시 필요
import '/screens/home_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService(); // ✅ 인스턴스 선언

  Future<void> signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요')),
      );
      return;
    }

    try {
      // ✅ _authService 인스턴스를 사용하여 로그인
      await _authService.signIn(email, password); // AuthService에 signIn 메서드가 있다고 가정

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인 성공')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = '로그인 실패: 다시 시도해주세요.';
      if (e.code == 'user-not-found') {
        errorMessage = '등록되지 않은 이메일입니다.';
      } else if (e.code == 'wrong-password') {
        errorMessage = '비밀번호가 일치하지 않습니다.';
      } else if (e.code == 'invalid-email') {
        errorMessage = '유효하지 않은 이메일 형식입니다.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('예상치 못한 오류 발생: $e')),
      );
    }
  }

  // UUID 테스트용 함수 (필요 없을 시 제거 가능)
  void generateUUID() {
    var uuid = const Uuid();
    String newUuid = uuid.v4();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generated UUID: $newUuid')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          '로그인',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'AquaTicket',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 48),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: '이메일',
                  hintText: 'user@example.com',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('로그인'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                child: const Text('회원가입하기', style: TextStyle(color: Colors.black87)),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: generateUUID,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("🧪 UUID 테스트"),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
