// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:uni_links/uni_links.dart'; // uni_links 패키지 임포트
// import 'dart:async'; // 비동기 처리를 위한 임포트
// import 'package:shared_preferences/shared_preferences.dart'; // shared_preferences 임포트
// import 'package:routine_ade/routine_user/token.dart';

// class RoutineAde1 extends StatefulWidget {
//   const RoutineAde1({super.key});

//   @override
//   _RoutineAde1State createState() => _RoutineAde1State();
// }

// class _RoutineAde1State extends State<RoutineAde1> {
//   StreamSubscription? _sub;

//   @override
//   void initState() {
//     super.initState();
//     _sub = linkStream.listen((String? link) {
//       if (link != null) {
//         // URL에서 토큰 추출
//         _handleIncomingLink(link);
//       }
//     });
//   }

//   Future<void> _handleIncomingLink(String link) async {
//     // URL에서 토큰 추출
//     Uri uri = Uri.parse(link);
//     String? token = uri.queryParameters['token'];
//     if (token != null) {
//       await TokenManager.saveToken(token); // TokenManager를 사용하여 토큰 저장
//       print('토큰 저장 완료: $token');
//     }
//   }

//   Future<void> _launchURL() async {
//     const url =
//         'https://kauth.kakao.com/oauth/authorize?response_type=code&client_id=25a0f887ecba2fdb77884c01ca0325b0&redirect_uri=http://15.164.88.94:8080/users/login/kakao';
//     if (await canLaunch(url)) {
//       await launch(url);
//     } else {
//       throw 'Could not launch $url';
//     }
//   }

//   @override
//   void dispose() {
//     _sub?.cancel(); // 스트림 구독 해제
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const Spacer(),
//             Image.asset(
//               'assets/images/new-icons/RoutineAde.png',
//               width: 100,
//               height: 100,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               '더 나은 하루, 루틴 에이드',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               '루틴으로 더 나은 일상을\n함께 관리해보세요!',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[700],
//               ),
//             ),
//             const Spacer(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 150,
//                 child: GestureDetector(
//                   onTap: () async {
//                     await _launchURL();
//                   },
//                   child: Image.asset(
//                     "assets/images/new-icons/kakaoTalk.png",
//                     width: 200,
//                     height: 200,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
