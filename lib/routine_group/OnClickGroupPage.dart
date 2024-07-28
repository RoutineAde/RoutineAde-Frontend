import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart'; //날짜 포맷팅 init 패키지

class OnClickGroupPage extends StatefulWidget {
  const OnClickGroupPage({super.key});



  @override
  State<OnClickGroupPage> createState() => _OnClickGroupPageState();
}

class _OnClickGroupPageState extends State<OnClickGroupPage> with SingleTickerProviderStateMixin{
  final List<String> categories = ["자기개발", "건강", "일상"];

  /*
  final Map<String, List<String>> items = {
    "자기 개발" : ["일기 쓰기", "1시간 독서하기",],
    "건강" : ["아침 스트레칭 하기"],
    "일상" : ["명상하기"],
  };
   */

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _isSwitchOn = false;

  late TabController _tabController;

  //카테고리 선택 (한번에 하나만)
  int selectedCategoryIndex = -1;
  List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"];

  DateTime _selectedDate = DateTime.now(); //선택된 날짜

  //날짜 포맷팅
  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  //탭
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
        //backgroundColor: Colors.grey[200],
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
            //backgroundColor: Colors.grey[200],
            title: Text(
              '꿈을 향해',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
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

                    Divider(),  //구분선 추가
                    ListTile(
                      title: Text('그룹원', style: TextStyle(
                          fontSize:20, fontWeight: FontWeight.bold
                      ),
                      ),
                      onTap: () {

                      },
                    ),

                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/new-icons/user01.png",
                            width: 40,
                            height: 40,
                          ),
                          SizedBox(width: 15,),
                          Image.asset(
                            "assets/images/new-icons/crown.png",
                            width: 20,
                            height: 20,
                          ),
                        ],
                      ),
                      title: Text('서현', style: TextStyle(
                        fontSize:18,
                      ),
                      ),
                    ),

                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/new-icons/김외롭.png",
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                      title: Text('김외롭', style: TextStyle(
                        fontSize:18,
                      ),
                      ),
                    ),

                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/new-icons/user03.png",
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                      title: Text('채은', style: TextStyle(
                        fontSize:18,
                      ),
                      ),

                    ),

                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/new-icons/user01.png",
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                      title: Text('윤정', style: TextStyle(
                        fontSize:18,
                      ),
                      ),

                    ),

                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/new-icons/user02.png",
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                      title: Text('가은', style: TextStyle(
                        fontSize:18,
                      ),
                      ),

                    ),

                    ListTile(
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            "assets/images/new-icons/user03.png",
                            width: 40,
                            height: 40,
                          ),
                        ],
                      ),
                      title: Text('이똑똑', style: TextStyle(
                        fontSize:18,
                      ),
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                color: Colors.grey[300],
                child: ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Image.asset("assets/images/new-icons/group-out.png",
                          width: 30,
                          height: 30,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("그룹을 나가시겠습니까?"),
                                  content: Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(builder: (context) => GroupMainPage()),
                                          // );
                                        },
                                        child: Row(
                                          children: [
                                            Text("나가기"),
                                          ],
                                        ),
                                      ),

                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (context) => OnClickGroupPage()),
                                          );
                                        },
                                        child: Row(
                                          children: [
                                            Text("취소"),
                                          ],
                                        ),
                                      ),

                                    ],
                                  ),
                                );
                              }
                          );
                        },),

                    ],
                  ),
                  title: Text('그룹 나가기'),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            //루틴 페이지
            Expanded(
              child:  ListView(
                padding: EdgeInsets.fromLTRB(24, 30, 24, 16),
                children: <Widget>[
                  ListTile(
                    title: Wrap(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("자기 개발", style: TextStyle(
                              fontSize:18, fontWeight: FontWeight.bold, color: Color(0xff7BD7C6),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[

                      Container(
                        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                        child: Column(
                          children: <Widget>[


                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("일기 쓰기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 화, 목", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                            SizedBox(height: 20,),


                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("1시간 독서하기"),

                                  ],
                                ),
                              ],
                            ),
                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 토, 일", style: TextStyle(
                                      color: Colors.grey,
                                    ),),
                                  ],
                                ),
                              ],
                            ),

                            SizedBox(height: 20,),
                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("1시간 공부하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 토, 일", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                          ],
                        ),
                      )
                    ],
                  ),

                  SizedBox(height: 50,),

                  ListTile(
                    title: Wrap(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("건강", style: TextStyle(
                              fontSize:18, fontWeight: FontWeight.bold, color: Color(0xff6ACBF3),),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[

                      Container(
                        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                        child: Column(
                          children: <Widget>[


                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("아침 스트레칭 하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 월, 화, 수, 목, 금", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                            SizedBox(height: 20,),


                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("1시간 독서하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 토, 일", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                            SizedBox(height: 20,),



                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("1시간 독서하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 토, 일", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                          ],
                        ),
                      )
                    ],
                  ),



                  SizedBox(height: 50,),

                  ListTile(
                    title: Wrap(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text("일상", style: TextStyle(
                                fontSize:18, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 208, 125, 1))),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: <Widget>[

                      Container(
                        padding: EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                        child: Column(
                          children: <Widget>[


                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("명상하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 월, 수, 금", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                            SizedBox(height: 20,),


                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("1시간 독서하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 토, 일", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                            SizedBox(height: 20,),



                            Row(  // 루틴
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 15,),
                                    Image.asset("assets/images/new-icons/group-check.png",
                                      width: 30,
                                      height: 30,
                                    ),
                                    SizedBox(width: 20,),
                                    Text("1시간 독서하기"),

                                  ],
                                ),


                              ],
                            ),

                            Row(  // 반복요일
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(width: 67,),
                                    Text("매주 토, 일", style: TextStyle(
                                      color: Colors.grey,
                                    ),),

                                  ],
                                ),


                              ],
                            ),

                          ],
                        ),
                      )
                    ],
                  ),


                ],
              ),
            ),




            //채팅페이지
            IconButton(
              icon: Icon(Icons.door_back_door_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },),
          ],
        ),
        endDrawerEnableOpenDragGesture: false,
      ),
    );
  }
}