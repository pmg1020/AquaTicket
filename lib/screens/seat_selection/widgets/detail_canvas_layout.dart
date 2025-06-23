import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DetailCanvasLayout extends StatelessWidget {
  final String showTitle;
  final DateTime selectedDate;
  final String displayDateTimeString; // ✅ 이 필드를 다시 추가합니다.
  final String selectedSectionName;
  final List<List<Map<String, dynamic>>> seats;
  final List<String> selectedSeats;
  final int totalPrice;
  final void Function(int row, int col) onSeatToggled;
  final VoidCallback onSectionChangePressed;
  final VoidCallback onRefreshSeatsPressed;
  final void Function() onConfirmSelectionPressed;
  final Color Function(String grade) getSeatColor;
  final String Function(int weekday) getDayOfWeek;

  const DetailCanvasLayout({
    super.key,
    required this.showTitle,
    required this.selectedDate,
    required this.displayDateTimeString, // ✅ 생성자에도 다시 추가합니다.
    required this.selectedSectionName,
    required this.seats,
    required this.selectedSeats,
    required this.totalPrice,
    required this.onSeatToggled,
    required this.onSectionChangePressed,
    required this.onRefreshSeatsPressed,
    required this.onConfirmSelectionPressed,
    required this.getSeatColor,
    required this.getDayOfWeek,
  });

  @override
  Widget build(BuildContext context) {
    // 이제 이 위젯 내부에서 selectedDate를 다시 포맷팅하지 않고,
    // 이미 포맷팅되어 전달받은 displayDateTimeString을 사용합니다.
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            showTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayDateTimeString, // ✅ 전달받은 displayDateTimeString 사용
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              ElevatedButton(
                onPressed: onSectionChangePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text("구역 변경"),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedSectionName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "무대방향",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ),
        Expanded(
          child: seats.isEmpty && selectedSectionName.isNotEmpty
              ? const Center(child: CircularProgressIndicator())
              : seats.isEmpty && selectedSectionName.isEmpty
              ? const Center(child: Text("구역을 선택해주세요."))
              : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: seats.asMap().entries.map((rowEntry) {
                int rowIndex = rowEntry.key;
                List<Map<String, dynamic>> rowSeats = rowEntry.value;

                return Row(
                  children: rowSeats.asMap().entries.map((seatEntry) {
                    int colIndex = seatEntry.key;
                    Map<String, dynamic> seat = seatEntry.value;
                    bool isReserved = seat['isReserved'];
                    String grade = (seat['grade'] ?? 'NORMAL').toString();
                    String seatNumber = (seat['seatNumber'] ?? '').toString();

                    final isSelected = selectedSeats.contains(seatNumber);

                    return GestureDetector(
                      onTap: () => onSeatToggled(rowIndex, colIndex),
                      child: Container(
                        width: 15,
                        height: 15,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: isReserved
                              ? Colors.grey[500]
                              : getSeatColor(grade),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: isSelected ? 3.0 : 0,
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          color: Colors.grey[800],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, color: Colors.purple[300]),
                  const SizedBox(width: 3),
                  const Text("전석", style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(width: 10),
                  Text("${totalPrice.toStringAsFixed(0)}원",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRefreshSeatsPressed,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: const Text("새로고침", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: selectedSeats.isEmpty ? null : onConfirmSelectionPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text("다음 (${selectedSeats.length}석)", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
