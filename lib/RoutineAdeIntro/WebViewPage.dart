import 'package:flutter/material.dart';
import 'package:routine_ade/RoutineAdeIntro/ProfileSetting.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../routine_user/token.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;
  String? _firebaseToken;

  @override
  void initState() {
    super.initState();
    // 웹뷰 초기화 전에 SharedPreferences에서 토큰을 불러옴.
    _loadToken();
    _getFirebaseToken(); // 앱 실행 시 FCM 토큰을 가져옴
  }

  // 토큰을 불러와서 출력
  Future<void> _loadToken() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      print('저장된 토큰: $token');
    } else {
      print('토큰이 없습니다.');
    }
  }

  // Firebase 토큰 가져오는 메서드
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
    final String apiUrl = 'http://15.164.88.94/users/$userId/token';
    String? token = await TokenManager.getToken(); // OAuth 토큰을 가져옴

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // OAuth 토큰을 추가
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
      appBar: AppBar(
        title: const Text('Kakao Login WebView'),
      ),
      body: WebView(
        initialUrl:
            'https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=25a0f887ecba2fdb77884c01ca0325b0&redirect_uri=http://15.164.88.94/users/login/kakao',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageFinished: (String url) async {
          // 페이지 로딩이 끝나면 URL을 확인
          if (url.contains('token=')) {
            final tokenStartIndex =
                url.indexOf('token=') + 6; // 'token='의 시작 위치
            final token = url.substring(tokenStartIndex);

            // URL이 정상적으로 응답하지 않을 때 예외 처리
            if (token.isNotEmpty) {
              print('OAuth 토큰: $token'); // 콘솔에 토큰 출력

              // 추출한 토큰을 SharedPreferences에 저장
              await TokenManager.saveToken(token);
              print('토큰 저장 완료');
            } else {
              print('토큰이 유효하지 않습니다.');
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfileSetting()),
            );
          }
        },
      ),
    );
  }
}
