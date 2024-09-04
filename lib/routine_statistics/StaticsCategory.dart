import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StaticsCategory extends StatefulWidget {
  @override
  _StaticsCategoryState createState() => _StaticsCategoryState();
}

class _StaticsCategoryState extends State<StaticsCategory> {
  // 카테고리별 개수 선언 (예시 데이터를 위한 초기값)
  int dailyCount = 5;
  int healthCount = 5;
  int selfDevelopmentCount = 3;
  int selfCareCount = 5;
  int othersCount = 2;

  DateTime _focusedDay = DateTime.now();  // 포커스된 날짜
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _updateCategoryCounts(); // 초기 카운트 업데이트
  }

  void _updateCategoryCounts() {
    // 예시 로직: 날짜에 따라 카테고리별 완료 루틴 수 업데이트
    dailyCount = getCompletionRate(_focusedDay) * 2;
    healthCount = getCompletionRate(_focusedDay) * 3;
    selfDevelopmentCount = getCompletionRate(_focusedDay);
    selfCareCount = getCompletionRate(_focusedDay) * 2;
    othersCount = getCompletionRate(_focusedDay) * 1;
    setState(() {});
  }

  int getCompletionRate(DateTime date) {
    // 날짜별 완료율을 계산하는 예시 로직 (실제 로직으로 대체 필요)
    return (date.day % 4) + 1;
  }

  @override
  Widget build(BuildContext context) {
    // 모든 카테고리의 합산값 계산
    int totalCount = dailyCount + healthCount + selfDevelopmentCount + selfCareCount + othersCount;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCalendarHeader(),  // 캘린더 헤더 추가
            SizedBox(height: 20),
            _buildPieChart(totalCount),
            SizedBox(height: 20),
            _buildCategoryList('일상', dailyCount, Color(0xffFDA598)!),
            _buildCategoryList('건강', healthCount, Color(0xff80CAFF)!),
            _buildCategoryList('자기개발', selfDevelopmentCount, Color(0xff85E0A3)!),
            _buildCategoryList('자기관리', selfCareCount, Color(0xffFFDE7A)!),
            _buildCategoryList('기타', othersCount, Color(0xffFFB2E5)!),
          ],
        ),
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
                _updateCategoryCounts();  // 월 변경 시 카운트 업데이트
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
                _updateCategoryCounts();  // 월 변경 시 카운트 업데이트
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(int totalCount) {
    return Container(
      height: 150,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Color(0xffFDA598),
                  value: dailyCount.toDouble(),
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  color: Color(0xff80CAFF),
                  value: healthCount.toDouble(),
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  color: Color(0xff85E0A3),
                  value: selfDevelopmentCount.toDouble(),
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  color: Color(0xffFFDE7A),
                  value: selfCareCount.toDouble(),
                  title: '',
                  radius: 30,
                ),
                PieChartSectionData(
                  color: Color(0xffFFB2E5),
                  value: othersCount.toDouble(),
                  title: '',
                  radius: 30,
                ),
              ],
              centerSpaceRadius: 55,
              sectionsSpace: 0,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '이번 달 완료 루틴',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  '$totalCount개',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String category, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 8,
            backgroundColor: color,
          ),
          title: Text(category),
          trailing: Text('$count 개', style: TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
