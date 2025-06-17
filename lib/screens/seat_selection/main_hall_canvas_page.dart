import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // 날짜 포맷팅을 위해 intl 패키지 임포트
import '../reservation/reservation_confirmation_page.dart';
import 'widgets/main_canvas_layout.dart';
import 'widgets/detail_canvas_layout.dart';
import 'widgets/outer_seating_block.dart';
import 'show_time_selector.dart'; // show_time_selector.dart 임포트


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
      print("Loading seats for section: $sectionName, Show ID: ${widget.showId}, Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute))}");

      final sectionRef = _firestore
          .collection('venues')
          .doc(widget.venueId)
          .collection('sections')
          .doc(sectionName);

      final sectionSnap = await sectionRef.get();
      final sectionData = sectionSnap.data();

      if (sectionData == null || sectionData['rows'] == null || sectionData['columns'] == null) {
        print("섹션 데이터 불완전하거나 없음: $sectionName. Data: $sectionData");
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

      final String currentSelectedDateTimeString =
          "${DateFormat('yyyy-MM-dd').format(_selectedDate)} ${DateFormat('HH:mm').format(DateTime(0,0,0, _selectedTime.hour, _selectedTime.minute))}";
      print("Querying reservations for showId: ${widget.showId}, dateTime: $currentSelectedDateTimeString, section: $sectionName");

      Set<String> currentlyReservedSeatNumbers = {};
      final appId = const String.fromEnvironment('APP_ID', defaultValue: 'default-app-id');

      final usersSnapshot = await _firestore.collection('artifacts').doc(appId).collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userReservationsSnapshot = await _firestore
            .collection('artifacts')
            .doc(appId)
            .collection('users')
            .doc(userId)
            .collection('reservations')
            .where('showId', isEqualTo: widget.showId)
            .where('dateTime', isEqualTo: currentSelectedDateTimeString)
            .where('section', isEqualTo: sectionName)
            .get();

        for (var resDoc in userReservationsSnapshot.docs) {
          final List<dynamic> bookedSeats = resDoc.data()['seats'] ?? [];
          print("Found reservation doc ${resDoc.id}, seats: $bookedSeats"); // Debugging
          for (var seat in bookedSeats) {
            currentlyReservedSeatNumbers.add(seat as String);
          }
        }
      }
      print("총 예약된 좌석 수 (이 회차, 이 섹션): ${currentlyReservedSeatNumbers.length}");
      print("예약된 좌석 번호 목록: $currentlyReservedSeatNumbers"); // Debugging


      List<List<Map<String, dynamic>>> tempSeats = [];
      final allSeatsInThisSectionQuery = await sectionRef.collection('seats').get();
      final Map<String, Map<String, dynamic>> allSeatsMap = {
        for (var doc in allSeatsInThisSectionQuery.docs)
          doc.id: doc.data()
      };


      for (int r = 1; r <= rows; r++) {
        List<Map<String, dynamic>> rowSeats = [];
        for (int c = 1; c <= columns; c++) {
          final seatNumber = '$sectionName-$r-$c';
          final bool isReservedForThisShow = currentlyReservedSeatNumbers.contains(seatNumber);

          String seatGrade = allSeatsMap[seatNumber]?['grade'] ?? 'NORMAL';
          int seatPrice = _getSeatPrice(seatGrade);

          rowSeats.add({
            'seatNumber': seatNumber,
            'isReserved': isReservedForThisShow,
            'grade': seatGrade,
            'price': seatPrice,
          });
        }
        tempSeats.add(rowSeats);
      }

      if(mounted) {
        setState(() {
          seats = tempSeats;
        });
      }
      print("좌석 그리드 데이터 생성 완료. Rows: $rows, Columns: $columns");
    } catch (e) {
      print("좌석 불러오기 오류 ($sectionName): $e");
      if (e is FirebaseException) {
        print("Firebase Exception Code: ${e.code}");
        print("Firebase Exception Message: ${e.message}");
      }
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
        onDateChangePressed: () {
          showShowTimePicker( // ✅ await 제거
            context: context,
            showId: widget.showId,
            onTimeSelected: (selectedTimeStr) {
              final parsedDateTime = DateTime.parse(selectedTimeStr.replaceFirst(' ', 'T'));
              if(mounted) {
                setState(() {
                  _selectedDate = DateTime(parsedDateTime.year, parsedDateTime.month, parsedDateTime.day);
                  _selectedTime = TimeOfDay(hour: parsedDateTime.hour, minute: parsedDateTime.minute);
                  _selectedSectionName = '';
                  _selectedGrade = null;
                  selectedSeats = [];
                  totalPrice = 0;
                });
              }
              _loadAllVenueSections();
            },
          );
        },
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
