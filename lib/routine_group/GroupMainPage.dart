import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupType.dart';
import 'package:routine_ade/routine_group/AddGroupPage.dart';

//전체화면 어둡게
class DarkOverlay extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback onTap;

  DarkOverlay({required this.child, required this.isDark, required this.onTap});

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

  Future<void> _fetchGroups() async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/my');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw',
    });

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes); // UTF-8 디코딩
      final data = jsonDecode(decodedResponse); // 디코딩된 문자열을 JSON으로 파싱
      setState(() {
        groups = (data['groups'] as List)
            .map((json) => Group.fromJson(json))
            .toList();

        // Sort groups by joinDate in ascending order
        groups.sort((a, b) => DateTime.fromMicrosecondsSinceEpoch(a.joinDate)
            .compareTo(DateTime.fromMicrosecondsSinceEpoch(b.joinDate)));
      });
    } else {
      print("그룹 불러오기를 실패하였습니다.");
    }
  }

  // 가입일자 계산
  int calculateDaysSinceCreation(int joinDate) {
    final now = DateTime.now();
    final joinDateTime = DateTime.fromMicrosecondsSinceEpoch(joinDate);
    return now.difference(joinDateTime).inDays + 1;
  }

  // 카테고리 색상 설정 함수
  Color getCategoryColor(String category) {
    switch (category) {
      case "건강":
        return Color(0xff6ACBF3);
      case "자기개발":
        return Color(0xff7BD7C6);
      case "일상":
        return Color(0xffF5A77B);
      case "자기관리":
        return Color(0xffC69FEC);
      default:
        return Color(0xffF4A2D8);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '내 그룹',
          style: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: isExpanded ? Colors.grey[600] : Colors.grey[200],
        automaticallyImplyLeading: false, // 뒤로가기 제거
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
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
          color: Colors.grey[200],
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = groups[index];
                    Color categoryColor = getCategoryColor(group.groupCategory);
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      group.groupTitle,
                                      style: TextStyle(
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
                                Text(
                                    "가입 ${group.joinDate}일차"),
                              ],
                            ),
                            SizedBox(height: 8.0),
                            Row(
                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("대표 카테고리 "),
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
                            SizedBox(height: 8.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("루틴장 ${group.createdUserNickname}"),
                                Text("그룹코드 ${group.groupId}"),
                              ],
                            ),
                          ],
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
                  MaterialPageRoute(builder: (context) => MyRoutinePage()),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/routine01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 그룹 버튼 클릭 시 동작할 코드
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/group02.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 통계 버튼 클릭 시 동작할 코드
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/statistics01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 더보기 버튼 클릭 시 동작할 코드
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/more01.png"),
              ),
            ),
          ],
        ),
      ),
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("루틴 그룹",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      // 그룹 추가 버튼
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return GroupRoutinePage(); // 그룹 루틴 페이지 이동 바꿔야함
                            },
                          ));
                        },
                        backgroundColor: Color(0xffF87c3ff),
                        child: Image.asset('assets/images/group-list.png'),
                        shape: CircleBorder(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("그룹 추가",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      SizedBox(width: 10),
                      // 그룹 루틴 추가 버튼
                      FloatingActionButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return AddGroupPage();
                            },
                          ));
                        },
                        backgroundColor: Color(0xffF1E977),
                        child: Image.asset('assets/images/add.png'),
                        shape: CircleBorder(),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
                // add 버튼, X버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(""),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      backgroundColor: isExpanded
                          ? Color(0xffF7C7C7C)
                          : Color(0xffF1E977),
                      child: isExpanded
                          ? Image.asset('assets/images/cancel.png')
                          : Image.asset('assets/images/add.png'),
                      shape: CircleBorder(),
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
