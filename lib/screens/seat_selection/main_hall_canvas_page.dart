import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../reservation/reservation_confirmation_page.dart';
import 'widgets/main_canvas_layout.dart';
import 'widgets/detail_canvas_layout.dart';
import 'widgets/outer_seating_block.dart';
import 'show_time_selector.dart';


class MainHallCanvasPage extends StatefulWidget {
  final String showId;
  final String showTitle;
  final String selectedDateTime; // 초기 선택된 회차 (날짜 + 시간 문자열)
  final String venueId;
  final int maxTicketsPerUser;

  const MainHallCanvasPage({
    super.key,
    required this.showId,
    required this.showTitle,
    required this.selectedDateTime,
    required this.venueId,
    required this.maxTicketsPerUser,
  });

  @override
  State<MainHallCanvasPage> createState() => _MainHallCanvasPageState();
}

class _MainHallCanvasPageState extends State<MainHallCanvasPage> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  String _currentView = 'main';
  String _selectedSectionName = '';

  String? _selectedGrade;
  List<Map<String, dynamic>> _allSections = [];

  int rows = 0;
  int columns = 0;
  List<List<Map<String, dynamic>>> seats = [];
  List<String> selectedSeats = [];
  int totalPrice = 0;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    try {
      final initialDateTimeString = widget.selectedDateTime.replaceFirst(' ', 'T');
      final initialDateTime = DateTime.parse(initialDateTimeString);
      _selectedDate = DateTime(initialDateTime.year, initialDateTime.month, initialDateTime.day);
      _selectedTime = TimeOfDay(hour: initialDateTime.hour, minute: initialDateTime.minute);
    } catch (e) {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      print("초기 selectedDateTime 파싱 오류: $e. 기본값으로 설정됨: $_selectedDate $_selectedTime");
    }
    _loadAllVenueSections();
  }

  Future<void> _loadAllVenueSections() async {
    try {
      final querySnapshot = await _firestore
          .collection('venues')
          .doc(widget.venueId)
          .collection('sections')
          .get();

      if (mounted) {
        setState(() {
          _allSections = querySnapshot.docs.map((doc) => doc.data()).toList();
        });
      }
      print("모든 섹션 로드 완료: $_allSections");
    } catch (e) {
      print("모든 섹션 로드 오류: $e");
    }
  }

  // 하단 팝업을 통해 날짜 및 회차를 변경하는 함수
  Future<void> _showChangeDateTimeBottomSheet(BuildContext context) async {
    DateTime tempPickedDate = _selectedDate;
    TimeOfDay? tempPickedTime = _selectedTime;
    List<TimeOfDay> availableTimesForSelectedDate = [];
    bool isLoadingTimes = true;

    Future<List<TimeOfDay>> fetchAvailableTimes(DateTime date) async {
      print("Fetching available times for ${DateFormat('yyyy-MM-dd').format(date)}...");
      await Future.delayed(const Duration(milliseconds: 500));
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        return [
          const TimeOfDay(hour: 14, minute: 0),
          const TimeOfDay(hour: 18, minute: 30),
        ];
      } else {
        return [
          const TimeOfDay(hour: 19, minute: 0),
        ];
      }
    }

    availableTimesForSelectedDate = await fetchAvailableTimes(tempPickedDate);
    isLoadingTimes = false;
    if (availableTimesForSelectedDate.isNotEmpty) {
      if (tempPickedTime == null || !availableTimesForSelectedDate.contains(tempPickedTime)) {
        tempPickedTime = availableTimesForSelectedDate.first;
      }
    } else {
      tempPickedTime = null;
    }

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext modalContext, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.only(
                  top: 20, left: 20, right: 20,
                  bottom: MediaQuery.of(modalContext).viewInsets.bottom + 20
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "날짜 및 회차 변경",
                      style: Theme.of(modalContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    ListTile(
                      title: Text("날짜: ${DateFormat('yyyy년 MM월 dd일 EEEE', 'ko_KR').format(tempPickedDate)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: modalContext,
                          initialDate: tempPickedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          locale: const Locale('ko', 'KR'),
                        );
                        if (pickedDate != null && pickedDate != tempPickedDate) {
                          setModalState(() {
                            tempPickedDate = pickedDate;
                            isLoadingTimes = true;
                            availableTimesForSelectedDate = [];
                            tempPickedTime = null;
                          });
                          List<TimeOfDay> newTimes = await fetchAvailableTimes(tempPickedDate);
                          setModalState(() {
                            availableTimesForSelectedDate = newTimes;
                            if (availableTimesForSelectedDate.isNotEmpty) {
                              tempPickedTime = availableTimesForSelectedDate.first;
                            }
                            isLoadingTimes = false;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text("시간 선택:", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 5),
                    if (isLoadingTimes)
                      const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                    else if (availableTimesForSelectedDate.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: Text("선택하신 날짜에 예매 가능한 회차가 없습니다.")),
                      )
                    else
                      Wrap(
                        spacing: 8.0,
                        children: availableTimesForSelectedDate.map((time) {
                          bool isSelected = tempPickedTime == time;
                          return ChoiceChip(
                            label: Text(
                              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                            ),
                            selected: isSelected,
                            selectedColor: Theme.of(modalContext).primaryColor,
                            backgroundColor: Colors.grey[200],
                            onSelected: (bool selected) {
                              if (selected) {
                                setModalState(() {
                                  tempPickedTime = time;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),

                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          child: const Text("취소"),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          child: const Text("선택 완료"),
                          onPressed: (tempPickedDate != null && tempPickedTime != null)
                              ? () {
                            Navigator.pop(sheetContext, {
                              'date': tempPickedDate,
                              'time': tempPickedTime,
                            });
                          }
                              : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null && result['date'] != null && result['time'] != null) {
      if (mounted) {
        setState(() {
          _selectedDate = result['date'];
          _selectedTime = result['time'];

          if (_selectedSectionName.isNotEmpty && _currentView == 'detail') {
            _loadSeatsForSection(_selectedSectionName);
          } else if (_currentView == 'main') {
            selectedSeats.clear();
            totalPrice = 0;
          }
          print("날짜/시간 변경 완료: $_selectedDate ${_selectedTime.format(context)}");
        });
      }
    }
  }

  // 맵의 구역 클릭 시 호출되는 팝업 함수
  void _showZoneSelectionDialog(BuildContext context, String sectionName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("선택 구역"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("$sectionName 구역"),
              const SizedBox(height: 10),
              const Text("상세 구역 잔여좌석 현황이\n제공되지 않는 상품입니다.", textAlign: TextAlign.center),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("닫기"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if(mounted) {
                  setState(() {
                    _selectedSectionName = sectionName;
                    _currentView = 'detail'; // 바로 상세 좌석 그리드 화면으로 전환
                  });
                }
                _loadSeatsForSection(sectionName); // 상세 좌석 데이터 로드
              },
              child: const Text("이동"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSeatsForSection(String sectionName) async {
    try {
      final sectionRef = _firestore
          .collection('venues')
          .doc(widget.venueId)
          .collection('sections')
          .doc(sectionName);

      final sectionSnap = await sectionRef.get();
      final sectionData = sectionSnap.data();
      if (sectionData == null) {
        print("섹션 데이터 없음: $sectionName");
        if(mounted) {
          setState(() {
            rows = 0;
            columns = 0;
            seats = [];
            selectedSeats = [];
            totalPrice = 0;
          });
        }
        return;
      }

      if(mounted) {
        setState(() {
          rows = sectionData['rows'] ?? 0;
          columns = sectionData['columns'] ?? 0;
          selectedSeats = [];
          totalPrice = 0;
        });
      }

      final seatQuery = await sectionRef.collection('seats').get();
      final seatMap = <String, Map<String, dynamic>>{};
      for (var doc in seatQuery.docs) {
        seatMap[doc.id] = doc.data();
      }

      List<List<Map<String, dynamic>>> tempSeats = [];
      for (int r = 1; r <= (sectionData['rows'] ?? 0); r++) {
        List<Map<String, dynamic>> rowSeats = [];
        for (int c = 1; c <= (sectionData['columns'] ?? 0); c++) {
          final seatNumber = '$sectionName-$r-$c';
          rowSeats.add({
            'seatNumber': seatNumber,
            'isReserved': seatMap[seatNumber]?['isReserved'] ?? false,
            'grade': sectionData['grade'] ?? 'NORMAL',
            'price': _getSeatPrice(sectionData['grade'] ?? 'NORMAL'),
          });
        }
        tempSeats.add(rowSeats);
      }

      if(mounted) {
        setState(() {
          seats = tempSeats;
        });
      }
    } catch (e) {
      print("좌석 불러오기 오류 ($sectionName): $e");
      if(mounted) {
        setState(() {
          rows = 0;
          columns = 0;
          seats = [];
          selectedSeats = [];
          totalPrice = 0;
        });
      }
    }
  }

  void _toggleSeat(int row, int col) {
    final seat = seats[row][col];
    final seatNumber = seat['seatNumber'];
    final isReserved = seat['isReserved'];
    final seatPrice = seat['price'] as int;

    if (isReserved) return;

    if (mounted) {
      setState(() {
        if (selectedSeats.contains(seatNumber)) {
          selectedSeats.remove(seatNumber);
          totalPrice -= seatPrice;
        } else {
          if (selectedSeats.length < widget.maxTicketsPerUser) {
            selectedSeats.add(seatNumber);
            totalPrice += seatPrice;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("최대 ${widget.maxTicketsPerUser}자리까지만 선택 가능합니다.")),
            );
          }
        }
      });
    }
  }

  Color _getSeatColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'VIP': return Colors.red;
      case 'SR': return Colors.orange;
      case 'R1': case 'R2': return Colors.green;
      case 'S': return Colors.blue;
      case 'A': return Colors.purple;
      case 'VIP_TABLE': return Colors.deepOrange;
      case 'ZONE': return Colors.purple[300]!;
      case 'NORMAL_2F': return const Color(0xFFD4C8A6);
      default: return const Color(0xFFD4C8A6);
    }
  }

  int _getSeatPrice(String grade) {
    switch (grade.toUpperCase()) {
      case 'VIP': return 150000;
      case 'SR': return 120000;
      case 'R1': case 'R2': return 100000;
      case 'S': return 80000;
      case 'A': return 60000;
      case 'VIP_TABLE': return 180000;
      case 'ZONE': return 110000;
      case 'NORMAL_2F': return 70000;
      default: return 70000;
    }
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

  List<String> _getSectionsForGrade(String gradeType) {
    String firebaseGrade;
    if (gradeType == "스탠딩석") {
      firebaseGrade = "ZONE";
    } else {
      firebaseGrade = "NORMAL_2F";
    }
    return _allSections
        .where((section) => section['grade'] == firebaseGrade)
        .map((section) => section['name'] as String)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentFullDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    final String currentSelectedDateTimeString =
        "${DateFormat('yyyy-MM-dd').format(_selectedDate)} ${DateFormat('HH:mm').format(DateTime(0,0,0, _selectedTime.hour, _selectedTime.minute))}";

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentView == 'main' ? widget.showTitle : _selectedSectionName),
        leading: _currentView == 'detail'
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (mounted) {
              setState(() {
                _currentView = 'main';
                selectedSeats = [];
                totalPrice = 0;
                _selectedGrade = null;
                _selectedSectionName = '';
              });
            }
          },
        )
            : null,
      ),
      body: _currentView == 'main'
          ? MainCanvasLayout(
        showTitle: widget.showTitle,
        selectedDate: currentFullDateTime,
        onDateChangePressed: () => _showChangeDateTimeBottomSheet(context),
        selectedGrade: _selectedGrade,
        onGradeSelected: (grade) {
          if (mounted) {
            setState(() {
              _selectedGrade = grade;
              _selectedSectionName = '';
            });
          }
        },
        allSections: _allSections,
        onZoneBlockTap: (ctx, name) => _showZoneSelectionDialog(ctx, name),
        getDayOfWeek: _getDayOfWeek,
        getSectionsForGrade: _getSectionsForGrade,
        currentView: _currentView,
        selectedSectionName: _selectedSectionName,
        selectedSeats: selectedSeats,
        totalPrice: totalPrice,
        maxTicketsPerUser: widget.maxTicketsPerUser,
        onRefreshPressed: () {
          if (mounted) {
            setState(() {
              _selectedGrade = null;
              _selectedSectionName = '';
              selectedSeats = [];
              totalPrice = 0;
            });
          }
          _loadAllVenueSections();
        },
        onSelectSeatsPressed: () {
          if (_selectedSectionName.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("먼저 구역을 선택해주세요.")),
            );
          } else {
            if (mounted) {
              setState(() {
                _currentView = 'detail';
              });
            }
            _loadSeatsForSection(_selectedSectionName);
          }
        },
        onSectionSelectedFromList: (sectionName) {
          if (mounted) {
            setState(() {
              _selectedSectionName = sectionName;
            });
          }
        },
      )
          : DetailCanvasLayout(
        showTitle: widget.showTitle,
        selectedDate: _selectedDate,
        selectedSectionName: _selectedSectionName,
        seats: seats,
        selectedSeats: selectedSeats,
        totalPrice: totalPrice,
        onSeatToggled: _toggleSeat,
        onSectionChangePressed: () {
          if (mounted) {
            setState(() {
              _currentView = 'main';
              selectedSeats = [];
              totalPrice = 0;
              _selectedGrade = null;
              _selectedSectionName = '';
            });
          }
        },
        onRefreshSeatsPressed: () {
          _loadSeatsForSection(_selectedSectionName);
        },
        onConfirmSelectionPressed: selectedSeats.isEmpty
            ? () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("좌석을 선택해주세요.")),
          );
        }
            : () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReservationConfirmationPage(
                showId: widget.showId,
                showTitle: widget.showTitle,
                selectedDateTime: currentSelectedDateTimeString,
                sectionName: _selectedSectionName,
                selectedSeats: selectedSeats,
                totalPrice: totalPrice,
              ),
            ),
          );
        },
        getSeatColor: _getSeatColor,
        getDayOfWeek: _getDayOfWeek,
      ),
    );
  }
}
