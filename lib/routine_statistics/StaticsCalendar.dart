import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routine_group/GroupMainPage.dart';
import '../routine_home/MyRoutinePage.dart';
import 'StaticsCategory.dart';

class StaticsCalendar extends StatefulWidget {
  @override
  _StaticsCalendarState createState() => _StaticsCalendarState();
}

class _StaticsCalendarState extends State<StaticsCalendar> with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late TabController _tabController;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '통계',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8DCCFF),
        automaticallyImplyLeading: false,
        // 뒤로가기 제거
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "캘린더"),
                  Tab(text: "카테고리"),
                ],
                labelStyle: const TextStyle(fontSize: 18),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Color(0xFF8DCCFF)),
                  insets: EdgeInsets.symmetric(horizontal: 115.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCalendarTab(),
          StaticsCategory(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyRoutinePage()),
                );
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset("assets/images/tap-bar/routine01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GroupMainPage()),
                );
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset("assets/images/tap-bar/group01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 통계 버튼 클릭 시 동작할 코드
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset("assets/images/tap-bar/statistics02.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 더보기 버튼 클릭 시 동작할 코드
              },
              child: SizedBox(
                width: 60,
                height: 60,
                child: Image.asset("assets/images/tap-bar/more01.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarTab() {
    final totalCompletedRoutines = _calculateTotalCompletedRoutines(_focusedDay);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCalendarHeader(), // 캘린더 헤더
          SizedBox(height: 20),
          Row(
            children: [
              SizedBox(width: 10),
              Text(
                '이번 달 완료 루틴',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 180,),
              Text(
                '$totalCompletedRoutines개',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8DCCFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 30),
          Row(
            children: [
              SizedBox(width: 10),
              Text(
                '이번 달 달성률',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildCalendar(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
              });
            },
          ),
          Text(
            '${_focusedDay.year}년 ${_focusedDay.month}월',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 30, 10, 5),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return false;
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  return _buildDayCell(date);
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(),
                todayTextStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                ),
                selectedDecoration: BoxDecoration(),
                defaultTextStyle: TextStyle(
                  fontSize: 16.0,
                ),
                weekendTextStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                outsideTextStyle: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (date, locale) {
                  const days = ['월', '화', '수', '목', '금', '토', '일'];
                  return days[date.weekday - 1];
                },
                weekdayStyle: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                weekendStyle: TextStyle(
                  fontSize: 14.0,
                  color: Colors.black,
                ),
              ),
              headerVisible: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(180, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Less"),
                SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 5.0,
                  backgroundColor: Colors.white,
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 5.0,
                  backgroundColor: Color(0xFF8DCCFF),
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 5.0,
                  backgroundColor: Colors.lightBlue,
                ),
                SizedBox(width: 8.0),
                CircleAvatar(
                  radius: 5.0,
                  backgroundColor: Colors.blue,
                ),
                SizedBox(width: 8.0),
                Text("More"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date) {
    Color circleColor;

    int completionRate = getCompletionRate(date);

    if (completionRate == 0) {
      circleColor = Colors.transparent;
    } else if (completionRate == 1) {
      circleColor = Colors.white;
    } else if (completionRate == 2) {
      circleColor = Color(0xFF8DCCFF);
    } else if (completionRate == 3) {
      circleColor = Colors.lightBlue;
    } else {
      circleColor = Colors.blue;
    }

    Color textColor = circleColor == Colors.white ? Colors.black : Colors.white;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
        ),
        width: 40.0,
        height: 40.0,
        child: Center(
          child: Text(
            date.day.toString(),
            style: TextStyle(
              color: circleColor == Colors.transparent ? Colors.black : textColor,
            ),
          ),
        ),
      ),
    );
  }

  int getCompletionRate(DateTime date) {
    // Example logic to determine completion rate, replace with your actual logic
    return (date.day % 4) + 1; // Example logic: you should replace it with actual logic
  }

  int _calculateTotalCompletedRoutines(DateTime focusedDay) {
    int totalRoutines = 0;

    for (int day = 1; day <= DateTime(focusedDay.year, focusedDay.month + 1, 0).day; day++) {
      totalRoutines += getCompletionRate(DateTime(focusedDay.year, focusedDay.month, day));
    }

    return totalRoutines;
  }
}
