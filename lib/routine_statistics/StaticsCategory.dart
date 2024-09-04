import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../routine_group/GroupMainPage.dart';
import '../routine_home/MyRoutinePage.dart';

class StaticsCategory extends StatefulWidget {
  @override
  _StaticsCategoryState createState() => _StaticsCategoryState();
}

class _StaticsCategoryState extends State<StaticsCategory> {
  // 카테고리별 개수 선언
  final int dailyCount = 5;
  final int healthCount = 5;
  final int selfDevelopmentCount = 3;
  final int selfCareCount = 5;
  final int othersCount = 2;

  @override
  Widget build(BuildContext context) {
    // 모든 카테고리의 합산값 계산
    int totalCount = dailyCount + healthCount + selfDevelopmentCount + selfCareCount + othersCount;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                  radius: 30, // 섹션의 반지름을 줄여 두께를 얇게
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
              centerSpaceRadius: 55,  // 중심 여백을 늘려 파이 두께를 얇게
              sectionsSpace: 0,
            ),
          ),
          Center(  // 파이 차트 가운데에 텍스트를 배치
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '이번 달 완료 루틴',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  '$totalCount개',  // 합산된 값을 출력
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
