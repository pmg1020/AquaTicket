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
    super.key, // super.key 사용
    required this.left,
    required this.top,
    required this.name,
    required this.width,
    required this.height,
    required this.capacity,
    required this.sectionFirestoreGrade,
    required this.selectedGrade,
    this.selectedSectionName, // 선택 사항이므로 required 제거
    required this.onBlockTap,
  });

  @override
  Widget build(BuildContext context) {
    Color blockColor = const Color(0xFFD4C8A6); // 일반석 기본 색상
    Border blockBorder = Border.all(color: Colors.transparent, width: 0);
    double opacity = 1.0; // 기본 투명도

    // 1. 등급 선택에 따른 투명도 조절 (selectedGrade가 있을 경우만)
    if (selectedGrade != null) {
      if (selectedGrade == "스탠딩석" && sectionFirestoreGrade == "NORMAL_2F") {
        opacity = 0.3; // 스탠딩석 선택 시 일반석 흐리게
      } else if (selectedGrade == "일반석" && sectionFirestoreGrade == "ZONE") {
        opacity = 0.3; // 일반석 선택 시 스탠딩석(ZONE) 흐리게
      } else {
        opacity = 1.0;
      }
    }

    // 2. 개별 구역 선택 강조 (selectedSectionName과 일치할 경우 최우선 적용)
    if (selectedSectionName == name) {
      blockBorder = Border.all(color: Colors.black, width: 3.0); // 굵은 검은색 테두리
      opacity = 1.0; // 선택된 구역은 항상 선명하게
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
              border: blockBorder,
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 7)),
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
