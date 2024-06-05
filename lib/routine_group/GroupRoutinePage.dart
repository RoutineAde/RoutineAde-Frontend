import 'package:flutter/material.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'Dialog.dart';
import 'package:routine_ade/routine_group/GroupType.dart';

class GroupRoutinePage extends StatefulWidget {
  @override
  _GroupRoutinePageState createState() => _GroupRoutinePageState();
  // State<GroupRoutinePage> createState() => _GroupRoutinePagState()
}

class _GroupRoutinePageState extends State<GroupRoutinePage> {
  // 텍스트필드 컨트롤러
  TextEditingController _searchController = TextEditingController();

  // 그룹 데이터 생성
List<Group> groups = [
    Group(name: "꿈을 향해" , 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "기타", 
    membersCount: 23, 
    leader: "가은", 
    groupCode: "#10",
    groupIntro: "부지런쟁이들을 환영합니다!\n주 4회 이상 루틴 수행을 안하면 강퇴입니다!\n성실하게 루틴을 수행하실 분들만 들어와주세요.",

    ),

    Group(name: "피트니스 챌린지", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "건강", 
    membersCount: 3, 
    leader: "건강지킴이", 
    groupCode: "#9",
    groupIntro: "같이 피트니스 하실 분 모집합니다! 초보자 환영"
    ),

     Group(name: "행복한 일상", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "자기관리", 
    membersCount: 21, 
    leader: "서현", 
    groupCode: "#8",
    groupIntro: "갓생루틴으로 행복한 일상 보내실 분 구함"
    ),

     Group(name: "아침의 시작", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "자기개발", 
    membersCount: 15, 
    leader: "윤정", 
    groupCode: "#7",
    groupIntro: "일찍 일어나서 꾸준하게 자기개발 하실분 구합니다!같이 갓생 살아요"
    ),

     Group(name: "자기관리 마스터모임", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "자기관리", 
    membersCount: 10, 
    leader: "채은", 
    groupCode: "#6",
    groupIntro: "테스트용 입니다.",
    ),
     Group(name: "공부 열심히 할 사람만", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "자기개발", 
    membersCount: 30, 
    leader: "공부짱", 
    groupCode: "#5",
    groupIntro: "테스트용 입니다.",
    ),
     Group(name: "독사모", 
    creationDate: DateTime.now().subtract(Duration(days: 1)), 
    category: "자기개발", 
    membersCount: 30, 
    leader: "독서초보", 
    groupCode: "#4",
    groupIntro: "테스트용 입니다.",
    ),
  ];

  // 필터링 된 그룹 데이터
  List<Group> filteredGroups = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    filteredGroups = groups;
  }

  // 검색 모드 전환 함수
  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        filterGroups('');
      }
    });
  }

  // 그룹 필터링 함수
  void filterGroups(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredGroups = groups
            .where((group) =>
                group.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredGroups = groups;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 검색 모드인 경우, 텍스트필드,아닌 경우 루틴그룹 표시
        title: _isSearching
            ? TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "  그룹명을 입력하세요",
                  fillColor: Colors.white,
                  filled: true,
                  // border: OutlineInputBorder(
                  //   borderRadius: BorderRadius.circular(12.0),
                  //   borderSide: BorderSide.none,
                  // ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.0,
                  ),
                ),
                onChanged: (value) {
                  filterGroups(value);
                },
              )
            : Text(
                "루틴 그룹",
                style: TextStyle(color: Colors.black, fontSize: 23, fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: _isSearching ? Icon(Icons.close) : Image.asset("assets/images/search.png", width: 27, height: 27),
            onPressed: toggleSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.0), // 좌우 여백
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.grey[200], // 전체 배경색 회색으로 변경
                  // 카테고리 버튼
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 1.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          '전체',
                          '일상',
                          '건강',
                          '자기개발',
                          '자기관리',
                          '기타'
                        ].map((category) {
                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 3.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // 카테고리 버튼 클릭 시 동작할 코드 작성
                              },
                              child: Text(
                                category,
                                style: TextStyle(
                                  color: category == "전체"? Colors.black:
                                  category == "일상"? Color(0xff5A77B):
                                  category == "건강"? Color(0xff6ACBF3):
                                  category == "자기개발"? const Color(0xff7BD7C6):
                                  category == "자기관리"? const Color(0xffC69FEC):
                                  category == "기타"? Color(0xffF4A2D8): Colors.black,
                                  ),
                              ),
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.white),
                                // padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0)),
                                // shape:MaterialStateProperty.all(
                                //   RoundedRectangleBorder(
                                //     side:BorderSide(color:Colors.black),// 버튼 테두리 색상
                                //     borderRadius: BorderRadius.circular(20.0), //버튼 모서리 둥글게
                                //   )
                                // ),

                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ),
              ),
                Expanded(
            child: ListView.builder(
              itemCount: filteredGroups.length,
              itemBuilder: (context, index) {
                final group = filteredGroups[index];
                Color textColor = group.category == "전체"? Colors.black:
                                  group.category == "일상"? Colors.orange:
                                  group.category == "건강"? Colors.blue:
                                  group.category == "자기개발"? const Color.fromARGB(255, 186, 224, 255):
                                  group.category == "자기관리"? const Color.fromARGB(255, 205, 150, 214):
                                  group.category == "기타"? Colors.pink: Colors.black;
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: GestureDetector(
                      onTap: (){
                        showGroupDetailsDialog(context, group); //그룹 카드를 누르면 다이얼로그 표시
                                },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                    Text(group.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  SizedBox(height: 4.0),  
                                  Row(
                                    children: [
                                      Text("대표 카테고리 "),
                                      // SizedBox(width: 4.0),
                                      Text(group.category, style: TextStyle( color: textColor)),
                                      Expanded(child: Container()),

                                      Text("인원 ${group.membersCount}/30명"),],
                                      // SizedBox(width: 10.0), // 간격 조절
                                    
                                  ),
                                  SizedBox(height: 4.0),
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
                        ),
                      );
                      },
                    ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
          //add 버튼
          Positioned(
            bottom: 25,
            right: 25,
            child: FloatingActionButton(
              onPressed: () {
                // floating action button이 클릭되었을 때의 동작
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color(0xffF1E977),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
//바텀 네비게이션바
      // bottomNavigationBar: BottomAppBar(
      //   color: Colors.white,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: [
      //       IconButton(
      //         icon: Image.asset("assets/images/tap-bar/routine01.png"),
      //         onPressed: () {
      //           Navigator.push(
      //             context,
      //             MaterialPageRoute(builder: (context)=> MyRoutinePage()),
      //           );
      //         },
      //       ),
      //       IconButton(
      //         icon: Image.asset("assets/images/tap-bar/group02.png"),
      //         onPressed: () {
      //           // 그룹 버튼 클릭 시 동작할 코드
      //         },
      //       ),
      //       IconButton(
      //         icon: Image.asset("assets/images/tap-bar/statistics01.png"),
      //         onPressed: () {
      //           // 통계 버튼 클릭 시 동작할 코드
      //         },
      //       ),
      //       IconButton(
      //         icon: Image.asset("assets/images/tap-bar/more01.png"),
      //         onPressed: () {
      //           // 더보기 버튼 클릭 시 동작할 코드
      //         },
      //         ),
      //     ],
      //   ),
      // ),
    );
  }
}
