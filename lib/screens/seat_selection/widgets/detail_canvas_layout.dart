import 'package:flutter/material.dart';

class DetailCanvasLayout extends StatelessWidget {
  final String showTitle;
  final DateTime selectedDate;
  final String selectedSectionName;
  final List<List<Map<String, dynamic>>> seats;
  final List<String> selectedSeats;
  final int totalPrice;
  final void Function(int row, int col) onSeatToggled;
  final VoidCallback onSectionChangePressed; // 구역 변경 버튼 콜백
  final VoidCallback onRefreshSeatsPressed; // 새로고침 버튼 콜백
  final void Function() onConfirmSelectionPressed; // 다음 (좌석 선택) 버튼 콜백
  final Color Function(String grade) getSeatColor; // 좌석 색상 헬퍼 함수
  final String Function(int weekday) getDayOfWeek; // 요일 헬퍼 함수

  const DetailCanvasLayout({
    Key? key,
    required this.showTitle,
    required this.selectedDate,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 콘서트 이름 (상세 화면에도 표시)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            showTitle,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        // 선택된 날짜와 구역 정보
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 (${getDayOfWeek(selectedDate.weekday)}) ${selectedDate.hour}시${selectedDate.minute.toString().padLeft(2, '0')}분",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              // 날짜 변경 버튼 대신 구역 변경 버튼
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
        // 상세 구역 이름
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedSectionName, // 선택된 구역 이름 표시
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 5.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "무대방향", // "무대방향" 텍스트 추가
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
                        width: 15, // 좌석 크기 더 줄임
                        height: 15, // 좌석 크기 더 줄임
                        margin: const EdgeInsets.all(1), // 좌석 간 간격 더 줄임
                        decoration: BoxDecoration(
                          color: isReserved
                              ? Colors.grey[500] // 매진된 좌석을 회색으로 통일
                              : getSeatColor(grade), // 등급에 따른 좌석 색상 (선택되어도 색상 유지)
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.transparent,
                            width: isSelected ? 3.0 : 0, // 선택된 좌석 테두리 굵기 3.0
                          ),
                          borderRadius: BorderRadius.circular(2), // 둥근 모서리 더 줄임
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
