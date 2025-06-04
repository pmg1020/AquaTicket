// 1단계: 기본 틀과 영역 Path 정의
import 'package:flutter/material.dart';

class GocheokDomePainter extends CustomPainter {
  final String? selectedSection;

  GocheokDomePainter({this.selectedSection});

  final Map<String, Path> sectionPaths = {};
  final Map<String, Color> sectionColors = {
    'VIP석': Colors.pink,
    'SR석': Colors.green,
    'R석1층': Colors.indigo.shade900,
    'R석2층': Colors.blue.shade300,
    'S석': Colors.teal,
    'A석': Colors.amber,
  };

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    sectionPaths.clear();

    // 예시 Path 정의: 영역은 추후 실제 위치에 맞게 보정
    final vipRect = Path()
      ..addRect(Rect.fromLTWH(size.width / 2 - 50, 100, 100, 60));
    final srLeft = Path()
      ..addRect(Rect.fromLTWH(40, 180, 60, 60));
    final srRight = Path()
      ..addRect(Rect.fromLTWH(size.width - 100, 180, 60, 60));
    final r1 = Path()
      ..addRect(Rect.fromLTWH(20, 260, 80, 40));
    final r2 = Path()
      ..addRect(Rect.fromLTWH(size.width - 100, 260, 80, 40));
    final s = Path()
      ..addRect(Rect.fromLTWH(100, 340, 160, 40));
    final a = Path()
      ..addRect(Rect.fromLTWH(60, 400, 240, 40));

    // 매핑
    sectionPaths['VIP석'] = vipRect;
    sectionPaths['SR석'] = srLeft..addPath(srRight, Offset.zero);
    sectionPaths['R석1층'] = r1;
    sectionPaths['R석2층'] = r2;
    sectionPaths['S석'] = s;
    sectionPaths['A석'] = a;

    sectionPaths.forEach((name, path) {
      paint.color = sectionColors[name] ?? Colors.grey;
      canvas.drawPath(path, paint);

      if (selectedSection == name) {
        final border = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawPath(path, border);
      }

      // 텍스트 중앙 표시
      final bounds = path.getBounds();
      textPainter.text = TextSpan(
        text: name,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
      textPainter.layout(minWidth: bounds.width);
      textPainter.paint(
        canvas,
        Offset(bounds.left + (bounds.width - textPainter.width) / 2,
            bounds.top + (bounds.height - textPainter.height) / 2),
      );
    });

    // STAGE
    textPainter.text = const TextSpan(
      text: 'STAGE',
      style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 40));
  }

  @override
  bool shouldRepaint(covariant GocheokDomePainter oldDelegate) {
    return oldDelegate.selectedSection != selectedSection;
  }

  String? detectSection(Offset position) {
    for (var entry in sectionPaths.entries) {
      if (entry.value.contains(position)) return entry.key;
    }
    return null;
  }
}
