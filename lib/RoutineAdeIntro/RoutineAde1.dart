import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'WebViewPage.dart';
import 'package:routine_ade/routine_user/token.dart';

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
//webview에서 같이 파이어베이스 토큰을 받도록 수정.

class RoutineAde1 extends StatefulWidget {
  const RoutineAde1({super.key});

  @override
  _RoutineAde1State createState() => _RoutineAde1State();
}

class _RoutineAde1State extends State<RoutineAde1> {
  String? _firebaseToken;
  @override
  void initState() {
    super.initState();
    _getFirebaseToken(); // 앱 실행 시 FCM 토큰을 가져옴
  }

  // Firebase 토큰을 가져오는 메서드
  Future<void> _getFirebaseToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? firebaseToken = await messaging.getToken(); // Firebase 토큰 가져오기
    setState(() {
      _firebaseToken = firebaseToken;
    });
    print('FCM Token: $_firebaseToken');
  }

  // 서버로 Firebase 토큰을 보내는 메서드
  Future<void> _sendTokenToServer(String userId, String firebaseToken) async {
    const String apiUrl = '';

    try {
      final response = await http.post(
        Uri.parse('$apiUrl/$userId/token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 인증 토큰
        },
        body: jsonEncode({
          'token': firebaseToken,
        }),
      );

      if (response.statusCode == 200) {
        print('토큰이 성공적으로 서버에 전송되었습니다.');
      } else {
        print('서버 응답 에러: ${response.statusCode}');
      }
    } catch (e) {
      print('토큰 전송 실패: $e');
    }
  }

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
