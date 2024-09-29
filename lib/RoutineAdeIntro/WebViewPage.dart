import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';  // WebView 패키지 import

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
    // 최신 버전에서는 Platform-specific 설정이 필요하지 않음
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kakao Login WebView'),
      ),
      body: WebView(
        initialUrl:
        'https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=25a0f887ecba2fdb77884c01ca0325b0&redirect_uri=https://15.164.88.94/users/login/kakao',
        javascriptMode: JavascriptMode.unrestricted,  // Javascript 활성화
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageFinished: (String url) {
          // 페이지 로딩이 끝나면 URL을 확인
          if (url.contains('token=')) {
            Uri uri = Uri.parse(url);
            String? token = uri.queryParameters['token'];
            if (token != null) {
              print('OAuth 토큰: $token');
              // 추출한 토큰으로 로그인 처리 로직 추가
              // 예: 서버에 토큰을 보내 인증 처리
            }
          }
        },
      ),
    );
  }
}
