import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/show.dart';

class ShowService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Show>> getShows({String? searchQuery}) async {
    Query<Map<String, dynamic>> query = _firestore.collection('shows');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final snapshot = await query.get();
      final allShows = snapshot.docs.map((doc) => Show.fromMap(doc.id, doc.data())).toList();

      final lowerCaseQuery = searchQuery.toLowerCase();
      return allShows.where((show) {
        return show.title.toLowerCase().contains(lowerCaseQuery) ||
            show.location.toLowerCase().contains(lowerCaseQuery) ||
            show.type.toLowerCase().contains(lowerCaseQuery);
      }).toList();

    } else {
      final snapshot = await query.get();
      // ✅ posterImageUrl 필드를 포함하여 Show.fromMap에 전달
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Show.fromMap(doc.id, data);
      }).toList();
    }
  }
}
