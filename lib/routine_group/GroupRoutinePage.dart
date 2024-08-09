import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GroupRoutinePage extends StatefulWidget {
  @override
  _GroupRoutinePageState createState() => _GroupRoutinePageState();
}

class _GroupRoutinePageState extends State<GroupRoutinePage> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  List<EntireGroup> allGroups = [];
  List<EntireGroup> filteredGroups = [];
  bool _isSearching = false;
  bool _isPasswordIncorrect = false;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  String? selectedCategory = '전체';

  @override
  void initState() {
    super.initState();
    _fetchGroups();
  }

  Future<void> _fetchGroups({bool loadMore = false, String? category}) async {
    if (loadMore) {
      _currentPage++;
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
        allGroups.clear();
      });
    }

    String categoryQuery = category != null && category != '전체'
        ? 'groupCategory=${Uri.encodeComponent(category)}'
        : 'groupCategory=%EC%A0%84%EC%B2%B4';
    final url = Uri.parse(
        'http://15.164.88.94:8080/groups?$categoryQuery');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization':
      'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw',
    });

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);

      setState(() {
        if (data is Map<String, dynamic> && data.containsKey('groups')) {
          final newGroups = (data['groups'] as List<dynamic>)
              .map((json) => EntireGroup.fromJson(json))
              .toList();
          allGroups.addAll(newGroups);
        }

        filteredGroups = allGroups;
        _sortGroupsByGroupIdDescending(); // 그룹 정렬 추가
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("그룹 불러오기를 실패하였습니다.");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
    }
  }

  Color getCategoryColor(String category) {
    switch (category) {
      case "전체":
        return Colors.black;
      case "건강":
        return Color(0xff6ACBF3);
      case "자기개발":
        return Color(0xff7BD7C6);
      case "일상":
        return Color(0xffF5A77B);
      case "자기관리":
        return Color(0xffC69FEC);
      default:
        return Color(0xffF4A2D8);
    }
  }

  void toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        filterGroups('');
      }
    });
  }

  void _sortGroupsByGroupIdDescending() {
    filteredGroups.sort((a, b) => b.groupId.compareTo(a.groupId));
  }

  void filterGroups(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredGroups = allGroups
            .where((group) =>
            group.groupTitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredGroups = allGroups;
      }
      _sortGroupsByGroupIdDescending(); // 필터 후 정렬 유지
    });
  }

  void _showGroupDialog(EntireGroup Egroup) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,  // 배경색을 하얀색으로 설정
          title: Center(child: Text(Egroup.groupTitle)),  // 가운데 정렬
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,  // 가운데 정렬
            children: [
              Text("그룹 코드 #${Egroup.groupId}"),
              Text("대표 카테고리 ${Egroup.groupCategory}"),
              Text("루틴장 ${Egroup.createdUserNickname}"),
              Text("인원 ${Egroup.joinMemberCount}/${Egroup.maxMemberCount}명"),
            ],
          ),
          actions: [
            ButtonBar(
              alignment: MainAxisAlignment.end,  // 버튼들을 오른쪽에 정렬
              children: [
                TextButton(
                  child: Text("가입하기"),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그를 닫고
                    if (Egroup.isPublic) {
                      // 공개 그룹이면 바로 참여 로직 추가 가능
                      print("참여 성공!");
                    } else {
                      // 비공개 그룹이면 비밀번호 입력 다이얼로그를 보여줌
                      _showPasswordDialog(Egroup);
                    }
                  },
                ),
                TextButton(
                  child: Text("취소"),
                  onPressed: () {
                    Navigator.of(context).pop(); // 다이얼로그 닫기
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }


  void _showPasswordDialog(EntireGroup group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,  // 배경색을 하얀색으로 설정
          title: Center(child: Text("비공개 그룹")),  // 가운데 정렬
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,  // 가운데 정렬
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "비밀번호 4자리 입력",
                  errorText: _isPasswordIncorrect ? "비밀번호가 틀렸습니다." : null,
                ),
              ),

            ],
          ),
          actions: [
            ButtonBar(
              alignment: MainAxisAlignment.end,  // 버튼들을 오른쪽에 정렬
              children: [
                TextButton(
                  child: Text("취소"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _passwordController.clear();
                    _isPasswordIncorrect = false;
                  },
                ),
                TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    _checkPassword(group);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _checkPassword(EntireGroup group) {
    setState(() {
      if (_passwordController.text == group.groupPassword) {
        Navigator.of(context).pop();
        _passwordController.clear();
        _isPasswordIncorrect = false;
        // 비밀번호가 맞으면, 참여 로직 추가 가능
        print("참여 성공!");
      } else {
        _isPasswordIncorrect = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            : Text(
          "루틴 그룹",
          style: TextStyle(
              color: Colors.black,
              fontSize: 23,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: _isSearching
                ? Icon(Icons.close)
                : Image.asset("assets/images/search.png",
                width: 27, height: 27),
            onPressed: toggleSearch,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.0),
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.grey[200],
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
                              bool isSelected = selectedCategory == category;
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 3.0),
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedCategory = category;
                                    });
                                    _fetchGroups(category: category);
                                  },
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: getCategoryColor(category), // Always set the color based on the category
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                      isSelected ? Colors.white : Color(0xE8E8E8EF),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? Center(child: CircularProgressIndicator())
                          : ListView.builder(
                        itemCount: filteredGroups.length,
                        itemBuilder: (context, index) {
                          final group = filteredGroups[index];
                          Color textColor =
                          getCategoryColor(group.groupCategory);
                          return InkWell(
                            onTap: () {
                              _showGroupDialog(group);
                            },
                            child: Card(
                              margin: EdgeInsets.all(8.0),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              group.groupTitle,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            if (!group.isPublic)
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Image.asset(
                                                  "assets/images/lock.png",
                                                  width: 20,
                                                  height: 20,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        Text("대표 카테고리 "),
                                        Text(group.groupCategory,
                                            style: TextStyle(
                                                color: textColor)),
                                        Expanded(child: Container()),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                              "인원 ${group.joinMemberCount}/${group.maxMemberCount}명"),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("루틴장 ${group.createdUserNickname}"),
                                        Text("그룹코드 ${group.groupId}"),
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
        ],
      ),
    );
  }
}

class EntireGroup {
  final int groupId;
  final String groupTitle;
  final String groupCategory;
  final String createdUserNickname;
  final int maxMemberCount;
  final int joinMemberCount;
  final bool isPublic;
  final String? groupPassword;

  EntireGroup({
    required this.groupId,
    required this.groupTitle,
    required this.groupCategory,
    required this.createdUserNickname,
    required this.maxMemberCount,
    required this.joinMemberCount,
    required this.isPublic,
    this.groupPassword,
  });

  factory EntireGroup.fromJson(Map<String, dynamic> json) {
    return EntireGroup(
      groupId: json['groupId'] ?? 0,
      groupTitle: json['groupTitle'] ?? 'Unknown',
      groupCategory: json['groupCategory'] ?? '기타',
      createdUserNickname: json['createdUserNickname'] ?? 'Unknown',
      maxMemberCount: json['maxMemberCount'] ?? 0,
      joinMemberCount: json['joinMemberCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      groupPassword: json['groupPassword'],
    );
  }
}