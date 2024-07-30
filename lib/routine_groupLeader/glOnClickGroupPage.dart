import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_groupLeader/glAddRoutinePage.dart';
import 'package:routine_ade/routine_groupLeader/glgroupManagement.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';

import '../routine_group/groupManagement.dart';

class GroupMember {
  final String name;
  final String avatarPath;
  final bool isLeader;

  GroupMember({required this.name, required this.avatarPath, this.isLeader = false});
}

class glOnClickGroupPage extends StatefulWidget {
  const glOnClickGroupPage({super.key});

  @override
  State<glOnClickGroupPage> createState() => _glOnClickGroupPageState();
}

class _glOnClickGroupPageState extends State<glOnClickGroupPage> with SingleTickerProviderStateMixin {
  final List<String> categories = ["자기개발", "건강", "일상"];

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isSwitchOn = false;

  List<GroupMember> members = [
    GroupMember(name: '서현', avatarPath: "assets/images/new-icons/user01.png", isLeader: true),
    GroupMember(name: '김외롭', avatarPath: "assets/images/new-icons/김외롭.png"),
    GroupMember(name: '채은', avatarPath: "assets/images/new-icons/user03.png"),
    GroupMember(name: '윤정', avatarPath: "assets/images/new-icons/user01.png"),
    GroupMember(name: '가은', avatarPath: "assets/images/new-icons/user02.png"),
    GroupMember(name: '이똑똑', avatarPath: "assets/images/new-icons/user03.png"),
  ];

  late TabController _tabController;

  int selectedCategoryIndex = -1;
  List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"];

  DateTime _selectedDate = DateTime.now();

  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100),
          child: AppBar(
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
              tabs: [
                Tab(text: "루틴",),
                Tab(text: "채팅",),
              ],
              labelStyle: TextStyle(
                fontSize: 18,
              ),
              labelColor: Colors.black,
              indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3.0, color: Color(0xffE6E288),),
                  insets: EdgeInsets.symmetric(horizontal: 115.0)
              ),
            ),
            title: Text(
              '꿈을 향해',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold
              ),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        endDrawer: Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DrawerHeader(
                padding: EdgeInsets.fromLTRB(25, 10, 10, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("꿈을 향해                           ", style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold,
                    ),),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(10.0),
                  children: <Widget>[
                    ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('#51', style: TextStyle(
                              fontSize: 18
                          ),),
                        ],
                      ),
                      title: Text('그룹 코드'),
                    ),
                    ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('기타', style: TextStyle(
                            fontSize: 18, color: Color(0xffF4A2D8),
                          ),),
                        ],
                      ),
                      title: Text('대표 카테고리'),
                    ),
                    ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('6 / 30 명', style: TextStyle(
                              fontSize: 18
                          ),),
                        ],
                      ),
                      title: Text('인원'),
                    ),
                    ListTile(
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CupertinoSwitch(
                            value: _isSwitchOn,
                            activeColor: Color(0xffE6E288),
                            onChanged: (value) {
                              setState(() {
                                _isSwitchOn = value;
                              });
                            },
                          ),
                        ],
                      ),
                      title: Text('그룹 알림'),
                    ),
                    Divider(),
                    ListTile(
                      title: Text('그룹원', style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold
                      ),),
                      onTap: () {},
                    ),
                    for (var member in members) ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            member.avatarPath,
                            width: 40,
                            height: 40,
                          ),
                          if (member.isLeader)
                            SizedBox(width: 15,),
                          if (member.isLeader)
                            Image.asset(
                              "assets/images/new-icons/crown.png",
                              width: 20,
                              height: 20,
                            ),
                        ],
                      ),
                      title: Text(member.name, style: TextStyle(
                        fontSize: 18,
                      ),),
                      trailing: member.isLeader
                          ? null
                          : TextButton(
                        onPressed: () {
                          // Handle member removal
                        },
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(8.0)),
                          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                              side: BorderSide(color: Colors.black, width: 1.0),
                            ),
                          ),
                        ),
                        child: Text(
                          '내보내기',
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.grey[300],
                child: ListTile(
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Image.asset("assets/images/new-icons/setting.png",
                          width: 30,
                          height: 30,
                        ),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => glgroupManagement()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // 루틴 페이지
            ListView(
              padding: EdgeInsets.fromLTRB(24, 30, 24, 16),
              children: <Widget>[
                _buildCategorySection('자기 개발', Color(0xff7BD7C6), [
                  _buildRoutineItem('일기 쓰기', '매주 화, 목'),
                  _buildRoutineItem('1시간 독서하기', '매주 토, 일'),
                  _buildRoutineItem('1시간 공부하기', '매주 토, 일'),
                ]),
                SizedBox(height: 50,),
                _buildCategorySection('건강', Color(0xff6ACBF3), [
                  _buildRoutineItem('아침 스트레칭 하기', '매주 월, 화, 수, 목, 금'),
                  _buildRoutineItem('1시간 독서하기', '매주 토, 일'),
                  _buildRoutineItem('1시간 운동하기', '매주 토, 일'),
                ]),
                SizedBox(height: 50,),
                _buildCategorySection('일상', Color(0xffF4A2D8), [
                  _buildRoutineItem('아침 스트레칭 하기', '매주 월, 화, 수, 목, 금'),
                  _buildRoutineItem('1시간 독서하기', '매주 토, 일'),
                  _buildRoutineItem('1시간 공부하기', '매주 토, 일'),
                ]),
              ],
            ),
            // 채팅 페이지
            ChatScreen(),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => glAddRoutinePage()));
          },
          backgroundColor: Color(0xffE6E288),
          shape: CircleBorder(),
          child: Image.asset(
            "assets/images/add.png",
            width: 30,
            height: 30,
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildCategorySection(String title, Color color, List<Widget> routines) {
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
            margin: EdgeInsets.fromLTRB(10, 0, 0, 16),
            padding: EdgeInsets.symmetric(horizontal: 10.0),  // 좌우 여백을 추가하여 텍스트 주변에 공간을 줍니다.
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


  Widget _buildRoutineItem(String title, String schedule) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Image.asset("assets/images/new-icons/group-check.png",
            width: 30,
            height: 30,
          ),
          SizedBox(width: 12,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
              ),),
              SizedBox(height: 4,),
              Text(schedule, style: TextStyle(
                fontSize: 16, color: Colors.grey[600],
              ),),
            ],
          ),
        ],
      ),
    );
  }
}
