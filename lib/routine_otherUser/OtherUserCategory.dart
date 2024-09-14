import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../routine_user/token.dart';

class Otherusercategory extends StatefulWidget {
  final int userId;
  const Otherusercategory({super.key, required this.userId});

  @override
  _OtherusercategoryState createState() => _OtherusercategoryState();
}

class _OtherusercategoryState extends State<Otherusercategory> {
  int completedRoutinesCount = 0;
  List<RoutineCategoryStatistics> routineCategoryStatistics = [];

  DateTime _focusedDay = DateTime.now(); // 포커스된 날짜

  @override
  void initState() {
    super.initState();
    _fetchCategoryStatistics(); // 초기 데이터 로드
  }

  Future<void> _fetchCategoryStatistics() async {
    String url =
        'http://15.164.88.94:8080/users/${widget.userId}/statistics?date=${_focusedDay.year}.${_focusedDay.month.toString().padLeft(2, '0')}';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // 인증 토큰 헤더 추가
          'Content-Type': 'application/json',
        },
      );

      var responseBody = utf8.decode(response.bodyBytes);
      var data = json.decode(responseBody);

      print('Response body: $responseBody'); // 응답 확인용 출력

      if (response.statusCode == 200) {
        if (data != null && data is Map<String, dynamic>) {
          var statistics = CategoryStatistics.fromJson(data);
          setState(() {
            completedRoutinesCount = statistics.completedRoutinesCount;
            routineCategoryStatistics = statistics.routineCategoryStatistics;
          });
          print(
              "Data loaded successfully: ${routineCategoryStatistics.length} categories");
        } else {
          print('Received null or invalid data');
          setState(() {
            routineCategoryStatistics = [];
          });
        }
      } else {
        print('Failed to load statistics. Status code: ${response.statusCode}');
        setState(() {
          routineCategoryStatistics = [];
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        routineCategoryStatistics = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCalendarHeader(),
            const SizedBox(height: 20),
            _buildPieChart(),
            const SizedBox(height: 20),
            routineCategoryStatistics.isNotEmpty
                ? Column(
              children: routineCategoryStatistics
                  .map((stat) => _buildCategoryList(
                  stat.category,
                  stat.completedCount,
                  _getCategoryColor(stat.category)))
                  .toList(),
            )
                : const Center(
              child: Text(
                '완료한 카테고리가 없습니다.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
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
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                _fetchCategoryStatistics(); // 월 변경 시 데이터 업데이트
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
                _fetchCategoryStatistics(); // 월 변경 시 데이터 업데이트
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sections: routineCategoryStatistics.isNotEmpty
                  ? routineCategoryStatistics.map((stat) {
                return PieChartSectionData(
                  color: _getCategoryColor(stat.category),
                  value: stat.completedCount.toDouble(),
                  title: '',
                  radius: 30,
                );
              }).toList()
                  : [
                PieChartSectionData(
                  color: Colors.grey,
                  radius: 30,
                )
              ],
              centerSpaceRadius: 55,
              sectionsSpace: 0,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '이번 달 완료 루틴',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                Text(
                  '$completedRoutinesCount개',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(String category, int completedCount, Color color) {
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
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 8,
            backgroundColor: color,
          ),
          title: Text(category),
          trailing:
          Text('$completedCount 개', style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '일상':
        return const Color(0xffFDA598);
      case '건강':
        return const Color(0xff80CAFF);
      case '자기개발':
        return const Color(0xff85E0A3);
      case '자기관리':
        return const Color(0xffFFDE7A);
      case '기타':
        return const Color(0xffFFB2E5);
      default:
        return Colors.grey;
    }
  }
}

class CategoryStatistics {
  final int completedRoutinesCount;
  final List<RoutineCategoryStatistics> routineCategoryStatistics;

  CategoryStatistics({
    required this.completedRoutinesCount,
    required this.routineCategoryStatistics,
  });

  factory CategoryStatistics.fromJson(Map<String, dynamic> json) {
    var list = json['routineCategoryStatistics'] as List? ?? [];
    List<RoutineCategoryStatistics> categoryStatisticsList =
    list.map((stat) => RoutineCategoryStatistics.fromJson(stat)).toList();
    return CategoryStatistics(
      completedRoutinesCount: json['completedRoutinesCount'] ?? 0,
      routineCategoryStatistics: categoryStatisticsList,
    );
  }
}

class RoutineCategoryStatistics {
  final String category;
  final int completedCount;

  RoutineCategoryStatistics({
    required this.category,
    required this.completedCount,
  });

  factory RoutineCategoryStatistics.fromJson(Map<String, dynamic> json) {
    return RoutineCategoryStatistics(
      category: json['category'] ?? 'Unknown',
      completedCount: json['completedCount'] ?? 0,
    );
  }
}