import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:routine_ade/routine_myInfo/MyInfo.dart';
import 'package:routine_ade/routine_group/GroupType.dart';
import 'AddRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_home/AlarmListPage.dart';
import 'package:routine_ade/routine_home/ModifiedRoutinePage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_user/token.dart';
import 'package:routine_ade/routine_statistics/StaticsCalendar.dart';
import 'package:routine_ade/routine_otherUser/OtherUserRoutinePage.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const MyRoutinePage());
}

class MyRoutinePage extends StatefulWidget {
  const MyRoutinePage({super.key});

  @override
  State<MyRoutinePage> createState() => _MyRoutinePageState();
}

class _MyRoutinePageState extends State<MyRoutinePage>
    with SingleTickerProviderStateMixin {
  Future<RoutineResponse>?
  futureRoutineResponse; // late 키워드를 사용하여 초기화를 나중에 하도록 설정
  String selectedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
  late CalendarWeekController _controller;
  String? userEmotion;

  bool _isTileExpanded = false;

  late TabController _tabController;
  bool _isExpanded = false;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller = CalendarWeekController();
    futureRoutineResponse = fetchRoutines(selectedDate);
    _tabController = TabController(length: 4, vsync: this);
    _fetchEmotionForSelectedDate(selectedDate);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = DateFormat('yyyy.MM.dd').format(date);
      futureRoutineResponse = fetchRoutines(selectedDate);
      _isTileExpanded = true; // 날짜를 선택할 때마다 ExpansionTile이 펼쳐지도록 설정
      // _showBottomSheet(date);
      _fetchEmotionForSelectedDate(selectedDate);
    });
  }

  void _fetchEmotionForSelectedDate(String date) async {
    try {
      final response = await fetchRoutines(date);
      setState(() {
        userEmotion = response.userEmotion;
      });
    } catch (e) {
      print("Failed to fetch emotion for selected date: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showBottomSheet(DateTime date) async {
    final String? selectedImage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheetContent(date);
      },
    );

    if (selectedImage != null) {
      setState(() {
        _selectedImage = selectedImage;
      });

      await _registerEmotion(date, selectedImage);
    }
  }

// 감정 등록 메서드
  Future<void> _registerEmotion(DateTime date, String selectedImage) async {
    final today = DateTime.now();
    final isPastOrToday = date.isBefore(today) || date.isAtSameMomentAs(today);

    if (!isPastOrToday) {
      // 선택한 날짜가 미래일 경우 알림 메시지를 표시하고 등록을 차단
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('과거와 오늘 날짜만 선택 가능합니다.')),
        );
      }
      return;
    }

    final formattedDate = DateFormat("yyyy.MM.dd").format(date);
    final url = Uri.parse("http://15.164.88.94/users/emotion");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };

    final body = jsonEncode({
      "date": formattedDate,
      "userEmotion": getImageEmotion2(selectedImage),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("감정 등록 성공");

        // 감정 등록 후 상태 업데이트
        setState(() {
          userEmotion = getImageEmotion2(selectedImage); // 새로운 감정 상태를 반영
          futureRoutineResponse =
              fetchRoutines(selectedDate); // 감정 등록 후 데이터를 다시 가져옴
        });

        // 감정 등록 성공 메시지
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('감정이 성공적으로 등록되었습니다.')),
          );
        }
      } else {
        print("감정 등록 실패: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("감정 등록 중 에러: $e");
    }
  }

  Widget _buildBottomSheetContent(DateTime date) {
    return SizedBox(
      height: 250,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              '${date.year}년 ${date.month}월 ${date.day}일',
              style: const TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmotionIcon("assets/images/emotion/happy.png"),
              _buildEmotionIcon("assets/images/emotion/depressed.png"),
              _buildEmotionIcon("assets/images/emotion/sad.png"),
              _buildEmotionIcon("assets/images/emotion/angry.png"),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmotionIcon(String asset) {
    return IconButton(
      icon: Image.asset(asset, width: 78),
      onPressed: () {
        Navigator.pop(context, asset);
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: PreferredSize(
      preferredSize: const Size.fromHeight(0),
      child: AppBar(
        backgroundColor: const Color(0xFF8DCCFF),
      ),
    ),
    bottomNavigationBar: _buildBottomAppBar(),
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const AddRoutinePage()));
      },
      backgroundColor: const Color(0xffB4DDFF),
      shape: const CircleBorder(),
      child: Image.asset('assets/images/add-button.png',
          width: 70, height: 70),
    ),
    body: Column(
      children: [
        _buildCalendarWeek(),
        Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFFF8F8EF),
          child: Center(
            child: GestureDetector(
              onTap: () {
                final DateTime selectedDateTime =
                DateFormat('yyyy.MM.dd').parse(selectedDate);
                _showBottomSheet(selectedDateTime);
              },
              child: Container(
                width: 360,
                height: 70,
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                decoration: BoxDecoration(
                  color: Colors.white, // White background
                  borderRadius:
                  BorderRadius.circular(12), // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey
                          .withOpacity(0.3), // Shadow color and opacity
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow position
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    userEmotion != null &&
                        getImageEmotion(userEmotion!) != null
                        ? Image.asset(
                      getImageEmotion(userEmotion!)!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    )
                        : Image.asset(
                        "assets/images/emotion/no-emotion.png",
                        width: 50,
                        height: 50),
                    const SizedBox(width: 10),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black), // Default text style
                          children: userEmotion != null &&
                              (userEmotion == 'GOOD' ||
                                  userEmotion == 'SAD' ||
                                  userEmotion == 'OK' ||
                                  userEmotion == 'ANGRY')
                              ? [
                            const TextSpan(text: '이 날은 기분이 '),
                            if (userEmotion == 'GOOD')
                              const TextSpan(
                                text: '해피',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .yellow), // Highlighted text style for GOOD
                              ),
                            if (userEmotion == 'SAD')
                              const TextSpan(
                                text: '우중충',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .blue), // Highlighted text style for SAD
                              ),
                            if (userEmotion == 'OK')
                              const TextSpan(
                                text: '쏘쏘',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .green), // Highlighted text style for OK
                              ),
                            if (userEmotion == 'ANGRY')
                              const TextSpan(
                                text: '나쁜',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .redAccent), // Highlighted text style for ANGRY
                              ),
                            TextSpan(
                                text: userEmotion == 'ANGRY'
                                    ? ' 날이에요'
                                    : '한 날이에요')
                          ]
                              : [
                            const TextSpan(
                              text: '오늘의 기분을 추가해보세요',
                              style: TextStyle(
                                  fontSize: 18,
                                  color:
                                  Colors.black), // Italicize text
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF8F8EF),
            child: FutureBuilder<RoutineResponse>(
              future: futureRoutineResponse,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                      child:
                      Text('루틴을 불러오는 중 오류가 발생했습니다: ${snapshot.error}'));
                } else if (!snapshot.hasData ||
                    (snapshot.data!.personalRoutines.isEmpty &&
                        snapshot.data!.groupRoutines.isEmpty)) {
                  // 개인 루틴과 그룹 루틴이 모두 비어있을 때 문구 표시
                  return const Center(
                    child: Column(
                      children: [
                        SizedBox(height: 100,),
                        Image(
                          image: AssetImage('assets/images/new-icons/ice.png'),
                          width: 150, // 원하는 크기로 설정
                          height: 150,
                        ),
                        Text(
                          ' 아래 + 버튼을 눌러 \n 새로운 루틴을 추가해보세요',
                          style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center, // 텍스트 중앙 정렬
                        ),
                      ],
                    ),
                  );

                }

                // 감정 상태를 업데이트
                userEmotion = snapshot.data!.userEmotion;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                  children: <Widget>[
                    // 개인 루틴이 있을 때만 표시
                    if (snapshot.data!.personalRoutines.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F5F8), // 배경색 설정
                          borderRadius:
                          BorderRadius.circular(12), // 둥근 모서리 설정
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            title: const Text("개인 루틴",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black)), // 텍스트 색상 변경
                            initiallyExpanded: true, // 초기상태를 펼친상태로 변경
                            children: snapshot.data!.personalRoutines
                                .map((category) {
                              return Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, top: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        borderRadius:
                                        BorderRadius.circular(20.0),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 1),
                                      child: Text(
                                        category.routineCategory,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: _getCategoryColor(
                                              category.routineCategory),
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 카테고리 밑에 루틴 추가
                                  ...category.routines.map((routine) {
                                    return _buildRoutineTile(
                                        routine); // 기존 _buildRoutineTile 메서드 사용
                                  }),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),

                    const SizedBox(height: 10),

                    // 그룹 루틴이 있을 때만 표시
                    if (snapshot.data!.groupRoutines.isNotEmpty)
                      ...snapshot.data!.groupRoutines.map((group) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            padding:
                            const EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F5F8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: ExpansionTile(
                                title: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start, // 시작 부분에 배치
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center, // 수직 중앙 정렬
                                  children: [
                                    Text(
                                      group.groupTitle,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: 8), // 제목과 아이콘 사이 간격
                                    if (group
                                        .isAlarmEnabled) // 알림이 활성화된 경우에만 벨 아이콘 표시
                                      Image.asset(
                                        'assets/images/bell.png', // bell.png 이미지 경로
                                        width: 20,
                                        height: 20,
                                      ),
                                  ],
                                ),
                                children: group.groupRoutines
                                    .map((categoryGroup) {
                                  return Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 10),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 255, 255, 255),
                                            borderRadius:
                                            BorderRadius.circular(20.0),
                                          ),
                                          padding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10.0,
                                              vertical: 1),
                                          child: Column(
                                            children: [
                                              Text(
                                                categoryGroup
                                                    .routineCategory, // 카테고리 이름
                                                style: TextStyle(
                                                  color: _getCategoryColor(
                                                      categoryGroup
                                                          .routineCategory),
                                                  fontWeight:
                                                  FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      ...categoryGroup.routines.map(
                                              (routine) => _buildRoutineTile2(
                                              routine)), // 루틴 목록
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        )
      ],
    ),
  );

  Color _getCategoryColor(String category) {
    switch (category) {
      case "건강":
        return const Color(0xff6ACBF3);
      case "자기개발":
        return const Color(0xff7BD7C6);
      case "일상":
        return const Color(0xffF5A77B);
      case "자기관리":
        return const Color(0xffC69FEC);
      default:
        return const Color(0xffF4A2D8);
    }
  }

//그룹 루틴
  Widget _buildRoutineTile2(GroupRoutine routine) {
    Color categoryColor = _getCategoryColor(routine.routineCategory);

    // 루틴 이름
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 여백 조절
        minLeadingWidth: 0,
        leading: const Icon(
          Icons.brightness_1,
          size: 8,
          color: Colors.black,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              routine.routineTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        trailing: Transform.scale(
          scale: 1.2, // Checkbox size increased by 1.5 times
          child: Checkbox(
            value: routine.isCompletion,
            onChanged: (bool? value) {
              if (value != null) {
                print("Checkbox changed: $value");
                setState(() {
                  routine.isCompletion = value;
                });
                updateRoutineCompletion(routine.routineId, value, selectedDate);
              }
            },
            activeColor: const Color(0xFF8DCCFF),
            checkColor: Colors.white,
            fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF8DCCFF);
                  }
                  return Colors.transparent;
                }),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAppBarItem("assets/images/tap-bar/routine02.png"),
          _buildBottomAppBarItem(
              "assets/images/tap-bar/group01.png", const GroupMainPage()),
          _buildBottomAppBarItem("assets/images/tap-bar/statistics01.png",
              const StaticsCalendar()),
          _buildBottomAppBarItem(
              "assets/images/tap-bar/more01.png", const MyInfo()),
        ],
      ),
    );
  }

  Widget _buildBottomAppBarItem(String asset, [Widget? page]) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.asset(asset),
      ),
    );
  }

  Widget _buildCalendarWeek() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1)
      ]),
      child: CalendarWeek(
        controller: _controller,
        height: 160,
        showMonth: true,
        minDate: DateTime.now().add(const Duration(days: -367)),
        maxDate: DateTime.now().add(const Duration(days: 365)),
        onDatePressed: (DateTime datetime) {
          _onDateSelected(datetime);
        },
        dayOfWeekStyle: const TextStyle(
            color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 17),
        dayOfWeek: const ['월', '화', '수', '목', '금', '토', '일'],
        dateStyle: const TextStyle(
            color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 17),
        todayDateStyle: const TextStyle(
            color: Color(0xffFFFFFF),
            fontWeight: FontWeight.w600,
            fontSize: 17),
        //todayBackgroundColor: Colors.blueAccent,
        weekendsStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 17, color: Colors.grey),
        monthViewBuilder: (DateTime time) => _buildMonthView(),
      ),
    );
  }

  Widget _buildMonthView() {
    return Align(
      alignment: const FractionalOffset(0.05, 1),
      child: Column(
        children: [
          Container(
            width: double.infinity, // 화면의 양끝까지 채우기
            color: const Color(0xFF8DCCFF), // 파란색 배경
            padding: const EdgeInsets.symmetric(vertical: 15), // 상하단 여백 추가
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월',
                  style: const TextStyle(
                    color: Colors.white, // 텍스트 색상
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRoutineTile(Routine routine) {
    Color categoryColor = _getCategoryColor(routine.routineCategory);

//개인루틴
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 여백 조절
        minLeadingWidth: 0,
        leading: const Icon(
          Icons.brightness_1,
          size: 8,
          color: Colors.black,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment:
          MainAxisAlignment.start, // Align elements to the start of the row
          children: [
            GestureDetector(
              onTap: () => _showDialog(context, routine),
              child: Text(routine.routineTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 5), // Adjust the width as needed
            if (routine.isAlarmEnabled) // Conditionally display the bell icon
              GestureDetector(
                onTap: () {
                  // Do nothing when the image is tapped3
                },
                child: Image.asset('assets/images/bell.png',
                    width: 20, height: 20),
              ),
          ],
        ),
        trailing: Transform.scale(
          scale: 1.2, // Checkbox size increased by 1.5 times
          child: Checkbox(
            value: routine.isCompletion,
            onChanged: (bool? value) {
              if (value != null) {
                print("Checkbox changed: $value");
                setState(() {
                  routine.isCompletion = value;
                });
                updateRoutineCompletion(routine.routineId, value, selectedDate);
              }
            },
            activeColor: const Color(0xFF8DCCFF),
            checkColor: Colors.white,
            fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF8DCCFF);
                  }
                  return Colors.transparent;
                }),
          ),
        ),
        onTap: () => _showDialog(context, routine),
      ),
    );
  }

  void _showDialog(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(routine.routineTitle), // Title과 함께 routineTitle 표시
          content: Text(routine.routineCategory), // Category 표시
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModifiedroutinePage(
                        routineId: routine.routineId,
                        routineTitle: routine.routineTitle,
                        routineCategory:
                        routine.routineCategory, // 이 부분도 연동
                        isAlarmEnabled: routine.isAlarmEnabled,
                        startDate: routine.startDate,
                        repeatDays: routine.repeatDays,
                      )),
                );
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/edit.png",
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '수정',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () async {
                // 다이얼로그를 먼저 닫음
                Navigator.of(context).pop();

                // 루틴 삭제
                await deleteRoutine(routine.routineId);

                // 상태 갱신
                setState(() {
                  futureRoutineResponse = fetchRoutines(selectedDate);
                });
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/delete.png",
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '삭제',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRoutineCompletion(
      int routineId, bool isCompletion, String date) async {
    final url = Uri.parse(
        "http://15.164.88.94/routines/$routineId/completion?date=$date");
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({"date": date, "isCompletion": isCompletion});

    try {
      final response = await http.put(url, headers: headers, body: body);
      if (response.statusCode == 204) {
        print("루틴 완료 상태 업데이트 성공 (응답 본문 없음)");
      } else if (response.statusCode == 200) {
        print("루틴 완료 상태 업데이트 성공");
      } else {
        print("루틴 완료 상태 업데이트 실패: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("루틴 완료 상태 업데이트 중 오류 발생: $e");
    }
  }

  Future<void> deleteRoutine(int routineId) async {
    final response = await http.delete(
      Uri.parse('http://15.164.88.94/routines/$routineId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete routine');
    }
  }
}

//루틴, 감정 조회
Future<RoutineResponse> fetchRoutines(String date) async {
  print('API 요청 날짜: $date'); // 요청할 날짜를 출력하여 확인

  final response = await http.get(
    Uri.parse('http://15.164.88.94/routines/v3?routineDate=$date'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final responseBody = json.decode(utf8.decode(response.bodyBytes));

    print('Parsed data: $responseBody'); // 데이터를 출력하여 확인
    return RoutineResponse.fromJson(responseBody);
  } else {
    throw Exception('Failed to load routines');
  }
}

//루틴 조회 및 수정
Future<void> _fetchRoutineDate(BuildContext context, int routineId) async {
  final url = Uri.parse("http://15.164.88.94/routines/$routineId");
  final headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $token"
  };

  try {
    final response = await http.get(url, headers: headers);
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Decoded date: $data");

      String routineTitle = data['routineTitle'];
      String routineCategory = data['routineCategory'] as String ?? '기타';
      bool isAlarmEnabled = data['isAlarmEnabled'];
      String startDate = data['startDate'];
      List<String> repeatDays = List<String>.from(data['repeatDays']);

      //수정 페이지 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ModifiedroutinePage(
            routineId: routineId,
            routineTitle: routineTitle,
            routineCategory: routineCategory,
            isAlarmEnabled: isAlarmEnabled,
            startDate: startDate,
            repeatDays: repeatDays,
          ),
        ),
      );
    } else {
      throw Exception("루틴이 없습니다.");
    }
  } catch (e) {
    print("에러");
  }
}

//기분 조회
String? getImageEmotion(String emotion) {
  switch (emotion) {
    case 'GOOD':
      return 'assets/images/emotion/happy.png';
    case 'OK':
      return 'assets/images/emotion/depressed.png';
    case 'SAD':
      return 'assets/images/emotion/sad.png';
    case 'ANGRY':
      return 'assets/images/emotion/angry.png';
    default:
      return "assets/images/emotion/no-emotion.png"; // 기본 이미지
  }
}

//기분 등록
String? getImageEmotion2(String emotion) {
  switch (emotion) {
    case 'assets/images/emotion/happy.png':
      return 'GOOD';
    case 'assets/images/emotion/depressed.png':
      return 'OK';
    case 'assets/images/emotion/sad.png':
      return 'SAD';
    case 'assets/images/emotion/angry.png':
      return 'ANGRY';
    default:
      return "assets/images/emotion/no-emotion.png"; // 기본 이미지
  }
}

//기분 텍스트
String getTextForEmotion(String emotion) {
  switch (emotion) {
    case 'GOOD':
      return '이 날은 기분이 해피한 날이에요';
    case 'OK':
      return '이 날은 기분이 쏘쏘한 날이에요';
    case 'SAD':
      return '이 날은 기분이 우중충한 날이에요';
    case 'ANGRY':
      return '이 날은 기분이 나쁜 날이에요';
  // case 'null':
  //   return '기분을 추가해보세요!';
    default:
      return '기분을 추가해보세요!'; // 기본 텍스트
  }
}

//루틴, 감정 조회 class
class RoutineResponse {
  final List<UserRoutineCategory> personalRoutines;
  final List<Group2> groupRoutines;
  final String userEmotion;
  final List<UserRoutineCategory> routines;
  // final List<String> groupRoutineCategories;

  RoutineResponse({
    required this.personalRoutines,
    required this.groupRoutines,
    required this.userEmotion,
    required this.routines,
    // required this.groupRoutineCategories,
  });

  factory RoutineResponse.fromJson(Map<String, dynamic> json) {
    return RoutineResponse(
      personalRoutines: (json['personalRoutines'] as List<dynamic>?)
          ?.map((item) =>
          UserRoutineCategory.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      groupRoutines: (json['groupRoutines'] as List<dynamic>?)
          ?.map((item) => Group2.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      userEmotion: json['userEmotion'] ?? 'null',
      routines: (json['routines'] as List<dynamic>?)
          ?.map((item) =>
          UserRoutineCategory.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// 개인 루틴
class Routine {
  final int routineId;
  final String routineTitle;
  final String routineCategory;
  bool isAlarmEnabled; // isAlarmEnabled를 mutable로 변경
  final String startDate;
  final List<String> repeatDays;
  bool isCompletion;

  Routine(
      {required this.routineId,
        required this.routineTitle,
        required this.routineCategory,
        required this.isAlarmEnabled,
        required this.startDate,
        required this.repeatDays,
        this.isCompletion = false});

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      routineId: json['routineId'] ?? 0, //기본값 설정
      routineTitle: json['routineTitle'] ?? '', // 한국어로 된 필드명을 사용하여 데이터를 파싱
      routineCategory: json['routineCategory'] ?? '기타',
      isAlarmEnabled: json['isAlarmEnabled'] ?? false,
      startDate:
      json["startDate"] ?? DateFormat('yyyy.MM.dd').format(DateTime.now()),
      repeatDays: List<String>.from(json["repeatDays"] ?? []),
      isCompletion: json['isCompletion'] ?? false,
    );
  }
}

// 개인 카테고리 그룹
class UserRoutineCategory {
  final String routineCategory;
  final List<Routine> routines;

  UserRoutineCategory({
    required this.routineCategory,
    required this.routines,
  });

  factory UserRoutineCategory.fromJson(Map<String, dynamic> json) {
    return UserRoutineCategory(
      routineCategory: json['routineCategory'] ?? '',
      routines: (json['routines'] as List)
          .map((item) => Routine.fromJson(item))
          .toList() ??
          [],
    );
  }
}

//그룹 루틴
class GroupRoutine {
  final int routineId;
  final String routineTitle;
  final String routineCategory;
  bool isCompletion;

  GroupRoutine({
    required this.routineId,
    required this.routineTitle,
    required this.routineCategory,
    this.isCompletion = false,
  });

  factory GroupRoutine.fromJson(Map<String, dynamic> json) {
    return GroupRoutine(
      routineId: json['routineId'] ?? 0,
      routineTitle: json['routineTitle'] ?? '',
      routineCategory: json['routineCategory'] ?? '',
      isCompletion: json['isCompletion'] ?? false,
    );
  }
}

// 루틴 카테고리 그룹
class RoutineCategoryGroup {
  final String routineCategory;
  final List<GroupRoutine> routines;

  RoutineCategoryGroup({
    required this.routineCategory,
    required this.routines,
  });

  factory RoutineCategoryGroup.fromJson(Map<String, dynamic> json) {
    return RoutineCategoryGroup(
      routineCategory: json['routineCategory'] ?? '',
      routines: (json['routines'] as List)
          .map((item) => GroupRoutine.fromJson(item))
          .toList(),
    );
  }
}

// 그룹
class Group2 {
  final int groupId;
  final String groupTitle;
  bool isAlarmEnabled;
  final List<RoutineCategoryGroup> groupRoutines;

  Group2({
    required this.groupId,
    required this.groupTitle,
    this.isAlarmEnabled = false,
    required this.groupRoutines,
  });

  factory Group2.fromJson(Map<String, dynamic> json) {
    return Group2(
      groupId: json['groupId'] ?? 0,
      groupTitle: json['groupTitle'] ?? '',
      isAlarmEnabled: json['isAlarmEnabled'] ?? false,
      groupRoutines: (json['groupRoutines'] as List)
          .map((item) => RoutineCategoryGroup.fromJson(item))
          .toList(),
    );
  }
}