import 'package:flutter/material.dart';
import 'outer_seating_block.dart'; // OuterSeatingBlock 위젯 임포트

class MainCanvasLayout extends StatelessWidget {
  final String showTitle;
  final DateTime selectedDate;
  final VoidCallback onDateChangePressed; // 날짜 변경 버튼 콜백
  final String? selectedGrade; // 현재 선택된 등급 (상태로 전달)
  final Function(String? grade) onGradeSelected; // 등급 선택 콜백 (상태 변경 콜백)
  final List<Map<String, dynamic>> allSections; // 모든 섹션 정보 (상태로 전달)
  final void Function(BuildContext context, String sectionName) onZoneBlockTap; // ZONE/블록 탭 콜백 (메인 Canvas에서 팝업 띄울 때 사용)
  final String Function(int weekday) getDayOfWeek; // 요일 헬퍼 함수
  final List<String> Function(String gradeType) getSectionsForGrade; // 구역 필터링 헬퍼 함수

  // 하단 버튼들을 위해 필요한 상태와 콜백들을 추가
  final String currentView;
  final String selectedSectionName; // _selectedSectionName (현재 선택된 구역)
  final List<String> selectedSeats;
  final int totalPrice;
  final int maxTicketsPerUser;
  final VoidCallback onRefreshPressed;
  final VoidCallback onSelectSeatsPressed; // 좌석 선택 버튼 콜백 (전체 흐름을 위해)
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
    Color zoneColor = Colors.purple[300]!; // 스탠딩석 기본 색상 (보라색 유지)
    Border? zoneBorder; // 기본적으로 null 또는 투명 테두리
    double zoneOpacity = 1.0;

    // 1. 등급 선택에 따른 투명도 조절
    if (selectedGrade != null) {
      if (selectedGrade == "스탠딩석") {
        zoneOpacity = 1.0; // 스탠딩 등급 선택 시 스탠딩석은 불투명
      } else if (selectedGrade == "일반석") {
        zoneOpacity = 0.3; // 일반석 등급 선택 시 스탠딩석 흐리게
      }
    }

    // 2. 개별 구역 선택 강조 (최우선 적용)
    // ZONE 블록 자체에 selectedSectionName과 일치하면 검은색 테두리
    // 이 로직은 각 ZONE 블록의 Positioned 위젯 내에서 개별적으로 처리
    // (이전 코드에서 이미 그렇게 처리되고 있었음)


    return Column(
      children: [
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
              Container(width: 9, height: 9, color: Colors.purple[300]), // 스탠딩석 아이콘 색상 보라색 유지
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
            child: LayoutBuilder( // LayoutBuilder로 부모 위젯의 크기를 가져옴
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double centerX = constraints.maxWidth / 2;

                  // STAGE 구성 요소의 크기 정의 (전체 UI에 맞춰 더 작게 조정)
                  const double stageWidth = 160.0;
                  const double stageHeight = 28.0;
                  const double stageTop = 6.0;

                  // ZONE (1층 스탠딩) 구성 요소의 크기 및 간격 정의
                  const double zoneWidth = 65.0;
                  const double zoneHeight = 50.0;
                  const double zoneHorizontalGap = 5.0;
                  const double zoneVerticalGap = 4.0;

                  // 2층 외곽 좌석 구성 요소의 크기 및 간격 정의
                  const double outerSideWidth = 35.0;
                  const double outerSideHeight = 45.0;
                  const double outerBottomWidth = 55.0;
                  const double outerBottomHeight = 28.0;
                  const double outerSectionSpacing = 3.0;

                  // STAGE 위치 계산
                  final double stageLeft = centerX - (stageWidth / 2);

                  // ZONE 1-4 위치 계산
                  final double zone1Left = centerX - zoneWidth - (zoneHorizontalGap / 2);
                  final double zone2Left = centerX + (zoneHorizontalGap / 2);
                  final double zoneRow1Top = stageTop + stageHeight + 7.0;

                  final double zone3Left = zone1Left;
                  final double zone4Left = zone2Left;
                  final double zoneRow2Top = zoneRow1Top + zoneHeight + zoneVerticalGap;

                  // 2층 외곽 좌석 위치 계산
                  const double outerLeftStart = 2.0;
                  final double outerSideTopStart = stageTop + stageHeight - 7.0;

                  final double outerRightLeft = constraints.maxWidth - outerLeftStart - outerSideWidth;

                  final double outerBottomRowTop = zoneRow2Top + zoneHeight + 7.0;
                  final double totalBottomRowWidth = (outerBottomWidth * 4) + (outerSectionSpacing * 3);
                  final double bottomRowStartX = centerX - (totalBottomRowWidth / 2);

                  // ZONE 블록에 대한 최종 border 및 opacity 결정 (개별 블록에서 사용할 변수)
                  // selectedSectionName과 일치하면 border를 적용하고 opacity를 1.0으로 강제
                  Border? currentZoneBorder;
                  double currentZoneOpacity;

                  // 각 ZONE 블록에 대한 로직이 개별적으로 실행되므로,
                  // 여기서는 각 ZONE을 그릴 때 필요한 값을 계산하여 전달해야 합니다.
                  // 이를 위해 각 ZONE Positioned 내에서 계산합니다.

                  return Stack(
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
                      _buildZoneBlock(context, zone1Left, zoneRow1Top, "ZONE 1", zoneWidth, zoneHeight, zoneColor, zoneOpacity, selectedSectionName, onZoneBlockTap),
                      // ZONE 2
                      _buildZoneBlock(context, zone2Left, zoneRow1Top, "ZONE 2", zoneWidth, zoneHeight, zoneColor, zoneOpacity, selectedSectionName, onZoneBlockTap),
                      // ZONE 3
                      _buildZoneBlock(context, zone3Left, zoneRow2Top, "ZONE 3", zoneWidth, zoneHeight, zoneColor, zoneOpacity, selectedSectionName, onZoneBlockTap),
                      // ZONE 4
                      _buildZoneBlock(context, zone4Left, zoneRow2Top, "ZONE 4", zoneWidth, zoneHeight, zoneColor, zoneOpacity, selectedSectionName, onZoneBlockTap),

                      // 2층 외곽 좌석 (측면 좌석) - OuterSeatingBlock으로 분리
                      OuterSeatingBlock(left: outerLeftStart, top: outerSideTopStart, name: "I", width: outerSideWidth, height: outerSideHeight, capacity: 200, sectionFirestoreGrade: "NORMAL_2F", selectedGrade: selectedGrade, selectedSectionName: selectedSectionName, onBlockTap: onZoneBlockTap),
                      OuterSeatingBlock(
                        left: outerLeftStart,
                        top: outerSideTopStart + outerSideHeight + outerSectionSpacing,
                        name: "J",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: outerLeftStart,
                        top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 2,
                        name: "K",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: outerLeftStart,
                        top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 3,
                        name: "L",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),

                      OuterSeatingBlock(
                        left: outerRightLeft,
                        top: outerSideTopStart,
                        name: "F",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: outerRightLeft,
                        top: outerSideTopStart + outerSideHeight + outerSectionSpacing,
                        name: "E",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: outerRightLeft,
                        top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 2,
                        name: "D",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: outerRightLeft,
                        top: outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 3,
                        name: "C",
                        width: outerSideWidth,
                        height: outerSideHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),

                      OuterSeatingBlock(
                        left: bottomRowStartX,
                        top: outerBottomRowTop,
                        name: "M",
                        width: outerBottomWidth,
                        height: outerBottomHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: bottomRowStartX + outerBottomWidth + outerSectionSpacing,
                        top: outerBottomRowTop,
                        name: "N",
                        width: outerBottomWidth,
                        height: outerBottomHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: bottomRowStartX + (outerBottomWidth + outerSectionSpacing) * 2,
                        top: outerBottomRowTop,
                        name: "A",
                        width: outerBottomWidth,
                        height: outerBottomHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),
                      OuterSeatingBlock(
                        left: bottomRowStartX + (outerBottomWidth + outerSectionSpacing) * 3,
                        top: outerBottomRowTop,
                        name: "B",
                        width: outerBottomWidth,
                        height: outerBottomHeight,
                        capacity: 200,
                        sectionFirestoreGrade: "NORMAL_2F",
                        selectedGrade: selectedGrade,
                        selectedSectionName: selectedSectionName, // ✅ 추가
                        onBlockTap: onZoneBlockTap,
                      ),

                    ],
                  );
                }
            ),
          ),
        ),
        // 등급 및 구역 선택
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
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
                          color: (selectedGrade == "스탠딩석") ? Colors.grey[100] : Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: (selectedGrade == "스탠딩석") ? Colors.black : Colors.transparent,
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
                            color: (selectedGrade == "일반석") ? Colors.black : Colors.transparent,
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
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.only(left: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("구역", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 100,
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
                                  child: GestureDetector(
                                    onTap: () => onSectionSelectedFromList(sectionName),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (selectedSectionName == sectionName) ? Colors.grey[300] : Colors.transparent,
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(
                                          color: (selectedSectionName == sectionName) ? Colors.black : Colors.transparent,
                                        ),
                                      ),
                                      child: Text(sectionName, style: TextStyle(fontSize: 10,
                                        fontWeight: (selectedSectionName == sectionName) ? FontWeight.bold : FontWeight.normal,
                                        color: (selectedSectionName == sectionName) ? Colors.black : Colors.black,
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
                  onPressed: onRefreshPressed,
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
                  onPressed: (selectedSectionName.isEmpty) ? null : onSelectSeatsPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text("좌석 선택 (${selectedSeats.length}석)", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ _buildZoneBlock 헬퍼 위젯 추가 (MainCanvasLayout 내에서 Zone 블록을 그릴 때 사용)
  Widget _buildZoneBlock(BuildContext context, double left, double top, String name, double width, double height, Color baseColor, double opacity, String selectedSectionName, void Function(BuildContext context, String sectionName) onZoneBlockTap) {
    bool isSelected = selectedSectionName == name;
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onZoneBlockTap(context, name),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: baseColor,
              border: isSelected ? Border.all(color: Colors.black, width: 3.0) : Border.all(color: Colors.transparent),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(1.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: TextStyle(color: isSelected ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 8)),
                const SizedBox(height: 0),
                const Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 5)),
                const Text("400석", style: TextStyle(color: Colors.white, fontSize: 5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
