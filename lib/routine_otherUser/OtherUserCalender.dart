import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:table_calendar/table_calendar.dart';
import '../routine_myInfo/MyInfo.dart';
import '../routine_group/GroupMainPage.dart';
import '../routine_home/MyRoutinePage.dart';
import '../routine_user/token.dart';

class Otherusercalender extends StatefulWidget {
  final int userId;
  const Otherusercalender({super.key, required this.userId});

  @override
  _OtherusercalenderState createState() => _OtherusercalenderState();
}

class _OtherusercalenderState extends State<Otherusercalender>
    with SingleTickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  RoutineStatistics? routineStatistics; // API에서 불러온 데이터 저장 변수

  @override
  void initState() {
    super.initState();

    _fetchRoutineStatistics(); // 통계 데이터 가져오기
  }

  // API 호출 함수
  Future<void> _fetchRoutineStatistics() async {
    final String url =
        'http://15.164.88.94/users/${widget.userId}/statistics/calender?date=${_focusedDay.year}.${_focusedDay.month.toString().padLeft(2, '0')}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // 인증 토큰 헤더 추가
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          routineStatistics = RoutineStatistics.fromJson(data);
        });
      } else {
        print('Failed to load routine statistics: ${response.statusCode}');
        throw Exception(
            'Failed to load routine statistics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching routine statistics: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   // backgroundColor: const Color(0xFF8DCCFF),
      //   automaticallyImplyLeading: false, // 뒤로가기 제거
      // ),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final totalCompletedRoutines =
        routineStatistics?.completedRoutinesCount ?? 0;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 20),
          Row(
            children: [
              const SizedBox(width: 10),
              const Text(
                '이번 달 완료 루틴',
                style: TextStyle(fontSize: 18),
              ),
              const Spacer(),
              Text(
                '${routineStatistics?.completedRoutinesCount ?? 0}개', // null 체크 추가
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8DCCFF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          const Row(
            children: [
              SizedBox(width: 10),
              Text(
                '이번 달 달성률',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                _fetchRoutineStatistics(); // 월을 변경할 때 데이터 갱신
              });
            },
          ),
          Text(
            '${_focusedDay.year}년 ${_focusedDay.month}월',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                _fetchRoutineStatistics(); // 월을 변경할 때 데이터 갱신
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      width: 360, //달력비율
      height: 400, //달력비율
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
                  _fetchRoutineStatistics(); // 페이지 변경 시 데이터 갱신
                });
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  final dayInfo = routineStatistics
                      ?.userRoutineCompletionStatistics.routineCompletionInfos
                      .firstWhere((element) => element.day == date.day,
                      orElse: () =>
                          RoutineCompletionInfo(day: 0, level: 0));

                  return _buildDayCell(date, dayInfo?.level ?? 0);
                },
              ),
              calendarStyle: const CalendarStyle(
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
                weekdayStyle: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                weekendStyle: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
              headerVisible: false,
              daysOfWeekHeight: 30.0,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(180, 5, 10, 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Less"),
                const SizedBox(width: 8.0),
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.grey, width: 1.0), // 테두리 추가
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: const Color(0xffCAF4FF),
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.grey, width: 1.0), // 테두리 추가
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: const Color(0xffA0DEFF),
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.grey, width: 1.0), // 테두리 추가
                  ),
                ),
                const SizedBox(width: 8.0),
                Container(
                  width: 10.0,
                  height: 10.0,
                  decoration: BoxDecoration(
                    color: const Color(0xff5AB2FF),
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.grey, width: 1.0), // 테두리 추가
                  ),
                ),
                const SizedBox(width: 8.0),
                const Text("More"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime date, int level) {
    final colorMap = {
      0: Colors.white, // 완료 안 됨
      1: const Color(0xffCAF4FF),
      2: const Color(0xffA0DEFF),
      3: const Color(0xff5AB2FF),
    };
    return Container(
      decoration: BoxDecoration(
        color: colorMap[level] ?? Colors.white,
        shape: BoxShape.circle,
        // border: Border.all(
        //   color: Colors.grey,
        //   width: 1.0,
        // ),
      ),
      margin: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(
          date.day.toString(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16.0,
          ),
        ),
      ),
    );
  }
}

// RoutineStatistics 데이터 모델
class RoutineStatistics {
  final int completedRoutinesCount;
  final UserRoutineCompletionStatistics userRoutineCompletionStatistics;

  RoutineStatistics(
      {required this.completedRoutinesCount,
        required this.userRoutineCompletionStatistics});

  factory RoutineStatistics.fromJson(Map<String, dynamic> json) {
    return RoutineStatistics(
      completedRoutinesCount: json['completedRoutinesCount'],
      userRoutineCompletionStatistics: UserRoutineCompletionStatistics.fromJson(
          json['userRoutineCompletionStatistics']),
    );
  }
}

class UserRoutineCompletionStatistics {
  final List<RoutineCompletionInfo> routineCompletionInfos;

  UserRoutineCompletionStatistics({required this.routineCompletionInfos});

  factory UserRoutineCompletionStatistics.fromJson(Map<String, dynamic> json) {
    var list = json['routineCompletionInfos'] as List;
    List<RoutineCompletionInfo> completionInfoList = list
        .map((completionInfo) => RoutineCompletionInfo.fromJson(completionInfo))
        .toList();
    return UserRoutineCompletionStatistics(
        routineCompletionInfos: completionInfoList);
  }
}

class RoutineCompletionInfo {
  final int day;
  final int level;

  RoutineCompletionInfo({required this.day, required this.level});

  factory RoutineCompletionInfo.fromJson(Map<String, dynamic> json) {
    return RoutineCompletionInfo(
      day: json['day'],
      level: json['level'],
    );
  }
}