import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:routine_ade/routine_groupLeader/glOnClickGroupPage.dart';
import 'AddRoutinePage.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_group/OnClickGroupPage.dart';
import 'package:routine_ade/routine_home/AlarmListPage.dart';
import 'package:routine_ade/routine_home/ModifiedRoutinePage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  String? _userEmotion;

  bool _isTileExpanded = false;

  late TabController _tabController;
  bool _isExpanded = false;
  String? _selectedImage;

  //루틴완료체크여부
  //Map<int, bool> isCheckedMap = {};

  @override
  void initState() {
    super.initState();
    _controller = CalendarWeekController();
    futureRoutineResponse = fetchRoutines(selectedDate);
    _tabController = TabController(length: 4, vsync: this);
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
        _userEmotion = response.userEmotion;
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

//기분등록
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
    final url = Uri.parse("http://15.164.88.94:8080/users/emotion");
    final headers = {
      "Content-Type": "application/json",
      "Authorization":
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw"
    };

    final body = jsonEncode({
      "date": formattedDate,
      "userEmotion": _getImageEmotion2(selectedImage),
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("감정 등록 성공");
        // 감정을 등록한 후 해당 날짜의 데이터를 가져옴
        setState(() {
          futureRoutineResponse = fetchRoutines(selectedDate);
        });
      } else {
        print("감정 등록 실패: ${response.statusCode}- ${response.body}");
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
            // child: Text(
            //   '${_controller.selectedDate.year ?? DateTime.now().year}년 ${_controller.selectedDate.month?? DateTime.now().month}월 ${_controller.selectedDate.day?? DateTime.now().day}일',
            //   style: TextStyle(fontSize: 20),
            child: Text(
              '${date.year}년 ${date.month}월 ${date.day}일',
              style: const TextStyle(fontSize: 20),
            ),
          ),
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
        floatingActionButton: _buildFloatingActionButton(),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: AppBar(
            backgroundColor: const Color(0xFF8DCCFF),
          ),
        ),
        bottomNavigationBar: _buildBottomAppBar(),
        body: Column(
          children: [
            _buildCalendarWeek(),
            if (_userEmotion != null && _userEmotion!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFF8F8EF),
                child: Center(
                  child: Container(
                    width: 360,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white, // 하얀색 배경
                      borderRadius: BorderRadius.circular(12), // 둥근 모서리
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3), // 그림자 색상과 투명도
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3), // 그림자의 위치
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        if (_getImageEmotion(_userEmotion!) != null)
                          Image.asset(
                            _getImageEmotion(_userEmotion!)!,
                            fit: BoxFit.cover,
                            width: 50,
                            height: 50,
                          ),
                        const SizedBox(width: 10),
                        Text(
                          _getTextForEmotion(_userEmotion!), // 감정에 따른 텍스트 표시
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
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
                        snapshot.data!.personalRoutines.isEmpty) {
                      return const Center(
                          child: Text(
                        '\n\t\t\t\t\t\t\t\t 아래 + 버튼을 눌러 \n 새로운 루틴을 추가해보세요',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ));
                    }
                    _userEmotion = snapshot.data!.userEmotion; // 감정 상태를 업데이트

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 16),
                      children: <Widget>[
                        const SizedBox(
                          height: 10,
                        ), // 여백 추가
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
                              initiallyExpanded: _isTileExpanded,
                              children: snapshot.data!.personalRoutines
                                  .map((routine) => _buildRoutineTile(routine))
                                  .toList(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // 여백 추가
                      ],
                    );
                  },
                ),
              ),
            ),

          ],
        ),
      );

  Widget _buildFloatingActionButton() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded) ...[
                _buildFABRow("기분 추가", () {
                  final DateTime selectedDateTime =
                      DateFormat('yyyy.MM.dd').parse(selectedDate);
                  _showBottomSheet(selectedDateTime);
                }, 'assets/images/add-emotion.png'),
                const SizedBox(height: 20),
                _buildFABRow("루틴 추가", () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AddRoutinePage()));
                }, 'assets/images/add.png'),
                const SizedBox(height: 20),
              ],
              _buildMainFAB(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFABRow(String text, VoidCallback onPressed, String asset) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(text,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: const Color(0xffF1E977),
          shape: const CircleBorder(),
          child: Image.asset(asset),
        ),
      ],
    );
  }

  Widget _buildMainFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(""),
        const SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _toggleExpand,
          backgroundColor:
              _isExpanded ? const Color(0xfff7c7c7c) : const Color(0xffF1E977),
          shape: const CircleBorder(),
          child: Image.asset(_isExpanded
              ? 'assets/images/cancel.png'
              : 'assets/images/add.png'),
        ),
      ],
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
              "assets/images/tap-bar/group01.png", GroupMainPage()),
          _buildBottomAppBarItem("assets/images/tap-bar/statistics01.png",
              const OnClickGroupPage(groupId: 1)),
          _buildBottomAppBarItem("assets/images/tap-bar/more01.png",
              const glOnClickGroupPage(groupId: 1)),
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
        width: 50,
        height: 50,
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
            padding: const EdgeInsets.symmetric(vertical: 8), // 상하단 여백 추가
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
                const Spacer(),
                IconButton(
                  icon: Image.asset("assets/images/bell.png",
                      width: 30, height: 30),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AlarmListPage()),
                    );
                  },
                ),
                const SizedBox(width: 20), // 오른쪽 여백 추가
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildRoutineTile(Routine routine) {
    Color categoryColor;

    // 카테고리 색상
    switch (routine.routineCategory) {
      case "건강":
        categoryColor = const Color(0xff6ACBF3);
        break;
      case "자기개발":
        categoryColor = const Color(0xff7BD7C6);
        break;
      case "일상":
        categoryColor = const Color(0xffF5A77B);
        break;
      case "자기관리":
        categoryColor = const Color(0xffC69FEC);
        break;
      default:
        categoryColor = const Color(0xffF4A2D8);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 3,
          ),
          // 카테고리 텍스트
          Container(
            padding: const EdgeInsets.only(left: 10), // 왼쪽에 10의 간격 추가
            child: Text(
              ' ${routine.routineCategory}',
              style: TextStyle(
                  color: categoryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
            ),
          ),
          // 루틴 이름
          ListTile(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment
                  .start, // Align elements to the start of the row
              children: [
                GestureDetector(
                  onTap: () => _showDialog(context, routine),
                  child: Text(routine.routineTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 3), // Adjust the width as needed
                if (routine
                    .isAlarmEnabled) // Conditionally display the bell icon
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
              scale: 1.5, // Checkbox size increased by 1.5 times
              child: Checkbox(
                value: routine.isCompletion,
                onChanged: (bool? value) {
                  if (value != null) {
                    print("Checkbox changed: $value");
                    setState(() {
                      routine.isCompletion = value;
                    });
                    updateRoutineCompletion(
                        routine.routineId, value, selectedDate);
                  }
                },
                activeColor: const Color(
                    0xFF8DCCFF), // Color when the checkbox is checked
                checkColor:
                    Colors.white, // The check mark color inside the checkbox
                fillColor: WidgetStateProperty.resolveWith<Color>(
                    (Set<WidgetState> states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(
                        0xFF8DCCFF); // Checkbox fill color when checked
                  }
                  return Colors
                      .transparent; // Checkbox fill color when unchecked
                }),
              ),
            ),
            */
            onTap: () => _showDialog(context, routine),
          ),
        ],
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
          title: Text(routine.routineTitle),
          content: Text(routine.routineCategory ?? '기타'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ModifiedroutinePage(
                            routineId: routine.routineId,
                            routineTitle: routine.routineTitle,
                            routineCategory: routine.routineCategory,
                            isAlarmEnabled: routine.isAlarmEnabled,
                            startDate: routine.startDate,
                            repeatDays: routine.repeatDays,
                          )),
                );
              },
              child: const Text('수정'),
            ),
            ElevatedButton(
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
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateRoutineCompletion(
      int routineId, bool isCompletion, String date) async {
    final url = Uri.parse(
        "http://15.164.88.94:8080/routines/$routineId/completion?date=$date");
    final headers = {
      "Content-Type": "application/json",
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw',
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
      Uri.parse('http://15.164.88.94:8080/routines/$routineId'),
      headers: {
        'Authorization':
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw',
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
    Uri.parse('http://15.164.88.94:8080/routines/v2?routineDate=$date'),
    headers: {
      'Authorization':
          'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw', // 여기에 올바른 인증 토큰을 넣으세요
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
  final url = Uri.parse("http://15.164.88.94:8080/routines/$routineId");
  final headers = {
    "Content-Type": "application/json",
    "Authorization":
        "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw"
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
String? _getImageEmotion(String emotion) {
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
      return null; // 기본 이미지
  }
}

//기분 등록
String? _getImageEmotion2(String emotion) {
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
      return null; // 기본 이미지
  }
}

//기분 텍스트
String _getTextForEmotion(String emotion) {
  switch (emotion) {
    case 'GOOD':
      return '기분굿';
    case 'OK':
      return '기분쏘쏘';
    case 'SAD':
      return '슬퍼요';
    case 'ANGRY':
      return '화나요';
    default:
      return '알 수 없음'; // 기본 텍스트
  }
}
//루틴, 감정 조회 class
class RoutineResponse {
  final List<Routine> personalRoutines;
  final String userEmotion;

  RoutineResponse({required this.personalRoutines, required this.userEmotion});

  factory RoutineResponse.fromJson(Map<String, dynamic> json) {
    return RoutineResponse(
      personalRoutines: (json['personalRoutines'] as List)
          .map((item) => Routine.fromJson(item))
          .toList(),
      userEmotion: json['userEmotion'] ?? 'OK',
    );
  }
}

class Routine {
  final int routineId;
  final String routineTitle;
  final String? routineCategory;
  final bool isAlarmEnabled; // isAlarmEnabled를 mutable로 변경
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
