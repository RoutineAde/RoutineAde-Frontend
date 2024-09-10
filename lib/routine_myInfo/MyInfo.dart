import 'dart:convert';  // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:routine_ade/routine_myInfo/ProfileChange.dart';
import '../routine_group/GroupMainPage.dart';
import '../routine_statistics/StaticsCalendar.dart';
import '../routine_user/token.dart';

class MyInfo extends StatefulWidget {
  @override
  _MyInfoState createState() => _MyInfoState();
}

class _MyInfoState extends State<MyInfo> {
  Profile? profile; // Profile 데이터 저장

  @override
  void initState() {
    super.initState();
    fetchProfile(); // 페이지 로드 시 프로필 데이터 가져오기
  }

  // 프로필 데이터 API로부터 가져오기
  Future<void> fetchProfile() async {
    final headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token', // token은 token.dart 파일에서 가져오는 것으로 가정
    };

    try {
      final response = await http.get(
        Uri.parse('http://15.164.88.94:8080/users/profile'),
        headers: headers, // 헤더 추가
      );

      // UTF-8로 응답 디코딩
      var responseBody = utf8.decode(response.bodyBytes);
      var data = json.decode(responseBody); // JSON 디코딩

      print('Response body: $responseBody'); // 응답 확인용 출력

      if (response.statusCode == 200) {
        // 성공적으로 데이터를 가져왔을 때
        setState(() {
          profile = Profile.fromJson(data); // 이미 디코딩된 데이터를 사용
        });
      } else {
        // 실패할 경우 처리 (에러 메시지 표시 등)
        setState(() {
          print('Failed to load profile: ${response.statusCode}');
          throw Exception('Failed to load profile');
        });
      }
    } catch (e) {
      // 네트워크 오류 처리
      print('Exception occurred: $e');
      setState(() {
        throw Exception('Failed to load profile');
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Color(0xFF8DCCFF),
        centerTitle: true,
        title: Text(
          '내 정보',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false, // 뒤로가기 제거
        actions: <Widget>[
          IconButton(
            icon: Stack(
              children: [
                IconButton(
                  icon: Image.asset("assets/images/settings-cog.png"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileChange()),
                    );
                  },
                ),
              ],
            ),
            onPressed: () {
              // Handle settings button press
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: profile == null
            ? CircularProgressIndicator() // 데이터가 없으면 로딩 표시
            : Column(
          children: <Widget>[
            SizedBox(height: 70),
            // Profile Image
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                profile!.profileImage, // API에서 가져온 이미지 URL 사용
              ),
            ),
            const SizedBox(height: 80),

            // Nickname Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  title: const Text('닉네임'),
                  trailing: Text(profile!.nickname, style: TextStyle(fontSize: 16),), // API에서 가져온 닉네임 사용
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Introduction Box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListTile(
                  title: const Text('한 줄 소개'),
                  trailing: Text(profile!.intro, style: TextStyle(fontSize: 16),), // API에서 가져온 한 줄 소개 사용
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomAppBar(context),
    );
  }

  // Bottom AppBar widget
  Widget _buildBottomAppBar(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAppBarItem(context, "assets/images/tap-bar/routine01.png", MyRoutinePage()),
          _buildBottomAppBarItem(context, "assets/images/tap-bar/group01.png", const GroupMainPage()),
          _buildBottomAppBarItem(context, "assets/images/tap-bar/statistics01.png", StaticsCalendar()),
          _buildBottomAppBarItem(context, "assets/images/tap-bar/more02.png", MyInfo()), // Current page
        ],
      ),
    );
  }

  // Helper function to create a Bottom App Bar Item
  Widget _buildBottomAppBarItem(BuildContext context, String asset, [Widget? page]) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.asset(asset),
      ),
    );
  }
}

// Profile 클래스 정의
class Profile {
  int userId;
  String profileImage;
  String nickname;
  String intro;

  Profile({
    required this.userId,
    required this.profileImage,
    required this.nickname,
    required this.intro,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['userId'] as int,
      profileImage: json['profileImage'] as String,
      nickname: json['nickname'] as String,
      intro: json['intro'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'profileImage': profileImage,
      'nickname': nickname,
      'intro': intro,
    };
  }
}
