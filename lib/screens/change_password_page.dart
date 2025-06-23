import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showSnackBar('로그인된 사용자가 없습니다.');
      return;
    }

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmNewPassword.isEmpty) {
      _showSnackBar('모든 필드를 입력해주세요.');
      return;
    }

    if (newPassword.length < 6) {
      _showSnackBar('새 비밀번호는 최소 6자 이상이어야 합니다.');
      return;
    }

    if (newPassword != confirmNewPassword) {
      _showSnackBar('새 비밀번호가 일치하지 않습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. 현재 비밀번호로 재인증 (필수)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!, // 현재 사용자 이메일 사용
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // 2. 새 비밀번호로 업데이트
      await user.updatePassword(newPassword);

      _showSnackBar('✅ 비밀번호가 성공적으로 변경되었습니다!');
      Navigator.pop(context); // 이전 페이지로 돌아가기
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = '현재 비밀번호가 올바르지 않습니다.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = '로그인 시도 횟수가 너무 많습니다. 잠시 후 다시 시도해주세요.';
      } else if (e.code == 'weak-password') {
        errorMessage = '새 비밀번호가 너무 약합니다.';
      } else {
        errorMessage = '비밀번호 변경 실패: ${e.message}';
      }
      _showSnackBar(errorMessage);
    } catch (e) {
      _showSnackBar('예상치 못한 오류 발생: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '비밀번호 변경',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text(
                '비밀번호 재설정',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '현재 비밀번호',
                  hintText: '현재 비밀번호를 입력하세요',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호',
                  hintText: '새 비밀번호를 입력하세요 (최소 6자)',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmNewPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '새 비밀번호 확인',
                  hintText: '새 비밀번호를 다시 입력하세요',
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('비밀번호 변경', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
