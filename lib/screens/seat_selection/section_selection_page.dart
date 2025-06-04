import 'package:flutter/material.dart';
import 'gocheok_dome_painter.dart';
import '/screens/seat_selection/seat_grid_page.dart';


class SectionSelectionPage extends StatefulWidget {
  final String showId;
  final String selectedDateTime;

  const SectionSelectionPage({
    super.key,
    required this.showId,
    required this.selectedDateTime,
  });

  @override
  State<SectionSelectionPage> createState() => _SectionSelectionPageState();
}

class _SectionSelectionPageState extends State<SectionSelectionPage> {
  String? selectedSection;

  void _handleTapDown(TapDownDetails details, GocheokDomePainter painter) {
    final tapped = painter.detectSection(details.localPosition);
    if (tapped != null) {
      setState(() {
        selectedSection = tapped;
      });
      // 예매 좌석 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeatGridPage(
            showId: widget.showId,
            selectedDateTime: widget.selectedDateTime,
            sectionName: tapped,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final painter = GocheokDomePainter(
      selectedSection: selectedSection,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("고척스카이돔 구역 선택")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Text(widget.selectedDateTime, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onTapDown: (details) => _handleTapDown(details, painter),
                child: CustomPaint(
                  painter: painter,
                  size: Size.infinite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
