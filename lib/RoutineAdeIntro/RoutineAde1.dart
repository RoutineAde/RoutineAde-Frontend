import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'WebViewPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    "assets/images/new-icons/onBoarding2.png",
    "assets/images/new-icons/onBoarding3.png",
    "assets/images/new-icons/onBoarding4.png",
    "assets/images/new-icons/onBoarding1.png",
  ];

  int _currentIndex = 0;
  String? _fcmToken; // FCM 토큰 변수

  @override
  void initState() {
    super.initState();
    _getToken(); // FCM 토큰 가져오기
  }

  // FCM 토큰을 가져오는 함수
  void _getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    setState(() {
      _fcmToken = token;
    });

    print("FCM Token: $_fcmToken");
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
            const SizedBox(height: 100),
            CarouselSlider(
              options: CarouselOptions(
                height: 300,
                enlargeCenterPage: true,
                viewportFraction: 0.8,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                enableInfiniteScroll: false,
              ),
              items: imgList
                  .map((item) => Center(
                child: Image.asset(
                  item,
                  fit: BoxFit.contain,
                  width: 1000,
                ),
              ))
                  .toList(),
            ),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => setState(() {
                    _currentIndex = entry.key;
                  }),
                  child: Container(
                    width: 12.0,
                    height: 12.0,
                    margin: const EdgeInsets.symmetric(
                        vertical: 10.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key
                          ? Colors.grey
                          : Colors.grey[300],
                    ),
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            const Text(
              "sns로 간편 가입하기 !",
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 100,
                child: GestureDetector(
                  onTap: () {
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
            const SizedBox(height: 50),
            if (_fcmToken != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'FCM Token: $_fcmToken',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
