import 'package:flutter/material.dart';
import 'outer_seating_block.dart'; // OuterSeatingBlock 위젯 임포트

class MainCanvasLayout extends StatelessWidget {
  final String showTitle;
  final DateTime selectedDate;
  final VoidCallback onDateChangePressed; // 날짜 변경 버튼 콜백
  final String? selectedGrade; // 현재 선택된 등급 (상태로 전달)
  final Function(String? grade) onGradeSelected; // 등급 선택 콜백 (상태 변경 콜백)
  final List<Map<String, dynamic>> allSections; // 모든 섹션 정보 (상태로 전달)
  final void Function(BuildContext context, String sectionName) onZoneBlockTap; // ZONE/블록 탭 콜백 (맵 클릭 시 팝업 띄울 때 사용)
  final String Function(int weekday) getDayOfWeek; // 요일 헬퍼 함수
  final List<String> Function(String gradeType) getSectionsForGrade; // 구역 필터링 헬퍼 함수

  // 하단 버튼들을 위해 필요한 상태와 콜백들을 추가
  final String currentView;
  final String selectedSectionName; // _selectedSectionName (현재 선택된 구역)
  final List<String> selectedSeats;
  final int totalPrice;
  final int maxTicketsPerUser;
  final VoidCallback onRefreshPressed;
  final VoidCallback onSelectSeatsPressed; // '좌석 선택' 버튼 클릭 시 상세 화면으로 이동
  final void Function(String sectionName) onSectionSelectedFromList; // 구역 리스트에서 구역 선택 시 호출될 콜백


  const MainCanvasLayout({
    super.key,
    required this.showTitle,
    required this.selectedDate,
    required this.onDateChangePressed,
    required this.selectedGrade,
    required this.onGradeSelected,
    required this.allSections,
    required this.onZoneBlockTap, // 이 콜백은 블록을 탭할 때 사용
    required this.getDayOfWeek,
    required this.getSectionsForGrade,
    // 새로 추가된 매개변수들
    required this.currentView,
    required this.selectedSectionName,
    required this.selectedSeats,
    required this.totalPrice,
    required this.maxTicketsPerUser,
    required this.onRefreshPressed,
    required this.onSelectSeatsPressed,
    required this.onSectionSelectedFromList,
  });

  @override
  Widget build(BuildContext context) {
    final double centerX = MediaQuery.of(context).size.width / 2;

    const double stageWidth = 160.0;
    const double stageHeight = 28.0;
    const double stageTop = 6.0;

    const double zoneWidth = 65.0;
    const double zoneHeight = 50.0;
    const double zoneHorizontalGap = 5.0;
    const double zoneVerticalGap = 4.0;

    const double outerSideWidth = 35.0;
    const double outerSideHeight = 45.0;
    const double outerBottomWidth = 55.0;
    const double outerBottomHeight = 28.0;
    const double outerSectionSpacing = 3.0;

    final double stageLeft = centerX - (stageWidth / 2);

    final double zone1Left = centerX - zoneWidth - (zoneHorizontalGap / 2);
    final double zone2Left = centerX + (zoneHorizontalGap / 2);
    final double zoneRow1Top = stageTop + stageHeight + 7.0;

    final double zone3Left = zone1Left;
    final double zone4Left = zone2Left;
    final double zoneRow2Top = zoneRow1Top + zoneHeight + zoneVerticalGap;

    const double outerLeftStart = 2.0;
    final double outerSideTopStart = stageTop + stageHeight - 7.0;

    final double outerRightLeft = MediaQuery.of(context).size.width - outerLeftStart - outerSideWidth;

    final double outerBottomRowTop = zoneRow2Top + zoneHeight + 7.0;
    final double totalBottomRowWidth = (outerBottomWidth * 4) + (outerSectionSpacing * 3);
    final double bottomRowStartX = centerX - (totalBottomRowWidth / 2);

    // ZONE (스탠딩석)에 대한 조건부 스타일 변수
    Color zoneColor = Colors.purple[300]!; // 스탠딩석 기본 색상
    double zoneOpacity = 1.0;
    Border zoneBorder = Border.all(color: Colors.transparent, width: 0); // 기본 테두리 없음

    // 등급 선택 시 ZONE 구역의 투명도 조절
    if (selectedGrade != null) {
      if (selectedGrade == "스탠딩석") {
        zoneOpacity = 1.0;
      } else if (selectedGrade == "일반석") {
        zoneOpacity = 0.3; // 일반석 선택 시 스탠딩석 흐리게
      }
    }


    return Column( // ✅ Column 시작
      children: [ // ✅ Column children 시작
        // 콘서트 이름
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Text(
            showTitle,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
        ),
        // 날짜 선택 및 변경 버튼
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 (${getDayOfWeek(selectedDate.weekday)}) ${selectedDate.hour}시${selectedDate.minute.toString().padLeft(2, '0')}분",
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
              ),
              ElevatedButton(
                onPressed: onDateChangePressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  textStyle: const TextStyle(fontSize: 9),
                ),
                child: const Text("날짜 변경"),
              ),
            ],
          ),
        ),
        // 등급 설명
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
          child: Row(
            children: [
              Container(width: 9, height: 9, color: Colors.purple[300]),
              const SizedBox(width: 2),
              const Text("스탠딩석", style: TextStyle(fontSize: 9)),
              const SizedBox(width: 6),
              Container(width: 9, height: 9, color: const Color(0xFFD4C8A6)),
              const SizedBox(width: 2),
              const Text("일반석", style: TextStyle(fontSize: 9)),
            ],
          ),
        ),
        // 좌석 배치도
        Expanded(
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              children: [
                // STAGE
                Positioned(
                  top: stageTop,
                  left: stageLeft,
                  child: Container(
                    width: stageWidth,
                    height: stageHeight,
                    color: Colors.grey[400],
                    alignment: Alignment.center,
                    child: const Text(
                      "STAGE",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),

                // ZONE 1 (1층 스탠딩 - 400석)
                Positioned(
                  top: zoneRow1Top,
                  left: zone1Left,
                  child: GestureDetector(
                    onTap: () => onZoneBlockTap(context, "ZONE 1"), // 맵 클릭 시 팝업 띄움
                    child: Opacity( // 등급 투명도 적용
                      opacity: zoneOpacity,
                      child: Container(
                        width: zoneWidth,
                        height: zoneHeight,
                        decoration: BoxDecoration(
                          color: zoneColor, // 스탠딩 색상
                          // 맵의 구역 강조 (선택된 구역인 경우 테두리)
                          border: (selectedSectionName == "ZONE 1") ? Border.all(color: Colors.black, width: 3.0) : zoneBorder,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("ZONE 1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8)),
                            SizedBox(height: 0),
                            Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 5)),
                            Text("400석", style: TextStyle(color: Colors.white, fontSize: 5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ZONE 2 (1층 스탠딩 - 400석)
                Positioned(
                  top: zoneRow1Top,
                  left: zone2Left,
                  child: GestureDetector(
                    onTap: () => onZoneBlockTap(context, "ZONE 2"),
                    child: Opacity(
                      opacity: zoneOpacity,
                      child: Container(
                        width: zoneWidth,
                        height: zoneHeight,
                        decoration: BoxDecoration(
                          color: zoneColor,
                          border: (selectedSectionName == "ZONE 2") ? Border.all(color: Colors.black, width: 3.0) : zoneBorder,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("ZONE 2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8)),
                            SizedBox(height: 0),
                            Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 5)),
                            Text("400석", style: TextStyle(color: Colors.white, fontSize: 5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ZONE 3 (1층 스탠딩 - 400석)
                Positioned(
                  top: zoneRow2Top,
                  left: zone3Left,
                  child: GestureDetector(
                    onTap: () => onZoneBlockTap(context, "ZONE 3"),
                    child: Opacity(
                      opacity: zoneOpacity,
                      child: Container(
                        width: zoneWidth,
                        height: zoneHeight,
                        decoration: BoxDecoration(
                          color: zoneColor,
                          border: (selectedSectionName == "ZONE 3") ? Border.all(color: Colors.black, width: 3.0) : zoneBorder,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("ZONE 3", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8)),
                            SizedBox(height: 0),
                            Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 5)),
                            Text("400석", style: TextStyle(color: Colors.white, fontSize: 5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ZONE 4 (1층 스탠딩 - 400석)
                Positioned(
                  top: zoneRow2Top,
                  left: zone4Left,
                  child: GestureDetector(
                    onTap: () => onZoneBlockTap(context, "ZONE 4"),
                    child: Opacity(
                      opacity: zoneOpacity,
                      child: Container(
                        width: zoneWidth,
                        height: zoneHeight,
                        decoration: BoxDecoration(
                          color: zoneColor,
                          border: (selectedSectionName == "ZONE 4") ? Border.all(color: Colors.black, width: 3.0) : zoneBorder,
                        ),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(1.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("ZONE 4", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8)),
                            SizedBox(height: 0),
                            Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 5)),
                            Text("400석", style: TextStyle(color: Colors.white, fontSize: 5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ), // ✅ ZONE 4 Positioned 닫는 괄호 추가

                // 2층 외곽 좌석 (측면 좌석) - OuterSeatingBlock으로 분리
                OuterSeatingBlock(left: outerLeftStart, top: outerSideTopStart, name: "I", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap),
                OuterSeatingBlock(left: outerLeftStart, top: outerSideTopStart + outerSideHeight + outerSectionSpacing, name: "J", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가 (이전 코드에는 없었음)
                OuterSeatingBlock(left: outerLeftStart, top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 2, name: "K", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: outerLeftStart, top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 3, name: "L", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가

                OuterSeatingBlock(left: outerRightLeft, top: outerSideTopStart, name: "F", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: outerRightLeft, top: outerSideTopStart + outerSideHeight + outerSectionSpacing, name: "E", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: outerRightLeft, top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 2, name: "D", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: outerRightLeft, top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 3, name: "C", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가

                OuterSeatingBlock(left: bottomRowStartX, top: outerBottomRowTop, name: "M", width: outerBottomWidth, height: outerBottomHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: bottomRowStartX + outerBottomWidth + outerSectionSpacing, top: outerBottomRowTop, name: "N", width: outerBottomWidth, height: outerBottomHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: bottomRowStartX + (outerBottomWidth + outerSectionSpacing) * 2, top: outerBottomRowTop, name: "A", width: outerBottomWidth, height: outerBottomHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
                OuterSeatingBlock(left: bottomRowStartX + (outerBottomWidth + outerSectionSpacing) * 3, top: outerBottomRowTop, name: "B", width: outerBottomWidth, height: outerBottomHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap), // ✅ selectedSectionName 추가
              ], // ✅ Stack children 닫는 대괄호
            ), // ✅ Stack 닫는 괄호
          ), // ✅ SizedBox 닫는 괄호
        ), // ✅ Expanded 닫는 괄호
        // 등급 및 구역 선택
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0), // 테두리 추가
            borderRadius: BorderRadius.circular(8.0), // 둥근 모서리
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1, // 등급 섹션 너비 조정
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("등급", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    // 스탠딩석 등급 선택
                    GestureDetector(
                      onTap: () => onGradeSelected("스탠딩석"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (selectedGrade == "스탠딩석") ? Colors.purple[100] : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: (selectedGrade == "스탠딩석") ? Colors.purple[300]! : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, color: Colors.purple[300]),
                            const SizedBox(width: 2),
                            const Text("스탠딩석", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 일반석 등급 선택
                    GestureDetector(
                      onTap: () => onGradeSelected("일반석"),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (selectedGrade == "일반석") ? Colors.grey[100] : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: (selectedGrade == "일반석") ? Colors.grey[300]! : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, color: const Color(0xFFD4C8A6)),
                            const SizedBox(width: 2),
                            const Text("일반석", style: TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 구역 섹션
              Expanded(
                flex: 1, // 구역 섹션 너비 조정
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(8.0), // 내부 패딩 추가
                  margin: const EdgeInsets.only(left: 8.0), // 등급 섹션과의 간격
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("구역", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      // 선택된 등급에 따른 구역 라인업 표시 (높이 제한 및 스크롤 추가)
                      SizedBox(
                        height: 100, // 이 높이는 필요에 따라 조정 가능
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (selectedGrade == null)
                                const Text("등급을 먼저 선택해주세요.", style: TextStyle(fontSize: 10, color: Colors.grey))
                              else
                                ...getSectionsForGrade(selectedGrade!)
                                    .map((sectionName) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  // 구역 이름 클릭 가능하게 변경
                                  child: GestureDetector(
                                    onTap: () => onSectionSelectedFromList(sectionName), // ✅ 구역 이름 클릭 시 해당 구역 선택 콜백
                                    child: Container( // 선택된 구역 시각적 강조를 위한 Container
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (selectedSectionName == sectionName) ? Colors.blue[100] : Colors.transparent, // 선택 시 배경색 변경
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: (selectedSectionName == sectionName) ? Colors.blue : Colors.transparent, // 선택 시 테두리 추가
                                        ),
                                      ),
                                      child: Text(sectionName, style: TextStyle(fontSize: 10,
                                        fontWeight: (selectedSectionName == sectionName) ? FontWeight.bold : FontWeight.normal,
                                        color: (selectedSectionName == sectionName) ? Colors.blue[800] : Colors.black,
                                      )),
                                    ),
                                  ),
                                ))
                                    .toList(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // 하단 버튼들
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRefreshPressed, // 콜백 사용
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    textStyle: const TextStyle(fontSize: 13),
                  ),
                  child: const Text("새로고침", style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: (selectedSectionName.isEmpty) ? null : onSelectSeatsPressed, // ✅ 구역 선택 시 활성화
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text("좌석 선택 (${selectedSeats.length}석)", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ], // ✅ Column children 닫는 대괄호
    ); // ✅ Column 닫는 괄호
  }
}