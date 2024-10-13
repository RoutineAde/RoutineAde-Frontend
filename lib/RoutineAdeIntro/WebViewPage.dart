import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/RoutineAdeIntro/ProfileSetting.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../routine_user/token.dart';
import 'dart:convert';

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  // 토큰을 불러오는 메서드
  Future<void> _loadToken() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      print('저장된 토큰: $token');
    } else {
      print('토큰이 없습니다.');
    }
  }

  // 최초 로그인 여부를 확인하는 메서드
  Future<void> _checkIfFirstLogin(String token) async {
    final response = await http.get(
      Uri.parse('http://15.164.88.94/users/isFirst'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      bool isFirst = responseBody['isFirst'] ?? false;

      // 최초 로그인 여부에 따라 페이지 이동
      if (isFirst) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
              const ProfileSetting()), // ProfileSetting 페이지로 이동
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MyRoutinePage()),
        );
      }
    } else {
      print('최초 로그인 확인 실패: ${response.statusCode}');
      // 오류 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('Kakao Login WebView'),
      ),
      body: WebView(
        initialUrl:
        'https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=25a0f887ecba2fdb77884c01ca0325b0&redirect_uri=http://15.164.88.94/users/login/kakao',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageFinished: (String url) async {
          if (url.contains('token=')) {
            final tokenStartIndex =
                url.indexOf('token=') + 6; // 'token='의 시작 위치
            final token = url.substring(tokenStartIndex);

            if (token.isNotEmpty) {
              print('OAuth 토큰: $token'); // 콘솔에 토큰 출력

              // 추출한 토큰으로 최초 로그인 확인
              await _checkIfFirstLogin(token);
            } else {
              print('토큰이 유효하지 않습니다.');
            }
          }
        },
      ),
    );
  }
}