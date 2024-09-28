import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:routine_ade/routine_myInfo/ProfileChange.dart';
import '../routine_group/GroupMainPage.dart';
import '../routine_statistics/StaticsCalendar.dart';
import '../routine_user/token.dart';

class MyInfo extends StatefulWidget {
  const MyInfo({super.key});

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
        Uri.parse('http://15.164.88.94/users/infos'),
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
        backgroundColor: const Color(0xFF8DCCFF),
        centerTitle: true,
        title: const Text(
          '내 정보',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        // 뒤로가기 제거
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: profile == null
            ? const CircularProgressIndicator() // 데이터가 없으면 로딩 표시
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: <Widget>[
            const SizedBox(height: 40),
            // Profile Information Row
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Image
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 20, 0, 10),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      profile!.profileImage, // API에서 가져온 이미지 URL 사용
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Nickname and Introduction Column
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          profile!.nickname,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        //SizedBox(width: 0),
                        // Edit Button
                        IconButton(
                          icon: Image.asset(
                            "assets/images/settings-cog.png",
                            width: 24, // 아이콘의 크기를 조정
                            height: 24,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                const ProfileChange(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      profile!.intro,
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 루틴 & 그룹 Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                '루틴 & 그룹',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // 루틴 & 그룹 Section에서 Row에 Expanded 추가
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 15),
              margin: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildInfoColumn(
                        '개인 루틴', profile!.personalRoutineCount),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                        '그룹 루틴', profile!.groupRoutineCount),
                  ),
                  Expanded(
                    child: _buildInfoColumn('그룹', profile!.groupCount),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 계정 Section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                '계정',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, vertical: 10.0),
              child: TextButton(
                onPressed: () {
                  // Implement logout functionality
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '로그아웃',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, vertical: 0.0),
              child: TextButton(
                onPressed: () {
                  // Implement delete account functionality
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '탈퇴하기',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Text(
                '앱 정보',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 30.0, vertical: 10.0),
              child: TextButton(
                onPressed: () {
                  // Implement contact us functionality
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '문의하기',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ],
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
          _buildBottomAppBarItem(context, "assets/images/tap-bar/routine01.png",
              const MyRoutinePage()),
          _buildBottomAppBarItem(context, "assets/images/tap-bar/group01.png",
              const GroupMainPage()),
          _buildBottomAppBarItem(
              context,
              "assets/images/tap-bar/statistics01.png",
              const StaticsCalendar()),
          _buildBottomAppBarItem(
              context, "assets/images/tap-bar/more02.png", const MyInfo()),
          // Current page
        ],
      ),
    );
  }

  // Helper function to create a Bottom App Bar Item
  Widget _buildBottomAppBarItem(BuildContext context, String asset,
      [Widget? page]) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        }
      },
      child: SizedBox(
        height: 60,
        width: 60,
        child: Image.asset(asset),
      ),
    );
  }

  // Helper function to build columns for 루틴 & 그룹 info
  Widget _buildInfoColumn(String label, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
      crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
      children: [
        Text(
          value.toString(), // int 값을 toString()으로 변환하여 표시
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Profile 클래스 정의
class Profile {
  String profileImage;
  String nickname;
  String intro;
  int personalRoutineCount;
  int groupRoutineCount;
  int groupCount;

  Profile({
    required this.profileImage,
    required this.nickname,
    required this.intro,
    required this.personalRoutineCount,
    required this.groupRoutineCount,
    required this.groupCount,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      profileImage: json['profileImage'] as String,
      nickname: json['nickname'] as String,
      intro: json['intro'] as String,
      personalRoutineCount: json['personalRoutineCount'] as int,
      groupRoutineCount: json['groupRoutineCount'] as int,
      groupCount: json['groupCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileImage': profileImage,
      'nickname': nickname,
      'intro': intro,
      'personalRoutineCount': personalRoutineCount,
      'groupRoutineCount': groupRoutineCount,
      'groupCount': groupCount,
    };
  }
}