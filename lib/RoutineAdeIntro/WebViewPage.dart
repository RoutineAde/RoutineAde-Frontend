import 'package:flutter/material.dart';
import 'package:routine_ade/RoutineAdeIntro/ProfileSetting.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../routine_user/token.dart';

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
    // 웹뷰 초기화 전에 SharedPreferences에서 토큰을 불러옴.
    _loadToken();
  }

  // 토큰을 불러와서 출력 (필요시 다른 처리)
  Future<void> _loadToken() async {
    String? token = await TokenManager.getToken();
    if (token != null) {
      print('저장된 토큰: $token');
    } else {
      print('토큰이 없습니다.');
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
