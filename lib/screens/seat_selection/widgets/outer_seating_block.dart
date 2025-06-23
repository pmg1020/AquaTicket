import 'package:flutter/material.dart';

class OuterSeatingBlock extends StatelessWidget {
  final double left;
  final double top;
  final String name;
  final double width;
  final double height;
  final int capacity;
  final String sectionFirestoreGrade;
  final String? selectedGrade; // 부모로부터 전달받는 선택된 등급
  final String? selectedSectionName; // 현재 선택된 구역 이름
  final void Function(BuildContext context, String sectionName) onBlockTap;

  const OuterSeatingBlock({
    super.key,
    required this.left,
    required this.top,
    required this.name,
    required this.width,
    required this.height,
    required this.capacity,
    required this.sectionFirestoreGrade,
    required this.selectedGrade,
    this.selectedSectionName,
    required this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    Color blockColor = const Color(0xFFD4C8A6); // 일반석 기본 색상 (베이지 계열)
    Border blockBorder = Border.all(color: Colors.transparent, width: 0);
    double opacity = 1.0; // 기본 투명도

    // 1. 등급 선택에 따른 투명도 조절 (selectedGrade가 있을 경우만)
    if (selectedGrade != null) {
      if (selectedGrade == "스탠딩석" && sectionFirestoreGrade == "NORMAL_2F") {
        opacity = 0.3; // 스탠딩 등급 선택 시 일반석 흐리게
      } else if (selectedGrade == "일반석" && sectionFirestoreGrade == "ZONE") {
        opacity = 0.3; // 일반석 등급 선택 시 스탠딩석 흐리게
      }
      // 그 외의 경우 (선택된 등급과 현재 구역의 등급이 일치하거나 등급이 없는 경우) opacity는 1.0 유지
    }

    // 2. 개별 구역 선택 강조 (최우선 적용)
    // selectedSectionName이 현재 블록 이름과 일치하면, 등급 기반 opacity를 덮어쓰고 검은색 테두리 적용
    if (selectedSectionName?.trim() == name.trim()) {
      blockBorder = Border.all(color: Colors.black, width: 3.0);
      opacity = 1.0;
    }



    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => onBlockTap(context, name),
        child: Opacity(
          opacity: opacity,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: blockColor,
              border: blockBorder, // 최종 결정된 테두리 적용
              borderRadius: BorderRadius.circular(4), // 둥근 모서리 유지
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 텍스트 색상도 선택 여부에 따라 조정 (일반석은 검은색)
                Text(name, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 7)), // 텍스트 색상 검은색으로 고정
                const SizedBox(height: 0),
                const Text("2층 좌석", style: TextStyle(color: Colors.black, fontSize: 4)),
                Text("$capacity석", style: TextStyle(color: Colors.black, fontSize: 4)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
