import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routine_group/GroupMainPage.dart';
import '../routine_home/MyRoutinePage.dart';

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
          // StaticsCategory(),
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
                // 그룹 버튼 클릭 시 동작할 코드
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCalendarHeader(), // Calendar header moved here
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
                '20개',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8DCCFF),
                ),
              ),
            ],
          ),
          SizedBox(height: 40),
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
          color: Colors.grey,  // Set the color of the border
          width: 2.0,  // Set the width of the border
        ),
        borderRadius: BorderRadius.circular(10.0), // Optional: Add rounded corners
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 40, 10, 60),  // Add padding between calendar and border
        child: TableCalendar(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarFormat: _calendarFormat,
          onFormatChanged: (format) {
            setState(() {
              _calendarFormat = format;
            });
          },
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            defaultTextStyle: TextStyle(
              fontSize: 16.0, // Increase the font size of day numbers
            ),
            weekendTextStyle: TextStyle(
              fontSize: 16.0, // Increase the font size of weekend numbers
              color: Colors.black, // Optional: Change weekend color if needed
            ),
            outsideTextStyle: TextStyle(
              fontSize: 16.0, // Increase the font size of outside month day numbers
              color: Colors.grey, // Optional: Set a color for outside month days
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            dowTextFormatter: (date, locale) {
              const days = ['월', '화', '수', '목', '금', '토', '일'];
              return days[date.weekday - 1];
            },
            weekdayStyle: TextStyle(
              fontSize: 14.0, // Increase the font size of weekday labels (Mon-Fri)
              color: Colors.black,
            ),
            weekendStyle: TextStyle(
              fontSize: 14.0, // Increase the font size of weekend labels (Sat-Sun)
              color: Colors.black,
            ),
          ),
          headerVisible: false, // Keep the custom header outside of the calendar
        ),
      ),
    );
  }
}