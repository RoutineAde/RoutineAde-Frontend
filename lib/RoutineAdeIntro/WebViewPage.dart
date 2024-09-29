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
        'https://accounts.kakao.com/login/?continue=https%3A%2F%2Fkauth.kakao.com%2Foauth%2Fauthorize%3Fresponse_type%3Dcode%26client_id%3D25a0f887ecba2fdb77884c01ca0325b0%26redirect_uri%3Dhttps%253A%252F%252F15.164.88.94%252Fusers%252Flogin%252Fkakao%26through_account%3Dtrue#login',
        javascriptMode: JavascriptMode.unrestricted,  // Javascript 활성화
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
        },
        onPageFinished: (String url) {
          // 페이지 로딩이 끝나면 인증 코드를 추출하는 로직
          if (url.contains('code=')) {
            Uri uri = Uri.parse(url);
            String? code = uri.queryParameters['code'];
            if (code != null) {
              print('OAuth 인증 코드: $code');
              // 인증 코드로 필요한 작업을 추가 수행
            }
          }
        },
      ),
    );
  }
}
