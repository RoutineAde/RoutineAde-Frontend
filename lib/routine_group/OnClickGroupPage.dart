import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import 'groupType.dart';

class OnClickGroupPage extends StatefulWidget {
  final int groupId; // 특정 그룹을 가져오기 위한 groupId 매개변수 추가

  const OnClickGroupPage({required this.groupId, super.key});

  @override
  State<OnClickGroupPage> createState() => _OnClickGroupPageState();
}

class _OnClickGroupPageState extends State<OnClickGroupPage>
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
            'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjA0MzIzMDYsImV4cCI6MTczNTk4NDMwNiwidXNlcklkIjoxfQ.gVbh87iupFLFR6zo6PcGAIhAiYIRfLWV_wi8e_tnqyM', // 필요 시 여기에 토큰을 추가
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
                buildDrawerListTile("대표 카테고리", groupInfo.groupCategory),
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

  ListTile buildDrawerListTile(String title, String trailing, {Color? color}) {
    return ListTile(
      trailing: Text(
        trailing,
        style: const TextStyle(
            color: Color(0xffE6E288),
            fontSize: 15,
            fontWeight: FontWeight.bold),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  ListTile buildLeaveGroupTile() {
    return ListTile(
      title: const Text(
        '그룹 나가기',
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
      ),
      onTap: () {
        // 그룹 나가기 동작 추가
      },
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
        return ExpansionTile(
          title: Text(category.routineCategory),
          children: category.routines.map((routine) {
            return ListTile(
              title: Text(routine.routineTitle),
              subtitle: Text(routine.repeatDay.join(", ")),
            );
          }).toList(),
        );
      },
    );
  }
}
