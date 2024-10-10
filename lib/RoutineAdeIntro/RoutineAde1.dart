import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'WebViewPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoutineAde1(),
    );
  }
}

class RoutineAde1 extends StatefulWidget {
  const RoutineAde1({super.key});

  @override
  _RoutineAde1State createState() => _RoutineAde1State();
}

class _RoutineAde1State extends State<RoutineAde1> {
  final List<String> imgList = [
    "assets/images/tap-bar/routine02.png",
    "assets/images/tap-bar/group02.png",
    "assets/images/tap-bar/statistics02.png",
    "assets/images/tap-bar/more02.png",
  ];

  int _currentIndex = 0; // 현재 선택된 이미지 인덱스

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            // Image.asset(
            //   'assets/images/new-icons/RoutineAde.png',
            //   width: 100,
            //   height: 100,
            // ),
            // const SizedBox(height: 20),
            // const Text(
            //   '더 나은 하루, 루틴 에이드',
            //   style: TextStyle(
            //     fontSize: 18,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.black,
            //   ),
            // ),
            // const SizedBox(height: 8),
            // Text(
            //   '루틴으로 더 나은 일상을\n함께 관리해보세요!',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 14,
            //     color: Colors.grey[700],
            //   ),
            // ),
            const SizedBox(height: 50),

            // Carousel Slider 부분
            CarouselSlider(
              options: CarouselOptions(
                height: 300, // 슬라이더 높이
                enlargeCenterPage: true, // 가운데 이미지 크게 보이기
                viewportFraction: 0.8, // 슬라이드 간격 조절
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index; // 슬라이드가 바뀔 때 현재 인덱스 업데이트
                  });
                },
              ),
              items: imgList
                  .map((item) => Container(
                        child: Center(
                          child: Image.asset(
                            item,
                            fit: BoxFit.contain,
                            width: 1000,
                          ),
                        ),
                      ))
                  .toList(),
            ),

            const SizedBox(
              height: 50,
            ),

            // 인디케이터 부분
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _currentIndex = entry.key; // 해당 인디케이터 클릭 시 슬라이드 변경
                  }),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.blueAccent // 현재 인덱스일 경우 채워진 동그라미
                          : Colors.grey, // 그렇지 않은 경우 빈 동그라미
                    ),
                  ),
                );
              }).toList(),
            ),

            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: SizedBox(
                width: double.infinity,
                height: 150,
                child: GestureDetector(
                  onTap: () {
                    // WebView 페이지로 이동
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const WebViewPage()),
                    );
                  },
                  child: Image.asset(
                    "assets/images/new-icons/kakaoTalk.png",
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
