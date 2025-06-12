import 'package:cloud_firestore/cloud_firestore.dart';

// 함수명을 initializeMainHallSeatsByGrade로 변경했습니다.
Future<void> initializeMainHallSeatsByGrade() async {
  final firestore = FirebaseFirestore.instance;
  const venueId = 'main_hall'; // 'gocheok_dome'을 'main_hall'로 변경했습니다.


  final sections = [
    // 1층 스탠딩 구역 (각 400석)
    {"name": "ZONE 1", "grade": "ZONE", "rows": 20, "columns": 20}, // 20*20 = 400
    {"name": "ZONE 2", "grade": "ZONE", "rows": 20, "columns": 20},
    {"name": "ZONE 3", "grade": "ZONE", "rows": 20, "columns": 20},
    {"name": "ZONE 4", "grade": "ZONE", "rows": 20, "columns": 20},

    // 2층 외곽 좌석 (각 200석 = rows * columns)
    // 현재 Canvas의 _buildOuterSeatingBlock에서 이름과 capacity를 사용하므로,
    // 이 rows, columns는 임의로 설정하거나 실제 구역에 맞게 조정해야 합니다.
    // 여기서는 200석을 대략적으로 채울 수 있도록 설정합니다.
    {"name": "I", "grade": "NORMAL_2F", "rows": 10, "columns": 20}, // 10*20 = 200
    {"name": "J", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "K", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "L", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "F", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "E", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "D", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "C", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "M", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "N", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "A", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
    {"name": "B", "grade": "NORMAL_2F", "rows": 10, "columns": 20},
  ];

  // 등급별로 섹션 묶기
  final Map<String, List<Map<String, dynamic>>> sectionsByGrade = {};
  for (var section in sections) {
    final grade = section['grade'] as String;
    sectionsByGrade.putIfAbsent(grade, () => []);
    sectionsByGrade[grade]!.add(section);
  }

  // 'main_hall' 공연장 문서 업데이트 및 새로운 섹션 데이터와 좌석 생성
  final venueRef = firestore.collection('venues').doc(venueId);
  await venueRef.set({
    "name": "공연장 A", // 공연장 이름 설정
    "sections": sections.map((s) => Map<String, dynamic>.from(s)).toList(), // 섹션 정보 저장
  });
  print("✅ 공연장 문서 업데이트 완료: $venueId");


  for (final sectionEntry in sections) { // 정의된 각 섹션에 대해 반복 처리
    final sectionName = sectionEntry['name'] as String;
    final sectionGrade = sectionEntry['grade'] as String;
    final rows = sectionEntry['rows'] as int;
    final columns = sectionEntry['columns'] as int;

    final sectionRef = firestore
        .collection('venues')
        .doc(venueId)
        .collection('sections')
        .doc(sectionName);

    await sectionRef.set({ // 섹션 정보 저장
      'name': sectionName,
      'grade': sectionGrade,
      'rows': rows,
      'columns': columns,
    });
    print("▶ $sectionName 섹션 초기화 시작");

    final batch = firestore.batch(); // 대량 좌석 생성을 위한 배치 쓰기 사용
    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= columns; c++) {
        final seatNumber = '$sectionName-$r-$c'; // 좌석 번호 형식: 섹션이름-행-열
        final seatRef = sectionRef.collection('seats').doc(seatNumber);

        batch.set(seatRef, {
          'seatNumber': seatNumber,
          'isReserved': false, // 기본적으로 예약되지 않은 상태
          'grade': sectionGrade, // 섹션의 등급을 좌석의 등급으로 저장
          // 'price' 필드는 앱 내에서 동적으로 결정되므로 Firebase에는 저장하지 않습니다.
        });
      }
    }
    await batch.commit(); // 모든 배치 작업 원자적으로 실행
    print("✅ $sectionName 좌석 생성 완료");
  }

  print("✅ 모든 좌석 데이터 Firebase에 업데이트 완료\n");
}
