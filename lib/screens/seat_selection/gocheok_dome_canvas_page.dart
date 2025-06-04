import 'package:flutter/material.dart';

class GocheokDomeCanvasPage extends StatelessWidget {
  const GocheokDomeCanvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("고척스카이돔 구역 보기")),
      body: Center(
        child: InteractiveViewer(
          boundaryMargin: const EdgeInsets.all(100),
          minScale: 0.5,
          maxScale: 2.5,
          child: CustomPaint(
            size: const Size(500, 600),
            painter: GocheokDomePainter(),
          ),
        ),
      ),
    );
  }
}

class GocheokDomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    void drawSection(String name, Offset position, Size size, Color color) {
      paint.color = color;
      final rect = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
      canvas.drawRect(rect, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: name,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(minWidth: 0, maxWidth: size.width);
      textPainter.paint(
        canvas,
        Offset(
          position.dx + (size.width - textPainter.width) / 2,
          position.dy + (size.height - textPainter.height) / 2,
        ),
      );
    }

    drawSection("플로어", const Offset(200, 100), const Size(100, 60), Colors.blue);
    drawSection("VIP", const Offset(200, 170), const Size(100, 50), Colors.purple);
    drawSection("R석", const Offset(130, 230), const Size(70, 50), Colors.red);
    drawSection("S석", const Offset(270, 230), const Size(70, 50), Colors.indigo);
    drawSection("A석", const Offset(200, 290), const Size(100, 50), Colors.green);
    drawSection("3층", const Offset(200, 350), const Size(100, 50), Colors.grey);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
