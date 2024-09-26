import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_groupLeader/groupDelete.dart';
import 'package:http/http.dart' as http;
import '../routine_group/GroupType.dart';
import 'groupRoutineEditPage.dart';
import 'AddGroupRoutinePage.dart';
import 'package:routine_ade/routine_user/token.dart';
import 'glGroupIntroRule.dart';
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
  bool _isFloatingActionButtonVisible = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    futureGroupResponse = fetchGroupResponse(widget.groupId);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  //탭바 여부
  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _isFloatingActionButtonVisible = _tabController.index == 0;
      });
    }
  }

  Future<GroupResponse> fetchGroupResponse(int groupId) async {
    final response = await http.get(
      Uri.parse('http://15.164.88.94/groups/$groupId'),
      headers: {
        'Authorization': 'Bearer $token',
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
      backgroundColor: Colors.white,
      key: _scaffoldKey,
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
          ChatScreen(groupId: widget.groupId),
        ],
      ),
      endDrawerEnableOpenDragGesture: false,
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            AddGroupRoutinePage(groupId: widget.groupId)));
              },
              backgroundColor: const Color(0xffA1D1F9),
              shape: const CircleBorder(),
              child: Image.asset(
                "assets/images/add-button.png",
                width: 80,
                height: 80,
              ),
            )
          : null,
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
                  buildSwitchListTile(),
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Divider(),
                  ),
                  buildDrawerHeaderTile("그룹원"),
                  ...groupResponse.groupMembers.map((member) {
                    return buildDrawerMemberTile(
                        member, // Pass the full member object as GroupMember
                        member.nickname, // member.nickname as String (title)
                        member
                            .profileImage, // member.profileImage as String (profileImage)
                        groupInfo
                            .groupId, // Convert groupId to int (groupId should be an int)
                        member.userId, // member.userId as int
                        isLeader: groupResponse.isGroupAdmin &&
                            member.nickname ==
                                groupInfo.createdUserNickname // isLeader flag
                        );
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

  ListTile buildSwitchListTile() {
    return ListTile(
      trailing: CupertinoSwitch(
        activeColor: const Color(0xffB4DDFF),
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

  ListTile buildDrawerMemberTile(GroupMember member, String title,
      String profileImage, int groupId, int userId,
      {bool isLeader = false}) {
    return ListTile(
      leading: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtherUserRoutinePage(userId: member.userId),
            ),
          );
        },
        child: CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(member.profileImage),
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
      trailing: isLeader
          ? null
          : TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('정말 내보내시겠습니까?'),
                      actions: <Widget>[
                        TextButton(
                          child: const Text('취소'),
                          onPressed: () {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                          },
                        ),
                        TextButton(
                          child: const Text('내보내기'),
                          onPressed: () async {
                            Navigator.of(context).pop(); // 다이얼로그 닫기
                            try {
                              await deleteMember(groupId, userId);
                              // 성공 시 추가 동작을 수행할 수 있습니다. 예: UI 업데이트
                            } catch (error) {
                              // 오류 처리
                            }
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(
                    const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0)), // 패딩 설정
                minimumSize: WidgetStateProperty.all<Size>(
                    const Size(0, 30)), // 버튼의 최소 높이 설정 (예: 36)
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

  Future<void> deleteMember(int groupId, int userId) async {
    final url = 'http://15.164.88.94/groups/$groupId/members/$userId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete member');
    }
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
                  builder: (context) => groupDelete(groupId: widget.groupId)));
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // 이미지가 오른쪽에 배치되도록 설정
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
                        color: Color.fromARGB(255, 70, 70, 70)),
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
                      builder: (context) => glGroupIntroRule(groupId: groupId),
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
                routine.routineId,
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
      onTap: () => {_showRoutineDialog(context, title, routineId, groupId)},
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
  BuildContext context,
  String routineTitle,
  int routineId,
  int groupId,
  //String routineCategory, // routineCategory 추가
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      //final categoryColor = getCategoryColor(routineCategory); // 카테고리 색상 얻기

      return AlertDialog(
        backgroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(routineTitle),
            const SizedBox(height: 8),
            // routineCategory를 추가하고 색상 적용
            // Text(
            //   routineCategory,
            //   style: TextStyle(
            //     color: categoryColor, // 카테고리 색상 적용
            //     fontSize: 16,
            //   ),
            // ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => groupRoutineEditPage(
                    groupId: groupId,
                    routineTitle: routineTitle,
                    routineId: routineId,
                    repeatDays: const [],
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Image.asset(
                  "assets/images/edit.png",
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 20),
                const Text(
                  '수정',
                  style: TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 현재 다이얼로그 닫기
              _showDeleteConfirmationDialog(
                  context, routineTitle, groupId, routineId); // 삭제 확인 다이얼로그 열기
            },
            child: Row(
              children: [
                Image.asset(
                  "assets/images/delete.png",
                  width: 20,
                  height: 20,
                ),
                const SizedBox(width: 20),
                const Text(
                  '삭제',
                  style: TextStyle(fontSize: 18, color: Color(0xFF8DCCFF)),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

// 삭제 확인 다이얼로그 함수
void _showDeleteConfirmationDialog(
    BuildContext context, String routineTitle, int groupId, int routineId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // 수평 가운데 정렬
          children: [
            const SizedBox(height: 20),
            Image.asset(
              "assets/images/warning.png", // warning 이미지 경로
              width: 60, // 원하는 크기로 이미지 조정
              height: 60,
            ),
            const SizedBox(height: 16), // 이미지와 텍스트 사이의 간격
            const Text(
              "루틴 삭제",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center, // 텍스트 가운데 정렬
            ),
          ],
        ),
        content: const SizedBox(
          height: 150, // 다이얼로그의 높이 조절
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // 모든 텍스트 가운데 정렬
            mainAxisAlignment:
                MainAxisAlignment.center, // 텍스트들이 수직 가운데 정렬되도록 추가
            children: [
              Text(
                "루틴을 삭제하면 해당 루틴의",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text(
                "모든 기록이 사라지며,",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              Text(
                "루틴원들에게도 삭제됩니다.",
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 가운데 정렬
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                },
                child: const Text(
                  "취소",
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 10), // 버튼 사이의 간격 조절
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  try {
                    await deleteGroupRoutine(groupId, routineId);
                    // 성공 시 추가 동작을 수행할 수 있습니다. 예: UI 업데이트
                  } catch (error) {
                    // 오류 처리
                  }
                },
                child: const Text(
                  "삭제",
                  style: TextStyle(fontSize: 16, color: Color(0xFF8DCCFF)),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> deleteGroupRoutine(int groupId, int routineId) async {
  final url = 'http://15.164.88.94/groups/$groupId/group-routines/$routineId';
  final response = await http.delete(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete group routine');
  }
}

class GroupInfo {
  final String groupTitle;
  final String groupDescription;
  final int groupId;

  GroupInfo({
    required this.groupTitle,
    required this.groupDescription,
    required this.groupId,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      groupTitle: json['groupTitle'] ?? 'No title',
      groupDescription: json['groupDescription'] ?? 'No description',
      groupId: json['groupId'] != null ? json['groupId'] as int : 0,
    );
  }
}
