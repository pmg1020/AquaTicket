import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:aquaticket/services/storage_service.dart';
import 'package:intl/intl.dart';

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
  final _basePriceController = TextEditingController();

  String? selectedVenueId;
  List<String> venueOptions = [];

  String? _posterImageUrl;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _loadVenues();
    _basePriceController.text = '70000';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _typeController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _maxTicketsController.dispose();
    _basePriceController.dispose();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    final snapshot = await FirebaseFirestore.instance.collection('venues').get();
    setState(() {
      venueOptions = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _pickAndUploadPoster() async {
    setState(() {
      _posterImageUrl = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('포스터 이미지를 업로드 중입니다...')),
    );
    try {
      final imageUrl = await _storageService.pickAndUploadImage();
      if (imageUrl != null) {
        setState(() {
          _posterImageUrl = imageUrl;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ 포스터 이미지 업로드 완료!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지 선택이 취소되었습니다.')),
        );
      }
    } catch (e) {
      print("포스터 업로드 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('포스터 업로드 실패: $e')),
      );
    }
  }

  Future<void> _submitShow() async {
    final title = _titleController.text;
    final type = _typeController.text;
    final location = _locationController.text;
    final rawDates = _dateController.text.split(',').map((e) => e.trim()).toList();
    final maxTicketsPerUser = int.tryParse(_maxTicketsController.text) ?? 1;
    final basePrice = int.tryParse(_basePriceController.text) ?? 70000;

    final List<String> formattedDates = [];
    for (String dateStr in rawDates) {
      try {
        DateTime parsedDateTime;
        if (dateStr.contains('T')) {
          parsedDateTime = DateTime.parse(dateStr);
        } else {
          parsedDateTime = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
        }
        formattedDates.add(DateFormat('yyyy-MM-dd HH:mm').format(parsedDateTime));
      } catch (e) {
        print("날짜 파싱 오류: $dateStr -> $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('날짜 형식 오류: $dateStr. YYYY-MM-DD HH:MM 형식인지 확인해주세요.')),
        );
        return;
      }
    }

    if (title.isEmpty || type.isEmpty || location.isEmpty || selectedVenueId == null || _posterImageUrl == null || formattedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 필드를 입력하고 포스터 이미지를 업로드해주세요.")),
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

      List<Map<String, dynamic>> simplifiedSeatSections = [];
      if (venueData != null && venueData['sections'] is List) {
        for (var sectionItem in venueData['sections']) {
          if (sectionItem is Map<dynamic, dynamic>) {
            Map<String, dynamic> simplifiedSection = {};
            if (sectionItem['name'] is String) simplifiedSection['name'] = sectionItem['name'];
            if (sectionItem['grade'] is String) simplifiedSection['grade'] = sectionItem['grade'];
            if (sectionItem['rows'] is int) simplifiedSection['rows'] = sectionItem['rows'];
            if (sectionItem['columns'] is int) simplifiedSection['columns'] = sectionItem['columns'];

            simplifiedSeatSections.add(simplifiedSection);
          }
        }
      }


      final showData = {
        'title': title,
        'type': type,
        'location': location,
        'date': formattedDates,
        'seatSections': simplifiedSeatSections,
        'venueId': selectedVenueId,
        'maxTicketsPerUser': maxTicketsPerUser,
        'posterImageUrl': _posterImageUrl,
        'basePrice': basePrice,
        'createdAt': FieldValue.serverTimestamp(),
      };

      print("Debug: Firestore showData being sent: $showData");

      await FirebaseFirestore.instance.collection('shows').add(showData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("공연이 성공적으로 등록되었습니다.")),
      );
      Navigator.pop(context);
    } on FirebaseException catch (e) {
      print('공연 등록 Firebase 에러: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("공연 등록에 실패했습니다: ${e.code} - ${e.message}")),
      );
    } catch (e) {
      print('공연 등록 일반 에러: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("공연 등록에 실패했습니다: ${e.toString()}")),
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
              const SizedBox(height: 16), // ✅ 간격 추가
              TextField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: "공연 유형"),
              ),
              const SizedBox(height: 16), // ✅ 간격 추가
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: "공연 장소"),
              ),
              const SizedBox(height: 16), // ✅ 간격 추가
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: "공연 날짜 (쉼표로 구분, YYYY-MM-DD HH:MM 형식)"),
              ),
              const SizedBox(height: 16), // ✅ 간격 추가
              TextField(
                controller: _maxTicketsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "예매 가능 최대 수"),
              ),
              const SizedBox(height: 16), // ✅ 간격 추가
              TextField(
                controller: _basePriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "기본 좌석 가격 (예: 70000)"),
              ),
              const SizedBox(height: 16), // ✅ 간격 추가
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
              _posterImageUrl == null
                  ? ElevatedButton.icon(
                onPressed: _pickAndUploadPoster,
                icon: const Icon(Icons.upload_file),
                label: const Text("포스터 이미지 업로드"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
                  : Column(
                children: [
                  Image.network(
                    _posterImageUrl!,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(child: Text('이미지 로드 실패')),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: _pickAndUploadPoster,
                    child: const Text('포스터 이미지 변경'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitShow,
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
