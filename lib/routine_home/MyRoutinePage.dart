import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/date_symbol_data_local.dart';
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

class _MyRoutinePageState extends State<MyRoutinePage> with SingleTickerProviderStateMixin {
  Future<List<Routine>>? futureRoutines; // late 키워드를 사용하여 초기화를 나중에 하도록 설정
  String selectedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
  late CalendarWeekController _controller;

  bool _isTileExpanded = false;

  late TabController _tabController;
  bool _isExpanded = false;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller = CalendarWeekController();
    futureRoutines = fetchRoutines(selectedDate);

    _tabController = TabController(length: 4, vsync: this);
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      selectedDate = DateFormat('yyyy.MM.dd').format(date);
      futureRoutines = fetchRoutines(selectedDate);
      _isTileExpanded = true; // 날짜를 선택할 때마다 ExpansionTile이 펼쳐지도록 설정
    });
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

  void _showBottomSheet() async {
    final String? selectedImage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheetContent();
      },
    );

    if (selectedImage != null) {
      setState(() {
        _selectedImage = selectedImage;
      });
    }
  }

  Widget _buildBottomSheetContent() {
    return Container(
      height: 250,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월 ${_controller.selectedDate.day}일',
              style: TextStyle(fontSize: 20),
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
          SizedBox(height: 20),
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
      child: AppBar(),
      preferredSize: Size.fromHeight(0),
    ),
    bottomNavigationBar: _buildBottomAppBar(),
    body: Column(
      children: [
        _buildCalendarWeek(),
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: FutureBuilder<List<Routine>>(
              future: futureRoutines,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load routines'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No routines available'));
                }

                return ListView(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
                  children: <Widget>[
                    SizedBox(height: 10,), // 여백 추가
                    Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        title: Text("개인 루틴", style: TextStyle(fontSize: 20)),
                        initiallyExpanded: _isTileExpanded,
                        children: snapshot.data!.map((routine) => _buildRoutineTile(routine)).toList(),
                      ),
                    ),
                    SizedBox(height: 10,), // 여백 추가
                  ],
                );
              },
            ),
          ),
        ),
        if(_selectedImage != null)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child: Column(
              children: [
                Text("오늘의 기분", style: TextStyle(fontSize: 18)),
                SizedBox(height: 10,),
                Image.asset(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: 70,
                  height: 70,
                ),
              ],
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
                _buildFABRow("기분 추가", _showBottomSheet, 'assets/images/add-emotion.png'),
                SizedBox(height: 20),
                _buildFABRow("루틴 추가", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRoutinePage()));
                }, 'assets/images/add.png'),
                SizedBox(height: 20),
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
        Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        SizedBox(width: 10),
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Color(0xffF1E977),
          child: Image.asset(asset),
          shape: CircleBorder(),
        ),
      ],
    );
  }

  Widget _buildMainFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(""),
        SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _toggleExpand,
          backgroundColor: _isExpanded ? Color(0xffF7C7C7C) : Color(0xffF1E977),
          child: Image.asset(_isExpanded ? 'assets/images/cancel.png' : 'assets/images/add.png'),
          shape: CircleBorder(),
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
          _buildBottomAppBarItem("assets/images/tap-bar/group01.png", GroupMainPage()),
          _buildBottomAppBarItem("assets/images/tap-bar/statistics01.png", OnClickGroupPage()),
          _buildBottomAppBarItem("assets/images/tap-bar/more01.png", ChatScreen()),
        ],
      ),
    );
  }

  Widget _buildBottomAppBarItem(String asset, [Widget? page]) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: Container(
        width: 50,
        height: 50,
        child: Image.asset(asset),
      ),
    );
  }

  Widget _buildCalendarWeek() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)
      ]),
      child: CalendarWeek(
        controller: _controller,
        height: 130,
        showMonth: true,
        minDate: DateTime.now().add(Duration(days: -367)),
        maxDate: DateTime.now().add(Duration(days: 365)),
        onDatePressed: (DateTime datetime) {
          _onDateSelected(datetime);
        },
        dayOfWeekStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17),
        dayOfWeek: ['월', '화', '수', '목', '금', '토', '일'],
        dateStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17),
        todayDateStyle: TextStyle(color: Color(0xffFFFFFF), fontWeight: FontWeight.w600, fontSize: 17),
        todayBackgroundColor: Color(0xffE6E288),
        weekendsStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red),
        monthViewBuilder: (DateTime time) => _buildMonthView(),
      ),
    );
  }

  Widget _buildMonthView() {
    return Align(
      alignment: FractionalOffset(0.05, 1),
      child: Row(
        children: [
          SizedBox(width: 20),
          Text(
            '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월',
            style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Spacer(),
          IconButton(
            icon: Image.asset("assets/images/bell.png", width: 30, height: 30),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AlarmListPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineTile(Routine routine) {
    Color categoryColor;

    // 카테고리 색상
    switch (routine.routineCategory) {
      case "건강":
        categoryColor = Color(0xff6ACBF3);
        break;
      case "자기 개발":
        categoryColor = Color(0xff7BD7C6);
        break;
      case "일상":
        categoryColor = Color(0xffF5A77B);
        break;
      case "자기 관리":
        categoryColor = Color(0xffC69FEC);
        break;
      default:
        categoryColor = Color(0xffF4A2D8);
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          // 카테고리 텍스트
          Container(
            padding: EdgeInsets.only(left: 10), // 왼쪽에 10의 간격 추가
            child: Text(
              ' ${routine.routineCategory}',
              style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          // 루틴 이름
          ListTile(
            title: Text('${routine.routineTitle}', style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Checkbox(
              value: routine.isAlarmEnabled,
              onChanged: (bool? value) {
                setState(() {
                  routine.isAlarmEnabled = value!;
                });
              },
            ),
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
          content: Text(routine.routineCategory),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifiedRoutinePage()),
                );
              },
              child: Text('수정'),
            ),
            ElevatedButton(
              onPressed: () async {
                await deleteRoutine(routine.routineId);
                setState(() {
                  futureRoutines = fetchRoutines(selectedDate); // Refresh the routines
                });
                Navigator.of(context).pop();
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteRoutine(int routineId) async {
    final response = await http.delete(
      Uri.parse('http://15.164.88.94:8080/routines/$routineId'),
      headers: {
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw', // 여기에 올바른 인증 토큰을 넣으세요
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete routine');
    }
  }
}

Future<List<Routine>> fetchRoutines(String date) async {
  print('Date used for API request: $date'); // 요청할 날짜를 출력하여 확인

  final response = await http.get(
    Uri.parse('http://15.164.88.94:8080/routines?routineDate=$date'),
    headers: {
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw', // 여기에 올바른 인증 토큰을 넣으세요
    },
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    Map<String, dynamic> responseBody = json.decode(utf8.decode(response.bodyBytes)); // UTF-8 디코딩
    List<dynamic> routines = responseBody['routines'];
    print('Parsed data: $routines'); // 데이터를 출력하여 확인
    return routines.map((item) => Routine.fromJson(item)).toList();
  } else {
    print('Failed to load routines: ${response.statusCode}');
    print('Response body: ${response.body}');
    throw Exception('Failed to load routines');
  }
}

class Routine {
  final int routineId;
  final String routineTitle;
  final String routineCategory;
  bool isAlarmEnabled; // isAlarmEnabled를 mutable로 변경

  Routine({required this.routineId, required this.routineTitle, required this.routineCategory, required this.isAlarmEnabled});

  factory Routine.fromJson(Map<String, dynamic> json) {
    return Routine(
      routineId: json['routineId'],
      routineTitle: json['routineTitle'], // 한국어로 된 필드명을 사용하여 데이터를 파싱
      routineCategory: json['routineCategory'],
      isAlarmEnabled: json['isAlarmEnabled'],
    );
  }
}
