import 'package:flutter/material.dart';
import '../../services/reservation_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './reservation_detail_page.dart';
import 'package:intl/intl.dart';

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  final ReservationService _reservationService = ReservationService();
  late Future<List<Map<String, dynamic>>> _reservationsFuture;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  void _loadReservations() {
    _reservationsFuture = _reservationService.getMyReservations();
  }

  String _getDayOfWeek(int weekday) {
    switch (weekday) {
      case DateTime.monday: return '월';
      case DateTime.tuesday: return '화';
      case DateTime.wednesday: return '수';
      case DateTime.thursday: return '목';
      case DateTime.friday: return '금';
      case DateTime.saturday: return '토';
      case DateTime.sunday: return '일';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text(
          '내 예매 내역',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _reservationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('오류 발생: ${snapshot.error}'));
          }

          final reservations = snapshot.data!;
          if (reservations.isEmpty) {
            return const Center(
              child: Text(
                '예매 내역이 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final res = reservations[index];
              final reservedAt = (res['reservedAt'] as Timestamp).toDate();

              String displayShowDateTime = '날짜 없음';
              if (res['dateTime'] != null) {
                try {
                  final showDateTime = DateTime.parse(res['dateTime'] as String);
                  final formattedDate = DateFormat('yyyy년 MM월 dd일').format(showDateTime);
                  final formattedTime = DateFormat('HH시mm분').format(showDateTime);
                  final dayOfWeek = _getDayOfWeek(showDateTime.weekday);
                  displayShowDateTime = '$formattedDate ($dayOfWeek) $formattedTime';
                } catch (e) {
                  displayShowDateTime = '날짜 포맷 오류';
                }
              }

              final int numberOfSeats = (res['seats'] as List<dynamic>?)?.length ?? 0;
              // ✅ posterImageUrl 가져오기
              final String? posterImageUrl = res['posterImageUrl'] as String?;

              return GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationDetailPage(reservation: res),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _loadReservations();
                    });
                  }
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // ✅ 포스터 이미지 표시 (기존 아이콘 대체)
                        Container(
                          width: 60,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[200],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: posterImageUrl != null && posterImageUrl.isNotEmpty
                              ? Image.network(
                            posterImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.broken_image, size: 40, color: Colors.grey[400]);
                            },
                          )
                              : Icon(Icons.confirmation_num, size: 40, color: Colors.grey[400]), // 이미지 없을 때 기본 아이콘
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                res['showTitle'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '일시: $displayShowDateTime / 좌석 수: $numberOfSeats석',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '총 금액: ${NumberFormat('#,###', 'ko_KR').format(res['totalPrice'] ?? 0)}원',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              '예약일',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              DateFormat('yyyy-MM-dd HH:mm').format(reservedAt),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
