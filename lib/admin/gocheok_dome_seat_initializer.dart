import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeGocheokDomeSeats() async {
  final firestore = FirebaseFirestore.instance;
  const venueId = 'gocheok_dome';

  final sections = [
    {"name": "F1", "rows": 4, "columns": 10},
    {"name": "F2", "rows": 4, "columns": 10},
    {"name": "F3", "rows": 4, "columns": 10},
    {"name": "F4", "rows": 4, "columns": 10},
    {"name": "F5", "rows": 4, "columns": 10},
    {"name": "T01", "rows": 3, "columns": 5},
    {"name": "T02", "rows": 3, "columns": 5},
    {"name": "R1", "rows": 5, "columns": 12},
    {"name": "R2", "rows": 5, "columns": 12},
    {"name": "S", "rows": 10, "columns": 20},
    {"name": "A", "rows": 12, "columns": 25},
  ];

  for (final section in sections) {
    final sectionRef = firestore
        .collection('venues')
        .doc(venueId)
        .collection('sections')
        .doc(section['name'] as String);

    final batch = firestore.batch();
    final rows = section['rows'] as int;
    final columns = section['columns'] as int;

    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= columns; c++) {
        final seatNumber = '${section['name']}$r-$c';
        final seatRef = sectionRef.collection('seats').doc(seatNumber);
        batch.set(seatRef, {
          'seatNumber': seatNumber,
          'isReserved': false,
        });
      }
    }

    await batch.commit();
    print("✅ ${section['name']} 좌석 생성 완료");
  }
}
