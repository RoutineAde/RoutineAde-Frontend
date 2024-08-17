import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_group/groupManagement.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import '../routine_group/GroupType.dart';
import '../routine_groupLeader/glAddRoutinePage.dart';
import 'glgroupManagement.dart';
import 'groupRoutineEditPage.dart';
import 'groupType.dart';

// 전역 함수로 getCategoryColor를 정의
Color getCategoryColor(String category) {
  switch (category) {
    case "전체":
      return Colors.black;
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

class glOnClickGroupPage extends StatefulWidget {
  final int groupId; // 특정 그룹을 가져오기 위한 groupId 매개변수 추가

  const glOnClickGroupPage({required this.groupId, super.key});

  @override
  State<glOnClickGroupPage> createState() => _glOnClickGroupPageState();
}

class _glOnClickGroupPageState extends State<glOnClickGroupPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isSwitchOn = false;
  late TabController _tabController;
  late Future<GroupResponse> futureGroupResponse;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    futureGroupResponse = fetchGroupResponse(widget.groupId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<GroupResponse> fetchGroupResponse(int groupId) async {
    final response = await http.get(
      Uri.parse('http://15.164.88.94:8080/groups/$groupId'),
      headers: {
        'Authorization':
        'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw', // 필요 시 여기에 토큰을 추가
        'Accept': 'application/json', // JSON 응답을 기대하는 경우
      },
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final jsonResponse = json.decode(decodedResponse);
      return GroupResponse.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load group data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: FutureBuilder<GroupResponse>(
          future: futureGroupResponse,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return const Text('Error');
            } else {
              final groupResponse = snapshot.data!;
              return Text(
                groupResponse.groupInfo.groupTitle,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Image.asset("assets/images/new-icons/hamburger.png"),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "루틴"),
            Tab(text: "채팅"),
          ],
          labelStyle: const TextStyle(fontSize: 18),
          labelColor: Colors.black,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(width: 3.0, color: Color(0xffE6E288)),
            insets: EdgeInsets.symmetric(horizontal: 115.0),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      endDrawer: FutureBuilder<GroupResponse>(
        future: futureGroupResponse,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final groupResponse = snapshot.data!;
            return buildDrawer(groupResponse);
          }
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<GroupResponse>(
            future: futureGroupResponse,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final groupResponse = snapshot.data!;
                return RoutinePage(groupResponse.groupRoutines);
              }
            },
          ),
          ChatScreen(),
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const glAddRoutinePage()));
        },
        backgroundColor: const Color(0xffE6E288),
        shape: const CircleBorder(),
        child: Image.asset(
          "assets/images/add-button.png",
          width: 30,
          height: 30,
        ),
      )
          : null,
    );
  }

  Widget buildDrawer(GroupResponse groupResponse) {
    final groupInfo = groupResponse.groupInfo;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DrawerHeader(
            padding: const EdgeInsets.fromLTRB(25, 10, 10, 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  groupInfo.groupTitle,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: <Widget>[
                buildDrawerListTile("그룹 코드", "#${groupInfo.groupId}"),
                buildDrawerListTile(
                  "대표 카테고리",
                  groupInfo.groupCategory,
                  color: Colors.black, // "대표 카테고리"의 title 텍스트는 검은색으로 유지
                  trailingColor: getCategoryColor(
                      groupInfo.groupCategory), // trailing 텍스트에만 색상을 적용
                ),
                buildDrawerListTile("인원",
                    "${groupInfo.joinMemberCount} / ${groupInfo.maxMemberCount} 명"),
                buildSwitchListTile(),
                const Divider(),
                buildDrawerHeaderTile("그룹원"),
                ...groupResponse.groupMembers.map((member) {
                  return buildDrawerMemberTile(
                    member.nickname,
                    member.profileImage,
                    isLeader: groupResponse.isGroupAdmin &&
                        member.nickname == groupInfo.createdUserNickname,
                  );
                }),
              ],
            ),
          ),
          buildLeaveGroupTile(),
        ],
      ),
    );
  }

  ListTile buildDrawerListTile(String title, String trailing,
      {Color? color, Color? trailingColor}) {
    return ListTile(
      trailing: Text(
        trailing,
        style: TextStyle(
          color: trailingColor ?? Colors.black, // trailing 텍스트 색상 설정
          fontSize: 15,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: color ?? Colors.black, // title 텍스트 색상 설정
        ),
      ),
    );
  }

  ListTile buildSwitchListTile() {
    return ListTile(
      trailing: CupertinoSwitch(
        activeColor: const Color(0xffE6E288),
        value: _isSwitchOn,
        onChanged: (bool value) {
          setState(() {
            _isSwitchOn = value;
          });
        },
      ),
      title: const Text(
        '알림',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  ListTile buildDrawerHeaderTile(String title) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  ListTile buildDrawerMemberTile(String title, String imagePath,
      {bool isLeader = false}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundImage: AssetImage("assets/images/profile/$imagePath"),
      ),
      title: Row(
        children: <Widget>[
          Text(title),
          if (isLeader)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Image(
                image: AssetImage("assets/images/new-icons/crown.png"),
                width: 16,
                height: 16,
              ),
            ),
        ],
      ),
      trailing: isLeader
          ? null
          : TextButton(
        onPressed: () {
          // 그룹원 내보내기 기능 추가
        },
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsets>(
              const EdgeInsets.all(8.0)),
          backgroundColor:
          WidgetStateProperty.all<Color>(Colors.transparent),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: const BorderSide(color: Colors.black, width: 1.0),
            ),
          ),
        ),
        child: const Text(
          '내보내기',
          style: TextStyle(
            color: Colors.black,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Container buildLeaveGroupTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      height: 60.0, // 컨테이너의 높이 설정
      decoration: BoxDecoration(
        color: Colors.grey[200], // 회색 배경
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const glgroupManagement()));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // 이미지가 오른쪽에 배치되도록 설정
          children: [
            Image.asset(
              'assets/images/new-icons/setting.png',
              width: 30,
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}

class RoutinePage extends StatelessWidget {
  final List<RoutineCategory> routineCategories;

  const RoutinePage(this.routineCategories, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: routineCategories.length,
      itemBuilder: (context, index) {
        final category = routineCategories[index];
        final color = getCategoryColor(category.routineCategory); // 카테고리 색상 설정
        return _buildCategorySection(
          category.routineCategory,
          color, // 여기에서 색상을 전달
          category.routines.map((routine) {
            return _buildRoutineItem(
              context,
              routine.routineTitle,
              routine.repeatDay.join(", "),
              routine.routineId,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildCategorySection(
      String title, Color color, List<Widget> routines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        IntrinsicWidth(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: const EdgeInsets.fromLTRB(30, 40, 0, 16),
            padding: const EdgeInsets.symmetric(
                horizontal: 20.0), // 좌우 여백을 추가하여 텍스트 주변에 공간을 줍니다.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          children: routines,
        ),
      ],
    );
  }

  Widget _buildRoutineItem(
      BuildContext context, String title, String schedule, int routineId) {
    return GestureDetector(
      onTap: () => {_showRoutineDialog(context, title, routineId)},
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 0, 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              "assets/images/new-icons/group-check.png",
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  schedule,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showRoutineDialog(
    BuildContext context, String routineTitle, int routineId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(routineTitle),
        actions: <Widget>[
          TextButton(
            child: const Text('수정'),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => groupRoutineEditPage(
                        groupId: 1,
                        routineTitle: routineTitle,
                        routineId: routineId,
                        repeatDays: const [])),
              );
            },
          ),
          TextButton(
            child: const Text('취소'),
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
          ),
        ],
      );
    },
  );
}