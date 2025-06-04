import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initializeVenues() async {
  final venue = {
    "id": "gocheok_dome",
    "name": "고척스카이돔",
    "sections": [
      {"name": "VIP F1", "type": "SEATED", "rows": 2, "columns": 5, "color": "deeppink", "position": {"x": 160, "y": 120}},
      {"name": "VIP F2", "type": "SEATED", "rows": 2, "columns": 5, "color": "deeppink", "position": {"x": 220, "y": 120}},
      {"name": "SR L", "type": "SEATED", "rows": 4, "columns": 5, "color": "limegreen", "position": {"x": 80, "y": 160}},
      {"name": "SR R", "type": "SEATED", "rows": 4, "columns": 5, "color": "limegreen", "position": {"x": 300, "y": 160}},
      {"name": "R석 1층 L", "type": "SEATED", "rows": 6, "columns": 7, "color": "navy", "position": {"x": 60, "y": 240}},
      {"name": "R석 1층 R", "type": "SEATED", "rows": 6, "columns": 7, "color": "navy", "position": {"x": 320, "y": 240}},
      {"name": "R석 2층 L", "type": "SEATED", "rows": 6, "columns": 7, "color": "lightskyblue", "position": {"x": 60, "y": 320}},
      {"name": "R석 2층 R", "type": "SEATED", "rows": 6, "columns": 7, "color": "lightskyblue", "position": {"x": 320, "y": 320}},
      {"name": "S석", "type": "SEATED", "rows": 10, "columns": 15, "color": "teal", "position": {"x": 160, "y": 380}},
      {"name": "A석", "type": "SEATED", "rows": 12, "columns": 18, "color": "gold", "position": {"x": 150, "y": 480}},
    ]
  };

  final firestore = FirebaseFirestore.instance;
  final venueId = venue['id'] as String;
  final data = Map<String, dynamic>.from(venue)..remove('id');

  await firestore.collection('venues').doc(venueId).set(data);
  print("✅ 공연장 등록 완료: $venueId");

  for (final section in data['sections']) {
    final pos = section['position'];
    section['position']['row'] = (pos['y'] / 90).round();
    section['position']['col'] = (pos['x'] / 90).round();

    final sectionName = section['name'];
    final sectionRef = firestore.collection('venues').doc(venueId).collection('sections').doc(sectionName);
    await sectionRef.set(section);

    final batch = firestore.batch();
    final rows = section['rows'] as int;
    final columns = section['columns'] as int;

    for (int r = 1; r <= rows; r++) {
      for (int c = 1; c <= columns; c++) {
        final seatNumber = '$sectionName$r-$c';
        final seatRef = sectionRef.collection('seats').doc(seatNumber);
        batch.set(seatRef, {
          'seatNumber': seatNumber,
          'isReserved': false,
        });
      }
    }

    await batch.commit();
    print("🎫 좌석 생성 완료: $venueId / $sectionName");
  }
}
