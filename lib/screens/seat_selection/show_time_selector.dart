import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showShowTimePicker({
  required BuildContext context,
  required String showId,
  required Function(String selectedTime) onTimeSelected,
}) async {
  final doc = await FirebaseFirestore.instance
      .collection('shows')
      .doc(showId)
      .get();

  if (!doc.exists) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('공연 정보를 불러오지 못했습니다.')),
    );
    return;
  }

  final data = doc.data();
  if (data == null || data['date'] == null) return;

  final List<dynamic> rawDates = data['date'];
  final List<String> showTimes = rawDates.cast<String>();

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Text("회차를 선택해주세요", style: TextStyle(fontSize: 18)),
          const Divider(),
          ...showTimes.map((time) {
            return ListTile(
              title: Text(time),
              onTap: () {
                Navigator.pop(context);
                onTimeSelected(time);
              },
            );
          }).toList(),
        ],
      );
    },
  );
}
