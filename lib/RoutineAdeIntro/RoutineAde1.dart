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
            Image.asset(
              'assets/images/new-icons/RoutineAde.png',
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              '더 나은 하루, 루틴 에이드',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '루틴으로 더 나은 일상을\n함께 관리해보세요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
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
                      MaterialPageRoute(builder: (context) => const WebViewPage()),
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
