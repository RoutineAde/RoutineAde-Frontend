import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_group/OnClickGroupPage.dart';
import 'package:routine_ade/routine_groupLeader/glOnClickGroupPage.dart';
import 'dart:convert';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupType.dart';
import 'package:routine_ade/routine_group/AddGroupPage.dart';
import 'package:routine_ade/routine_user/token.dart';

//전체화면 어둡게
class DarkOverlay extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback onTap;

  const DarkOverlay(
      {super.key,
        required this.child,
        required this.isDark,
        required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (isDark)
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap, // 클릭 방지용 빈 함수
              child: Container(
                color: Colors.black.withOpacity(0.5), // 어두운 배경색, 투명도 조절 가능
              ),
            ),
          ),
      ],
    );
  }
}

class GroupMainPage extends StatefulWidget {
  const GroupMainPage({super.key});

  @override
  _GroupMainPageState createState() => _GroupMainPageState();
}

class _GroupMainPageState extends State<GroupMainPage> {
  bool isExpanded = false;
  List<Group> groups = [];

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  //가입일자 계산
  int calculateDaysSinceCreation(int joinDate) {
    final now = DateTime.now();
    final joinDateTime = DateTime.fromMicrosecondsSinceEpoch(joinDate);
    return now.difference(joinDateTime).inDays + 1;
  }

  //내그룹 조회
  Future<void> _fetchGroups() async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/my');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes); // UTF-8 디코딩
      final data = jsonDecode(decodedResponse); // 디코딩된 문자열을 JSON으로 파싱
      setState(() {
        groups = (data['groups'] as List)
            .map((json) => Group.fromJson(json))
            .toList();

        // Sort groups by joinDate in ascending order
        groups.sort((a, b) =>
            DateTime.fromMicrosecondsSinceEpoch(a.joinDate ?? 0).compareTo(
                DateTime.fromMicrosecondsSinceEpoch(b.joinDate ?? 0)));
      });
    } else {
      print("그룹 불러오기를 실패하였습니다.");
    }
  }

  Future<bool> fetchIsGroupAdmin(int groupId) async {
    final url = Uri.parse("http://15.164.88.94:8080/groups/$groupId");
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);

      if (data is Map<String, dynamic> && data.containsKey('isGroupAdmin')) {
        return data['isGroupAdmin'] as bool;
      } else {
        return false;
      }
    } else {
      print("Error fetching group admin status: ${response.statusCode}");
      return false;
    }
  }

  Future<void> navigateToGroupPage(int groupId) async {
    final isAdmin = await fetchIsGroupAdmin(groupId);

    if (isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => glOnClickGroupPage(groupId: groupId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => OnClickGroupPage(groupId: groupId),
        ),
      );
    }
  }

  // 카테고리 색상 설정 함수
  Color getCategoryColor(String category) {
    switch (category) {
      case "건강":
        return const Color(0xff6ACBF3);
      case "자기개발":
        return const Color(0xff7BD7C6);
      case "일상":
        return const Color(0xffF5A77B);
      case "자기관리":
        return const Color(0xffC69FEC);
      default:
        return const Color(0xffF4A2D8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '내 그룹',
          style: TextStyle(
              color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor:
        isExpanded ? Colors.grey[600] : const Color(0xFF8DCCFF),
        automaticallyImplyLeading: false, // 뒤로가기 제거
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              "assets/images/bell.png",
              width: 35,
              height: 35,
            ),
          ),
        ],
      ),
      body: DarkOverlay(
        isDark: isExpanded, // 눌렀을때만 어둡게
        onTap: () {
          setState(() {
            isExpanded = false;
          });
        },
        child: Container(
          color: const Color(0xFFF8F8EF),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    Color categoryColor = getCategoryColor(group.groupCategory);

                    return InkWell(
                      onTap: () {
                        navigateToGroupPage(group.groupId);
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        color: const Color(0xFFE6F5F8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        group.groupTitle,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (!group.isPublic)
                                        Padding(
                                          padding:
                                          const EdgeInsets.only(left: 8.0),
                                          child: Image.asset(
                                            "assets/images/lock.png",
                                            width: 20,
                                            height: 20,
                                          ), // 비밀번호 방 여부
                                        ),
                                    ],
                                  ),
                                  Text("가입 ${group.joinDate}일차"),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("대표 카테고리 "),
                                  Text(group.groupCategory,
                                      style: TextStyle(color: categoryColor)),
                                  Expanded(child: Container()), // 간격 조절
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                        "인원 ${group.joinMemberCount}/${group.maxMemberCount}명"),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("루틴장 ${group.createdUserNickname}"),
                                  Text("그룹코드 ${group.groupId}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // 바텀 네비게이션 바
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyRoutinePage()),
                );
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/routine01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 그룹 버튼 클릭 시 동작할 코드
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/group02.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 통계 버튼 클릭 시 동작할 코드
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/statistics01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 더보기 버튼 클릭 시 동작할 코드
              },
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/more01.png"),
              ),
            ),
          ],
        ),
      ),

      // add 버튼
      // add 버튼
      floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isExpanded) ...[
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("루틴 그룹",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      // 그룹 추가 버튼
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const GroupRoutinePage(); // 그룹 루틴 페이지 이동 바꿔야함
                            },
                          ));
                        },
                        backgroundColor: const Color(0xfff87c3ff),
                        shape: const CircleBorder(),
                        child: Image.asset('assets/images/group-list.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text("그룹 추가",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      // 그룹 루틴 추가 버튼
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return const AddGroupPage();
                            },
                          ));
                        },
                        backgroundColor: const Color(0xffF1E977),
                        shape: const CircleBorder(),
                        child: Image.asset('assets/images/add.png'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
                // add 버튼, X버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(""),
                    const SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      backgroundColor: isExpanded
                          ? const Color(0xfff7c7c7c)
                          : const Color(0xffF1E977),
                      shape: const CircleBorder(),
                      child: isExpanded
                          ? Image.asset('assets/images/cancel.png')
                          : Image.asset('assets/images/add.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}