import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SeatGridPage extends StatefulWidget {
  final String showId;
  final String selectedDateTime;
  final String sectionName;

  const SeatGridPage({
    super.key,
    required this.showId,
    required this.selectedDateTime,
    required this.sectionName,
  });

  @override
  State<SeatGridPage> createState() => _SeatGridPageState();
}

class _SeatGridPageState extends State<SeatGridPage> {
  int rows = 0;
  int columns = 0;
  List<List<Map<String, dynamic>>> seats = [];
  List<String> selectedSeats = [];
  int maxTicketsPerUser = 1;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    try {
      final showDoc = await FirebaseFirestore.instance
          .collection('shows')
          .doc(widget.showId)
          .get();

      final showData = showDoc.data();
      if (showData == null || showData['venueId'] == null) return;

      maxTicketsPerUser = showData['maxTicketsPerUser'] ?? 1;

      final venueId = showData['venueId'];
      final sectionRef = FirebaseFirestore.instance
          .collection('venues')
          .doc(venueId)
          .collection('sections')
          .doc(widget.sectionName);

      final sectionSnap = await sectionRef.get();
      final sectionData = sectionSnap.data();
      if (sectionData == null) return;

      rows = sectionData['rows'] ?? 0;
      columns = sectionData['columns'] ?? 0;

      final seatQuery = await sectionRef.collection('seats').get();
      final seatMap = <String, Map<String, dynamic>>{};
      for (var doc in seatQuery.docs) {
        seatMap[doc.id] = doc.data();
      }

      List<List<Map<String, dynamic>>> tempSeats = [];
      for (int r = 1; r <= rows; r++) {
        List<Map<String, dynamic>> rowSeats = [];
        for (int c = 1; c <= columns; c++) {
          final seatNumber = '${widget.sectionName}$r-$c';
          rowSeats.add({
            'seatNumber': seatNumber,
            'isReserved': seatMap[seatNumber]?['isReserved'] ?? false,
            'grade': seatMap[seatNumber]?['grade'] ?? 'NORMAL',
          });
        }
        tempSeats.add(rowSeats);
      }

      setState(() {
        seats = tempSeats;
      });
    } catch (e) {
      print("좌석 불러오기 오류: $e");
    }
  }

  void _toggleSeat(int row, int col) {
    final seatNumber = seats[row][col]['seatNumber'];
    final isReserved = seats[row][col]['isReserved'];

    if (isReserved) return;

    setState(() {
      if (selectedSeats.contains(seatNumber)) {
        selectedSeats.remove(seatNumber);
      } else {
        if (selectedSeats.length < maxTicketsPerUser) {
          selectedSeats.add(seatNumber);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("최대 $maxTicketsPerUser자리까지만 선택 가능합니다.")),
          );
        }
      }
    });
  }

  Color _getSeatColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'VIP':
        return Colors.purple;
      case 'R':
      case 'R석':
        return Colors.red;
      case 'A':
      case 'A석':
        return Colors.blue;
      case 'B석':
        return Colors.green;
      case 'S1':
      case 'S2':
      case '스탠딩':
      case '플로어':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("좌석 선택 - ${widget.sectionName}")),
      body: seats.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            children: seats.asMap().entries.map((entry) {
              int rowIndex = entry.key;
              List<Map<String, dynamic>> rowSeats = entry.value;

              return Row(
                children: rowSeats.asMap().entries.map((seatEntry) {
                  int colIndex = seatEntry.key;
                  Map<String, dynamic> seat = seatEntry.value;
                  bool isReserved = seat['isReserved'];
                  String grade = (seat['grade'] ?? 'NORMAL').toString();
                  String seatNumber = (seat['seatNumber'] ?? '').toString();

                  final isSelected = selectedSeats.contains(seatNumber);

                  return GestureDetector(
                    onTap: () => _toggleSeat(rowIndex, colIndex),
                    child: Container(
                      width: 30,
                      height: 30,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isReserved
                            ? Colors.grey
                            : _getSeatColor(grade),
                        border: isSelected
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                }).toList(),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
