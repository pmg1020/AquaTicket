import 'dart:math';
import 'package:flutter/material.dart';

void showCaptchaDialog({
  required BuildContext context,
  required VoidCallback onVerified,
}) {
  final String captcha = _generateRandomCaptcha(6);
  final TextEditingController controller = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("인증예매"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("부정예매 방지를 위해 보안문자를 정확히 입력해주세요."),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[200],
              child: Text(
                captcha,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              onChanged: (value) {
                // 입력 시 자동으로 대문자로 변환
                controller.value = controller.value.copyWith(
                  text: value.toUpperCase(),
                  selection: TextSelection.collapsed(offset: value.length),
                );
              },
              decoration: const InputDecoration(
                hintText: "보안문자를 입력하세요",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: const Text("취소"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.toUpperCase() == captcha) {
                Navigator.of(context).pop(); // 다이얼로그 닫기
                onVerified(); // 인증 성공 콜백 실행
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("보안문자가 일치하지 않습니다.")),
                );
              }
            },
            child: const Text("입력 완료"),
          ),
        ],
      );
    },
  );
}

String _generateRandomCaptcha(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; // 숫자 제거
  final rand = Random();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}
