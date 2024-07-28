import 'package:flutter/material.dart';
import 'package:routine_ade/routine_group/AddGroupPage.dart';
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
  TextEditingController _passwordController = TextEditingController();

  // 그룹 데이터 생성
  List<Group> groups = [
    Group(name: "꿈을 향해" ,
      creationDate: DateTime.now().subtract(Duration(days: 1)),
      category: "기타",
      membersCount: 6,
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

    Group(name: "갓생러 모여",
        creationDate: DateTime.now().subtract(Duration(days: 1)),
        category: "건강",
        membersCount: 1,
        leader: "갓생호소인",
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
  bool _isPasswordIncorrect = false; // 비밀번호 틀림 여부 상태 추가

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
  //비밀번호 다이얼로그
  void showPasswordDialog(BuildContext context) {
    TextEditingController _passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                "비밀번호를 입력해주세요",
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      hintText: _isPasswordIncorrect
                          ? "비밀번호가 일치하지 않습니다"
                          : "비밀번호 4자리",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      counterText: "",
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    obscureText: true,
                    style: TextStyle(
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_passwordController.text == "1234") {
                      Navigator.of(context).pop();
                    } else {
                      setState(() {
                        _isPasswordIncorrect = true; // 일치하지 않을 때 상태 업데이트
                      });
                    }
                  },
                  child: Text("확인", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("취소", style: TextStyle(color: Colors.black)),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      setState(() {
        _isPasswordIncorrect = false; // 다이얼로그 닫힐 때 상태 초기화
      });
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
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.0,
            ),
          ),
          onChanged: (value) {
            filterGroups(value);
          },
        )
            : Text("루틴 그룹",
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
                                      category == "일상"? Color(0xffF5A77B):
                                      category == "건강"? Color(0xff6ACBF3):
                                      category == "자기개발"? const Color(0xff7BD7C6):
                                      category == "자기관리"? const Color(0xffC69FEC):
                                      category == "기타"? Color(0xffF4A2D8): Colors.black,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.white),


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
                          group.category == "일상"? Color(0xff5A77B):
                          group.category == "건강"? Color(0xff6ACBF3):
                          group.category == "자기개발"? Color(0xff7BD7C6):
                          group.category == "자기관리"? Color(0xffC69FEC):
                          group.category == "기타"? Color(0xff4A2D8): Colors.black;
                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(15.0),
                              child: GestureDetector(
                                onTap: (){
                                  if(index ==2 ){
                                    showPasswordDialog(context); //3번째 카드 누르면 비밀번호 화면 표시
                                  }
                                  else
                                    showGroupDetailsDialog(context, group); //그룹 카드를 누르면 다이얼로그 표시
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(group.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                        if(index==2)
                                          Padding(
                                            padding: const EdgeInsets.only(left:2.0),
                                            child:Image.asset("assets/images/lock.png", width: 24, height: 24,),
                                          ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddGroupPage()),
                );
              },
              child: Icon(Icons.add, color: Colors.white),
              backgroundColor: Color(0xffF1E977),
              shape: CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}