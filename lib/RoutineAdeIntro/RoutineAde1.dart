import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:routine_ade/RoutineAdeIntro/ProfileSetting.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

void main() async {
  await initializeDateFormatting();
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
  String? token;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _initUniLinks();
  }

  Future<void> _initUniLinks() async {
    // 초기 링크 수신
    try {
      final initialLink = await getInitialLink();
      _extractToken(initialLink);
    } catch (e) {
      print("초기 링크 오류: $e");
    }

    // 링크 스트림 수신
    _sub = linkStream.listen((String? link) {
      _extractToken(link);
    }, onError: (err) {
      print("링크 스트림 오류: $err");
    });
  }

  void _extractToken(String? link) {
    if (link != null) {
      Uri uri = Uri.parse(link);
      String? code = uri.queryParameters['code'];
      if (code != null) {
        setState(() {
          token = code; // 토큰 저장
        });
        print('추출된 토큰: $token');
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel(); // 구독 해제
    super.dispose();
  }

  Future<void> _launchURL() async {
    const url =
        'https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=25a0f887ecba2fdb77884c01ca0325b0&redirect_uri=http://15.164.88.94/users/login/kakao';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
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
                  onTap: () async {
                    await _launchURL(); // 카카오 로그인 페이지로 이동
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