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
  int _currentPage = 1; // 현재 페이지
  final int _pageSize = 10; // 한 번에 가져올 데이터 양
  String? selectedCategory = '전체'; // 선택된 카테고리 추가

  @override
  void initState() {
    super.initState();
    _fetchGroups(); // 초기 로드 시 '전체' 카테고리 데이터 불러오기
  }

  Future<void> _fetchGroups({bool loadMore = false, String? category}) async {
    if (loadMore) {
      _currentPage++; // 더 로드할 때는 페이지 증가
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 1; // 처음 로드 시 페이지 초기화
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
      final decodedResponse = utf8.decode(response.bodyBytes); // UTF-8 디코딩
      final data = jsonDecode(decodedResponse);

      print("Response Data: $data"); // 응답 데이터를 로그로 출력하여 확인

      setState(() {
        if (data is Map<String, dynamic> && data.containsKey('groups')) {
          final newGroups = (data['groups'] as List<dynamic>)
              .map((json) => EntireGroup.fromJson(json))
              .toList();
          allGroups.addAll(newGroups);
        }

        filteredGroups = allGroups; // 초기에는 모든 그룹을 필터링된 그룹에 할당
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

  int calculateDaysSinceCreation(int joinDate) {
    final now = DateTime.now();
    final joinDateTime = DateTime.fromMillisecondsSinceEpoch(joinDate);
    return now.difference(joinDateTime).inDays + 1;
  }

  Color getCategoryColor(String category) {
    switch (category) {
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

  void filterGroups(String query) {
    setState(() {
      if (query.isNotEmpty) {
        filteredGroups = allGroups
            .where((group) =>
            group.groupTitle.toLowerCase().contains(query.toLowerCase()))
            .toList();
      } else {
        filteredGroups = allGroups; // 검색어가 없을 때 모든 그룹을 보여줌
      }
    });
  }

  void showPasswordDialog(BuildContext context, String groupPassword) {
    _passwordController.clear();
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
                    if (_passwordController.text == groupPassword) {
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
              padding: EdgeInsets.symmetric(horizontal: 7.0), // 좌우 여백
              child: Container(
                color: Colors.grey[200],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      color: Colors.grey[200], // 전체 배경색 회색으로 변경
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
                                    setState(() {
                                      selectedCategory = category; // 선택된 카테고리 설정
                                    });
                                    _fetchGroups(category: category); // 선택된 카테고리로 그룹 불러오기
                                  },
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: category == selectedCategory
                                          ? Colors.black
                                          : getCategoryColor(category),
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.white),
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
                          return Card(
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
                                              ), //비밀번호 방 여부
                                            ),
                                        ],
                                      ),
                                      Text(
                                          "가입 ${calculateDaysSinceCreation(group.joinDate)}일차"),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      Text("대표 카테고리 "),
                                      Text(group.groupCategory,
                                          style: TextStyle(
                                              color: textColor)),
                                      Expanded(child: Container()), // 간격 조절
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
  final int joinDate;
  final bool isPublic;
  final String? groupPassword;  // 비밀번호는 null 가능

  EntireGroup({
    required this.groupId,
    required this.groupTitle,
    required this.groupCategory,
    required this.createdUserNickname,
    required this.maxMemberCount,
    required this.joinMemberCount,
    required this.joinDate,
    required this.isPublic,
    this.groupPassword,  // nullable로 선언
  });

  factory EntireGroup.fromJson(Map<String, dynamic> json) {
    return EntireGroup(
      groupId: json['groupId'] ?? 0,
      groupTitle: json['groupTitle'] ?? 'Unknown',
      groupCategory: json['groupCategory'] ?? '기타',
      createdUserNickname: json['createdUserNickname'] ?? 'Unknown',
      maxMemberCount: json['maxMemberCount'] ?? 0,
      joinMemberCount: json['joinMemberCount'] ?? 0,
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']).millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch,
      isPublic: json['isPublic'] ?? true,
      groupPassword: json['groupPassword'],
    );
  }
}