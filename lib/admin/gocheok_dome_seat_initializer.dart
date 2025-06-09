import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> initializeGocheokDomeSeatsByGrade() async {
  final firestore = FirebaseFirestore.instance;
  const venueId = 'gocheok_dome';

  final sections = [
    {"name": "VIP1", "grade": "VIP", "rows": 4, "columns": 10},
    {"name": "VIP2", "grade": "VIP", "rows": 4, "columns": 10},
    {"name": "VIP3", "grade": "VIP", "rows": 4, "columns": 10},
    {"name": "VIP4", "grade": "VIP", "rows": 4, "columns": 10},
    {"name": "VIP5", "grade": "VIP", "rows": 4, "columns": 10},
    {"name": "SR1", "grade": "SR", "rows": 4, "columns": 10},
    {"name": "SR2", "grade": "SR", "rows": 4, "columns": 10},
    {"name": "SR3", "grade": "SR", "rows": 4, "columns": 10},
    {"name": "SR4", "grade": "SR", "rows": 4, "columns": 10},
    {"name": "T01", "grade": "VIP_TABLE", "rows": 4, "columns": 10},
    {"name": "T02", "grade": "VIP_TABLE", "rows": 4, "columns": 10},
    {"name": "R1-1", "grade": "R1", "rows": 6, "columns": 20},
    {"name": "R1-2", "grade": "R1", "rows": 6, "columns": 20},
    {"name": "R1-3", "grade": "R1", "rows": 6, "columns": 20},
    {"name": "R2-1", "grade": "R2", "rows": 5, "columns": 20},
    {"name": "R2-2", "grade": "R2", "rows": 5, "columns": 20},
    {"name": "R2-3", "grade": "R2", "rows": 5, "columns": 20},
    {"name": "R2-4", "grade": "R2", "rows": 5, "columns": 20},
    {"name": "S1", "grade": "S", "rows": 5, "columns": 20},
    {"name": "S2", "grade": "S", "rows": 5, "columns": 20},
    {"name": "A1", "grade": "A", "rows": 5, "columns": 20},
    {"name": "A2", "grade": "A", "rows": 5, "columns": 20},
    {"name": "A3", "grade": "A", "rows": 5, "columns": 20},
    {"name": "A4", "grade": "A", "rows": 5, "columns": 20},
    {"name": "A5", "grade": "A", "rows": 5, "columns": 20},
    {"name": "A6", "grade": "A", "rows": 5, "columns": 20},
  ];

  // 등급별로 묶기
  final Map<String, List<Map<String, dynamic>>> sectionsByGrade = {};
  for (var section in sections) {
    final grade = section['grade'] as String;
    sectionsByGrade.putIfAbsent(grade, () => []);
    sectionsByGrade[grade]!.add(section);
  }

  for (final entry in sectionsByGrade.entries) {
    final grade = entry.key;
    final sectionList = entry.value;

    print("▶ $grade 등급 초기화 시작");

    for (final section in sectionList) {
      final sectionRef = firestore
          .collection('venues')
          .doc(venueId)
          .collection('sections')
          .doc(section['name']);

      await sectionRef.set(section); // 섹션 정보 저장

      final rows = section['rows'] as int;
      final columns = section['columns'] as int;

      for (int r = 1; r <= rows; r++) {
        for (int c = 1; c <= columns; c++) {
          final seatNumber = '${section['name']}$r-$c';
          final seatRef = sectionRef.collection('seats').doc(seatNumber);

          await seatRef.set({
            'seatNumber': seatNumber,
            'isReserved': false,
            'grade': section['grade'],
          });
        }
      }

      print("✅ ${section['name']} 좌석 생성 완료");
    }

    print("✅ $grade 등급 전체 완료\n");
  }
}
