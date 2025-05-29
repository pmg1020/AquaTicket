import 'package:flutter/material.dart';
import '../../models/show.dart';
import '../../services/reservation_service.dart';

class ReservePage extends StatefulWidget {
  final Show show;

  const ReservePage({super.key, required this.show});

  @override
  State<ReservePage> createState() => _ReservePageState();
}

class _ReservePageState extends State<ReservePage> {
  int _selectedPeople = 1;
  String? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.show.date.length == 1) {
      _selectedDate = widget.show.date.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('${widget.show.title} 예매'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.confirmation_num, size: 48, color: Colors.black87),
            const SizedBox(height: 16),
            Text(
              widget.show.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),

            // 날짜 선택
            const Text('날짜 선택', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            widget.show.date.length == 1
                ? Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(widget.show.date.first, style: const TextStyle(fontSize: 16)),
            )
                : DropdownButtonFormField<String>(
              value: _selectedDate,
              hint: const Text('날짜를 선택하세요'),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: widget.show.date.map((date) {
                return DropdownMenuItem(value: date, child: Text(date));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDate = value;
                });
              },
            ),

            const SizedBox(height: 24),

            // 인원 선택
            const Text('인원 수', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _selectedPeople,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: List.generate(10, (i) => i + 1)
                  .map((num) => DropdownMenuItem(value: num, child: Text('$num명')))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPeople = value!;
                });
              },
            ),

            const Spacer(),

            // 예매 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDate == null
                    ? null
                    : () async {
                  try {
                    await ReservationService().reserve(
                      showId: widget.show.id,
                      showTitle: widget.show.title,
                      date: _selectedDate!,
                      people: _selectedPeople,
                    );

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('예매 완료'),
                        content: Text(
                          '${widget.show.title} 공연\n날짜: $_selectedDate\n인원: $_selectedPeople명',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('확인'),
                          ),
                        ],
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('예매 실패: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('예매 확정', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
