import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_group/groupIntroRule.dart';
import 'package:routine_ade/routine_groupLeader/AddGroupRoutinePage.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';
import 'package:routine_ade/routine_groupLeader/groupEdit.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import 'groupType.dart';
import 'package:routine_ade/routine_user/token.dart';
import 'group-unjoin.dart';
import 'package:routine_ade/routine_otherUser/OtherUserRoutinePage.dart';

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

class OnClickGroupPage extends StatefulWidget {
  final int groupId; // 특정 그룹을 가져오기 위한 groupId 매개변수 추가

  const OnClickGroupPage({required this.groupId, super.key});

  @override
  State<OnClickGroupPage> createState() => _OnClickGroupPageState();
}

class _OnClickGroupPageState extends State<OnClickGroupPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final bool _isSwitchOn = false;
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
      Uri.parse('http://15.164.88.94/groups/$groupId'),
      headers: {
        'Authorization': 'Bearer $token', // 필요 시 여기에 토큰을 추가
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

//알람 보내기
  Future<void> updateGroupAlarm(int groupId, bool isEnabled) async {
    final response = await http.put(
      Uri.parse('http://15.164.88.94/groups/$groupId/alarm'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'isGroupAlarmEnabled': isEnabled}),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to update group alarm');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xff8DCCFF),
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
                    color: Colors.white,
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "루틴"),
                Tab(text: "채팅"),
              ],
              labelStyle: const TextStyle(fontSize: 18),
              labelColor: Colors.black,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Color(0xffB4DDFF)),
                insets: EdgeInsets.symmetric(horizontal: 115.0),
              ),
            ),
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
                return RoutinePage(groupResponse.groupRoutines,
                    groupId: widget.groupId);
              }
            },
          ),
          ChatScreen(
            groupId: widget.groupId,
          ),
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
    );
  }

  Widget buildDrawer(GroupResponse groupResponse) {
    final groupInfo = groupResponse.groupInfo;

    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              color: Colors.white, // DrawerHeader의 배경색
              padding:
                  const EdgeInsets.only(top: 120.0), // DrawerHeader 위쪽 여백 추가
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.fromLTRB(30, 10, 0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          groupInfo.groupTitle,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8.0), // Title과 구분선 사이 간격
                        const Padding(
                          padding: EdgeInsets.only(left: 5.0), // 구분선 왼쪽 공백
                          child: Divider(color: Colors.grey), // 구분선 색상 조정
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(left: 20.0),
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
                  buildSwitchListTile(groupResponse),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Divider(),
                  ),
                  buildDrawerHeaderTile("그룹원"),
                  ...groupResponse.groupMembers.map((member) {
                    bool isLeader =
                        member.nickname == groupInfo.createdUserNickname;
                    return buildDrawerMemberTile(
                        member.nickname, member.profileImage,
                        groupmember: member,
                        groupResponse: groupResponse,
                        isLeader: isLeader);
                  }),
                ],
              ),
            ),
            buildLeaveGroupTile(),
          ],
        ),
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

  ListTile buildSwitchListTile(GroupResponse groupResponse) {
    return ListTile(
      trailing: CupertinoSwitch(
        activeColor: const Color(0xffB4DDFF),
        value: groupResponse.isGroupAlarmEnabled, //현재 상태 표시
        onChanged: (bool value) async {
          try {
            await updateGroupAlarm(widget.groupId, value); //서버에 알림 설정 요청
            setState(() {
              groupResponse.isGroupAlarmEnabled = value; // 알림 상태 업데이트
            });
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update alarm setting')),
            );
          }
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
      {required GroupResponse groupResponse,
      required GroupMember groupmember,
      bool isLeader = false}) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserRoutinePage(
                  userId: groupmember.userId, groupId: widget.groupId),
            ),
          );
        },
        child: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(groupmember.profileImage),
        ),
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
                  builder: (context) => Groupunjoin(groupId: widget.groupId)));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/sign-out.png',
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
  final int groupId;

  const RoutinePage(this.routineCategories, {required this.groupId, super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // "규칙" 텍스트를 가진 컨테이너
        Container(
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.fromLTRB(30, 20, 30, 0),
          decoration: BoxDecoration(
            color: const Color(0xffF6F6F6), // 배경색 설정
            borderRadius: BorderRadius.circular(10.0), // 둥근 모서리 설정
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // 왼쪽에 megaphone.png 이미지 추가
                  const SizedBox(
                    width: 5,
                  ),
                  Image.asset(
                    'assets/images/new-icons/megaphone.png', // 이미지 경로
                    width: 24, // 이미지 너비 설정
                    height: 24, // 이미지 높이 설정
                  ),
                  const SizedBox(width: 15), // 이미지와 텍스트 사이 간격 설정
                  const Text(
                    "그룹 소개 / 규칙",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              // 오른쪽에 화살표 버튼 추가
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 16), // 화살표 아이콘
                onPressed: () {
                  // 버튼을 눌렀을 때의 동작을 여기에 작성
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GroupIntroRule(
                        groupId: groupId,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 각 카테고리와 루틴 아이템을 동적으로 추가
        ...routineCategories.map((category) {
          final color =
              getCategoryColor(category.routineCategory); // 카테고리 색상 설정
          return _buildCategorySection(
            category.routineCategory,
            color,
            category.routines.map((routine) {
              return _buildRoutineItem(
                context,
                routine.routineTitle,
                routine.repeatDay.join(", "),
              );
            }).toList(),
          );
        }),
      ],
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
              color: const Color(0xffF6F6F6),
              borderRadius: BorderRadius.circular(20.0),
            ),
            margin: const EdgeInsets.fromLTRB(30, 40, 0, 16),
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
      BuildContext context, String title, String schedule) {
    return GestureDetector(
      onTap: () => {},
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
