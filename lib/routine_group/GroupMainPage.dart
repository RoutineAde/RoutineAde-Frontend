import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
class _GroupMainPageState extends State<GroupMainPage>{
    bool isExpanded = false;

    
//예시 그룹. GroupRoutinPage 상속 
  List<Group> groups = [
    Group(name: "성공의 루틴" , 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "건강", 
    membersCount: 4, 
    leader: "서현쓰", 
    groupCode: "#13",
    groupIntro: "테스트 용",

    ),
    Group(name: "루틴 킬러", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "일상", 
    membersCount: 21, 
    leader: "윤정", 
    groupCode: "#36",
    groupIntro: "테스트 용",
    ),

    Group(name: "갓생러 모여", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "건강", 
    membersCount: 1,
    leader: "갓생호소인", 
    groupCode: "#8",
    groupIntro: "테스트 용",
    ),
  ];
//가입일자 계산
  String calculateDaysSinceCreation(DateTime creationDate) {
    final now = DateTime.now();
    final difference = now.difference(creationDate).inDays;
    return "가입 ${difference + 1}일차";
  }

  @override
  Widget build(BuildContext context){
    return 
        Scaffold( 
      appBar: AppBar(
        title: Text('내 그룹', 
        style: TextStyle(
          color: Colors.black, 
          fontSize: 25, 
          fontWeight: FontWeight.bold ),),
          centerTitle: true,
          backgroundColor: isExpanded? Colors.grey[600] : Colors.grey[200],
          automaticallyImplyLeading: false, //뒤로가기 제거
          actions: [
            Padding(padding: EdgeInsets.only(right: 16.0),
            child: Image.asset("assets/images/bell.png",
            width: 35,
            height: 35,),
            ),
          ], 
      ), 
      
      //예시그룹
      body: DarkOverlay(
        isDark: isExpanded, //눌렀을때만 어둡게
        onTap: (){
          setState(() {
            isExpanded=false;
          });
        },
        child:  Container(
        color: Colors.grey[200], 
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: groups.length,
                itemBuilder: (context, index) {
                  final group = groups[index];
                  Color textColor = group.category =="건강"? Colors.blue: Colors.orange;
                  return  
                  Card(
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
                              Text(
                                group.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,      
                                ),
                              ),
                              Text(calculateDaysSinceCreation(group.creationDate)),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("대표 카테고리 "), 
                              Text(group.category, style: TextStyle( color: textColor)),
                              Expanded(child: Container()),// 간격 조절
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text("인원 ${group.membersCount}/30명"),),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("루틴장 ${group.leader}"),
                              Text("그룹코드 ${group.groupCode}"),
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

      //바텀 네비게이션 바
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
      //add 버튼
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
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("루틴 그룹", style: 
                    TextStyle( color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                    SizedBox(width: 10),

                     //그룹 추가 버튼
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context){
                          return  GroupRoutinePage();
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
                  Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("그룹 추가", style: TextStyle( color: Colors.white, fontWeight: FontWeight.bold)
                  ),
                     SizedBox(width: 10),

                  //그룹 루틴 추가 버튼
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context){
                          return  AddGroupPage();
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
                //add 버튼, X버튼
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(""),
                     SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  backgroundColor: isExpanded? Color(0xffF7C7C7C): Color(0xffF1E977),
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