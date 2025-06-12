import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 intl 패키지 필요
import '../../models/show.dart';
import '../../services/show_service.dart';
import 'show_detail_page.dart';

class ShowListPage extends StatefulWidget {
  const ShowListPage({super.key});

  @override
  State<ShowListPage> createState() => _ShowListPageState();
}

class _ShowListPageState extends State<ShowListPage> {
  late Future<List<Show>> _showsFuture;

  @override
  void initState() {
    super.initState();
    _showsFuture = ShowService().getShows();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text('공연 목록', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<List<Show>>(
        future: _showsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('공연 정보가 없습니다.'));
          }

          final shows = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: shows.length,
            itemBuilder: (context, index) {
              final show = shows[index];

              // 날짜 포맷팅 로직
              String displayDate = '날짜 없음';
              if (show.date.isNotEmpty) {
                try {
                  // 첫 번째 날짜/시간 문자열만 가져와서 파싱
                  final dateTime = DateTime.parse(show.date[0]);
                  displayDate = DateFormat('yyyy-MM-dd').format(dateTime); // YYYY-MM-DD 형식으로 포맷팅
                } catch (e) {
                  displayDate = '날짜 오류'; // 파싱 실패 시
                }
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ShowDetailPage(show: show),
                    ),
                  );
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
                        const Icon(Icons.theaters, size: 40, color: Colors.black87),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                show.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${show.type} | ${show.location}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          displayDate, // 포맷팅된 날짜 표시
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
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
