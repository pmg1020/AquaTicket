import 'package:flutter/material.dart';

class GocheokDomePainter extends CustomPainter {
  final String? selectedSection;
  final Function(String) onSectionTap;

  GocheokDomePainter({required this.selectedSection, required this.onSectionTap});

  // 섹션 정의
  final List<Map<String, dynamic>> sections = [
    {
      'name': '플로어',
      'color': Colors.orange,
      'rect': Rect.fromLTWH(80, 150, 160, 80),
    },
    {
      'name': 'VIP',
      'color': Colors.purple,
      'rect': Rect.fromLTWH(120, 250, 80, 60),
    },
    {
      'name': 'R석',
      'color': Colors.red,
      'rect': Rect.fromLTWH(50, 320, 100, 60),
    },
    {
      'name': 'S석',
      'color': Colors.blue,
      'rect': Rect.fromLTWH(150, 320, 100, 60),
    },
    {
      'name': 'A석',
      'color': Colors.green,
      'rect': Rect.fromLTWH(100, 400, 120, 70),
    },
    {
      'name': '3층',
      'color': Colors.grey,
      'rect': Rect.fromLTWH(80, 490, 160, 50),
    },
  ];

  final Map<String, Path> sectionPaths = {}; // 섹션별 Path 저장

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final textPainter = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    sectionPaths.clear(); // 매 프레임마다 초기화

    for (var section in sections) {
      final name = section['name'] as String;
      final color = section['color'] as Color;
      final rect = section['rect'] as Rect;

      // Path 생성 및 저장
      final path = Path()..addRect(rect);
      sectionPaths[name] = path;

      // 좌석 영역 색칠
      paint.color = color;
      canvas.drawPath(path, paint);

      // 선택되었을 경우 테두리
      if (name == selectedSection) {
        canvas.drawPath(
          path,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }

      // 텍스트 표시
      textPainter.text = TextSpan(
        text: name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      );
      textPainter.layout(minWidth: rect.width);
      textPainter.paint(
        canvas,
        Offset(
          rect.left + (rect.width - textPainter.width) / 2,
          rect.top + (rect.height - textPainter.height) / 2,
        ),
      );
    }

    // 무대 텍스트
    textPainter.text = const TextSpan(
      text: "STAGE",
      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(120, 100));
  }

  @override
  bool shouldRepaint(covariant GocheokDomePainter oldDelegate) {
    return oldDelegate.selectedSection != selectedSection;
  }

  /// 클릭한 위치가 어떤 구역인지 반환
  String? detectSection(Offset position) {
    for (var entry in sectionPaths.entries) {
      if (entry.value.contains(position)) {
        return entry.key;
      }
    }
    return null;
  }
}
