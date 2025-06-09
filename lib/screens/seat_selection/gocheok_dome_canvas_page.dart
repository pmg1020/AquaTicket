import 'package:flutter/material.dart';

class GocheokDomeCanvasPage extends StatelessWidget {
  const GocheokDomeCanvasPage({super.key});

  // 2층 외곽 좌석 컨테이너를 생성하는 헬퍼 위젯
  Widget _buildOuterSeatingBlock(double left, double top, String name, double width, double height, int capacity) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: width,
        height: height,
        color: Colors.grey[200], // 2층 일반 좌석 색상
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(name, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 5),
            const Text("2층 좌석", style: TextStyle(color: Colors.black, fontSize: 12)),
            Text("$capacity석", style: TextStyle(color: Colors.black, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("고척 스카이돔 좌석 배치도"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 1000, // 새로운 레이아웃에 맞춰 높이 조정
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              final double centerX = constraints.maxWidth / 2;

              // STAGE 구성 요소의 크기 정의
              const double stageWidth = 400.0;
              const double stageHeight = 80.0;
              const double stageTop = 50.0; // STAGE의 시작 Y 위치

              // ZONE (1층 스탠딩) 구성 요소의 크기 및 간격 정의
              const double zoneWidth = 180.0;
              const double zoneHeight = 150.0;
              const double zoneHorizontalGap = 20.0;
              const double zoneVerticalGap = 20.0;

              // 2층 외곽 좌석 구성 요소의 크기 및 간격 정의
              const double outerSideWidth = 90.0; // 측면 좌석 너비
              const double outerSideHeight = 110.0; // 측면 좌석 높이
              const double outerBottomWidth = 110.0; // 하단 좌석 너비
              const double outerBottomHeight = 70.0; // 하단 좌석 높이
              const double outerSectionSpacing = 10.0; // 외곽 좌석 섹션 간 간격

              // STAGE 위치 계산
              final double stageLeft = centerX - (stageWidth / 2);

              // ZONE 1-4 위치 계산
              final double zone1Left = centerX - zoneWidth - (zoneHorizontalGap / 2);
              final double zone2Left = centerX + (zoneHorizontalGap / 2);
              final double zoneRow1Top = stageTop + stageHeight + 40.0; // STAGE 아래 첫 번째 행 ZONE 시작 Y 위치

              final double zone3Left = zone1Left;
              final double zone4Left = zone2Left;
              final double zoneRow2Top = zoneRow1Top + zoneHeight + zoneVerticalGap; // ZONE 두 번째 행 시작 Y 위치

              // 2층 외곽 좌석 위치 계산
              // 좌측 측면 섹션 (I, J, K, L)
              const double outerLeftStart = 20.0; // 좌측 여백
              final double outerSideTopStart = stageTop + stageHeight - 20.0; // STAGE 옆에서 시작

              // 우측 측면 섹션 (F, E, D, C)
              final double outerRightLeft = constraints.maxWidth - outerLeftStart - outerSideWidth;

              // 하단 섹션 (M, N, A, B)
              final double outerBottomRowTop = zoneRow2Top + zoneHeight + 50.0; // ZONE 아래에서 시작
              final double totalBottomRowWidth = (outerBottomWidth * 4) + (outerSectionSpacing * 3);
              final double bottomRowStartX = centerX - (totalBottomRowWidth / 2);

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
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 28),
                      ),
                    ),
                  ),

                  // ZONE 1 (1층 스탠딩 - 400석)
                  Positioned(
                    top: zoneRow1Top,
                    left: zone1Left,
                    child: Container(
                      width: zoneWidth,
                      height: zoneHeight,
                      color: Colors.purple[300], // 멤버십 색상
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("ZONE 1", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 5),
                          Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 14)),
                          Text("400석", style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  // ZONE 2 (1층 스탠딩 - 400석)
                  Positioned(
                    top: zoneRow1Top,
                    left: zone2Left,
                    child: Container(
                      width: zoneWidth,
                      height: zoneHeight,
                      color: Colors.purple[300], // 멤버십 색상
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("ZONE 2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 5),
                          Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 14)),
                          Text("400석", style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  // ZONE 3 (1층 스탠딩 - 400석)
                  Positioned(
                    top: zoneRow2Top,
                    left: zone3Left,
                    child: Container(
                      width: zoneWidth,
                      height: zoneHeight,
                      color: Colors.purple[300], // 멤버십 색상
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("ZONE 3", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 5),
                          Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 14)),
                          Text("400석", style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  // ZONE 4 (1층 스탠딩 - 400석)
                  Positioned(
                    top: zoneRow2Top,
                    left: zone4Left,
                    child: Container(
                      width: zoneWidth,
                      height: zoneHeight,
                      color: Colors.purple[300], // 멤버십 색상
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("ZONE 4", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 5),
                          Text("1층 스탠딩", style: TextStyle(color: Colors.white, fontSize: 14)),
                          Text("400석", style: TextStyle(color: Colors.white, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),

                  // 2층 외곽 좌석 (측면 좌석)
                  // 좌측 측면 섹션 (I, J, K, L) - 각 200석
                  _buildOuterSeatingBlock(outerLeftStart, outerSideTopStart, "I", outerSideWidth, outerSideHeight, 200),
                  _buildOuterSeatingBlock(outerLeftStart, outerSideTopStart + outerSideHeight + outerSectionSpacing, "J", outerSideWidth, outerSideHeight, 200),
                  _buildOuterSeatingBlock(outerLeftStart, outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 2, "K", outerSideWidth, outerSideHeight, 200),
                  _buildOuterSeatingBlock(outerLeftStart, outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 3, "L", outerSideWidth, outerSideHeight, 200),

                  // 우측 측면 섹션 (F, E, D, C) - 각 200석
                  _buildOuterSeatingBlock(outerRightLeft, outerSideTopStart, "F", outerSideWidth, outerSideHeight, 200),
                  _buildOuterSeatingBlock(outerRightLeft, outerSideTopStart + outerSideHeight + outerSectionSpacing, "E", outerSideWidth, outerSideHeight, 200),
                  _buildOuterSeatingBlock(outerRightLeft, outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 2, "D", outerSideWidth, outerSideHeight, 200),
                  _buildOuterSeatingBlock(outerRightLeft, outerSideTopStart + (outerSideHeight + outerSectionSpacing) * 3, "C", outerSideWidth, outerSideHeight, 200),

                  // 2층 외곽 좌석 (하단 좌석)
                  // 하단 섹션 (M, N, A, B) - 각 200석
                  _buildOuterSeatingBlock(bottomRowStartX, outerBottomRowTop, "M", outerBottomWidth, outerBottomHeight, 200),
                  _buildOuterSeatingBlock(bottomRowStartX + outerBottomWidth + outerSectionSpacing, outerBottomRowTop, "N", outerBottomWidth, outerBottomHeight, 200),
                  _buildOuterSeatingBlock(bottomRowStartX + (outerBottomWidth + outerSectionSpacing) * 2, outerBottomRowTop, "A", outerBottomWidth, outerBottomHeight, 200),
                  _buildOuterSeatingBlock(bottomRowStartX + (outerBottomWidth + outerSectionSpacing) * 3, outerBottomRowTop, "B", outerBottomWidth, outerBottomHeight, 200),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
