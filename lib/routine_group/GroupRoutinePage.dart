import 'package:flutter/material.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'Dialog.dart';

class Group {
  //그룹
  final String name;
  final DateTime creationDate;
  final String category;
  final int membersCount;
  final String leader;
  final String groupCode;

  Group({
    required this.name,
    required this.creationDate,
    required this.category,
    required this.membersCount,
    required this.leader,
    required this.groupCode,
  });
}

class GroupRoutinePage extends StatefulWidget {
  @override
  _GroupRoutinePageState createState() => _GroupRoutinePageState();
  // State<GroupRoutinePage > createState() => _GroupRoutinePagState()
}

class _GroupRoutinePageState extends State<GroupRoutinePage> {
  // 텍스트필드 컨트롤러
  TextEditingController _searchController = TextEditingController();

  // 그룹 데이터 생성
  List<Group> groups = List.generate(
    10,
    (index) => Group(
      name: "그룹 $index",
      creationDate: DateTime.now(),
      category: "카테고리 $index",
      membersCount: index + 1,
      leader: "익명 $index",
      groupCode: "#$index",
    ),
  );

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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
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
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: _isSearching
                ? Icon(Icons.close)
                : Image.asset("assets/images/search.png",
                    width: 35, height: 35),
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
                            children: ['전체', '일상', '건강', '자기개발', '자기관리', '기타']
                                .map((category) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    // 카테고리 버튼 클릭 시 동작할 코드 작성
                                  },
                                  child: Text(
                                    category,
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.white),
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
                          return Card(
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.all(7.0),
                              child: GestureDetector(
                                onTap: () {
                                  showGroupDetailsDialog(
                                      context, group); //그룹 카드를 누르면 다이얼로그 표시
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(group.name,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "가입일자: ${group.creationDate.toString().substring(0, 10)}"),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 4.0,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(group.category),
                                        Text("인원수: ${group.membersCount}명"),
                                      ],
                                    ),
                                    SizedBox(height: 4.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("루틴장: ${group.leader}"),
                                        Text("그룹코드: ${group.groupCode}"),
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
