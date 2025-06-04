import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminShowCreatePage extends StatefulWidget {
  const AdminShowCreatePage({super.key});

  @override
  State<AdminShowCreatePage> createState() => _AdminShowCreatePageState();
}

class _AdminShowCreatePageState extends State<AdminShowCreatePage> {
  final _titleController = TextEditingController();
  final _typeController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _maxTicketsController = TextEditingController();

  String? selectedVenueId;
  List<String> venueOptions = [];

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    final snapshot = await FirebaseFirestore.instance.collection('venues').get();
    setState(() {
      venueOptions = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _submitShow() async {
    final title = _titleController.text;
    final type = _typeController.text;
    final location = _locationController.text;
    final dates = _dateController.text.split(',').map((e) => e.trim()).toList();
    final maxTicketsPerUser = int.tryParse(_maxTicketsController.text) ?? 1;

    if (title.isEmpty || type.isEmpty || location.isEmpty || selectedVenueId == null || dates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 입력해주세요.")),
      );
      return;
    }

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("로그인된 사용자가 없습니다.");
      }

      final venueRef = FirebaseFirestore.instance.collection('venues').doc(selectedVenueId);
      final venueDoc = await venueRef.get();
      final venueData = venueDoc.data();
      final seatSections = List<Map<String, dynamic>>.from(venueData?['sections'] ?? []);

      await FirebaseFirestore.instance.collection('shows').add({
        'title': title,
        'type': type,
        'location': location,
        'date': dates,
        'seatSections': seatSections,
        'venueId': selectedVenueId,
        'maxTicketsPerUser': maxTicketsPerUser,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("공연이 성공적으로 등록되었습니다.")),
      );
      Navigator.pop(context);
    } catch (e) {
      print('에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("공연 등록에 실패했습니다.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("공연 등록")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "공연 제목"),
              ),
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: "공연 유형"),
              ),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "공연 장소"),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "공연 날짜 (쉼표로 구분)"),
              ),
              TextField(
                controller: _maxTicketsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "예매 가능 최대 수"),
              ),
              const SizedBox(height: 16),
              DropdownButton<String>(
                isExpanded: true,
                value: selectedVenueId,
                hint: const Text("공연장 선택"),
                items: venueOptions.map((venueId) {
                  return DropdownMenuItem<String>(
                    value: venueId,
                    child: Text(venueId),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedVenueId = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: selectedVenueId != null ? _submitShow : null,
                icon: const Icon(Icons.add),
                label: const Text("공연 등록"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
