import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_group/groupSearchPage.dart';
import '../routine_groupLeader/glOnClickGroupPage.dart';
import 'OnClickGroupPage.dart';
import 'package:routine_ade/routine_user/token.dart';

class GroupRoutinePage extends StatefulWidget {
  const GroupRoutinePage({super.key});

  @override
  _GroupRoutinePageState createState() => _GroupRoutinePageState();
}

class _GroupRoutinePageState extends State<GroupRoutinePage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<EntireGroup> allGroups = [];
  List<EntireGroup> filteredGroups = [];
  bool _isPasswordIncorrect = false;
  bool _isLoading = false;
  int _currentPage = 1;
  final int _pageSize = 10;
  String? selectedCategory = '전체';
  String? selectedSortType = '신규'; // 추가된 정렬 기준
  bool searchByGroupName = true;

  @override
  void initState() {
    super.initState();
    fetchGroups(); // 초기 데이터 로드 (기본은 '신규' 기준)
  }

  // fetchGroups에 sortType 추가
  Future<void> fetchGroups({bool loadMore = false, String? category, String? sortType}) async {
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

    String sortTypeQuery = sortType != null
        ? '&sortType=${Uri.encodeComponent(sortType)}'
        : '&sortType=신규'; // 기본 정렬 기준을 '신규'로 설정

    final url = Uri.parse('http://15.164.88.94/groups?$categoryQuery$sortTypeQuery');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);

      setState(() {
        if (data is Map<String, dynamic> && data.containsKey('groups')) {
          allGroups = (data['groups'] as List<dynamic>)
              .map((json) => EntireGroup.fromJson(json))
              .toList();
        }
        filteredGroups = allGroups;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("그룹 불러오기를 실패하였습니다.");
    }
  }

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

  void _showGroupDialog(EntireGroup Egroup) {
    if (Egroup.isJoined) {
      navigateToGroupPage(Egroup.groupId);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            title: Center(
              child: Column(
                children: [
                  Text(Egroup.groupTitle,
                      style: const TextStyle(color: Colors.black)),
                  const SizedBox(height: 1.0), //그룹 여백
                  Text("그룹 코드 #${Egroup.groupId}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 0), //그룹 코드와 대표 카테고리 사이의 여백
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("대표 카테고리 ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(Egroup.groupCategory),
                  ],
                ),
                const SizedBox(
                  height: 4.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("그룹장 ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(Egroup.createdUserNickname),
                    const Text("  인원 ",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text("${Egroup.joinMemberCount}/${Egroup.maxMemberCount}명"),
                  ],
                ),
                const SizedBox(height: 12), // 추가 설명 텍스트를 위한 공간
                const Divider(
                  height: 20,
                  thickness: 0.5,
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(Egroup.description),
                const SizedBox(
                  height: 80.0,
                ),
              ],
            ),
            actions: [
              OverflowBar(
                alignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("취소",
                        style: TextStyle(
                            color: Color.fromARGB(255, 128, 121, 121))),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text("그룹 가입",
                        style: TextStyle(color: Color(0xff8DCCFF))),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (Egroup.isPublic) {
                        print("참여 성공!");
                      } else {
                        _showPasswordDialog(Egroup);
                      }
                    },
                  ),
                ],
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> navigateToGroupPage(int groupId) async {
    final isAdmin = await fetchIsGroupAdmin(groupId);

    if (isAdmin) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => glOnClickGroupPage(groupId: groupId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OnClickGroupPage(groupId: groupId),
        ),
      );
    }
  }

  Future<bool> fetchIsGroupAdmin(int groupId) async {
    final url = Uri.parse('http://15.164.88.94/groups/$groupId');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);

      if (data is Map<String, dynamic> && data.containsKey('isGroupAdmin')) {
        return data['isGroupAdmin'] as bool;
      } else {
        return false;
      }
    } else {
      print("Error fetching group admin status: ${response.statusCode}");
      return false;
    }
  }

  Future<bool> _joinGroup(int groupId, {String? password}) async {
    final url = Uri.parse(
      'http://15.164.88.94/groups/$groupId/join?password=${Uri.encodeComponent(password ?? '')}',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final decodedResponseBody = utf8.decode(response.bodyBytes);

    if (response.statusCode == 201) {
      return true;
    } else if (response.statusCode == 401) {
      print("Error: 비밀번호가 틀렸습니다.");
      return false;
    } else {
      print("Error: 서버 응답 에러 발생 (Status Code: ${response.statusCode})");
      print("Response Body: $decodedResponseBody");
      return false;
    }
  }

  void _showPasswordDialog(EntireGroup group) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Center(child: Text("비공개 그룹")),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
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
                OverflowBar(
                  alignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: const Text("취소"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _passwordController.clear();
                        setState(() {
                          _isPasswordIncorrect = false;
                        });
                      },
                    ),
                    TextButton(
                      child: const Text("확인"),
                      onPressed: () async {
                        // 서버로 비밀번호 검증 요청
                        bool joinSuccess = await _joinGroup(
                          group.groupId,
                          password: _passwordController.text,
                        );

                        if (joinSuccess) {
                          Navigator.of(context).pop(); // 다이얼로그 닫기
                          navigateToGroupPage(group.groupId); // 그룹 페이지로 이동
                          _passwordController.clear(); // 비밀번호 필드 초기화
                          setState(() {
                            _isPasswordIncorrect = false;
                          });
                        } else {
                          setState(() {
                            _isPasswordIncorrect = true; // 비밀번호 틀림 표시
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "루틴 그룹",
          style: TextStyle(
              color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8DCCFF),
        actions: [
          IconButton(
              icon: Image.asset("assets/images/search.png",
                  width: 27, height: 27),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const GroupSearchPage()),
                );
              }),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: const Color(0xFFF8F8EF),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Container(
                color: const Color(0xFFF8F8EF),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // 카테고리와 정렬 기준 버튼 추가
                    Container(
                      color: const Color(0xFFF8F8EF),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // Use the spread operator (...) to unpack the map-generated list of widgets
                              ...['전체', '일상', '건강', '자기개발', '자기관리', '기타'].map((category) {
                                bool isSelected = selectedCategory == category;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        selectedCategory = category;
                                      });
                                      fetchGroups(category: category);
                                    },
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(
                                        isSelected ? Colors.white : const Color(0xE8E8E8EF),
                                      ),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        color: getCategoryColor(category),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(), // Convert the map to a list and unpack it

                              //신규, 랭킹 버튼
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedSortType = '신규';
                                        });
                                        fetchGroups(
                                          category: selectedCategory,
                                          sortType: '신규',
                                        );
                                      },
                                      child: Text(
                                        '신규',
                                        style: TextStyle(
                                          color: selectedSortType == '신규'
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedSortType = '랭킹';
                                        });
                                        fetchGroups(
                                          category: selectedCategory,
                                          sortType: '랭킹',
                                        );
                                      },
                                      child: Text(
                                        '랭킹',
                                        style: TextStyle(
                                          color: selectedSortType == '랭킹'
                                              ? Colors.blue
                                              : Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
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
                              margin: const EdgeInsets.all(8.0),
                              color: const Color(0xFFE6F5F8),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
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
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight:
                                                FontWeight.bold,
                                              ),
                                            ),
                                            if (!group.isPublic)
                                              Padding(
                                                padding:
                                                const EdgeInsets.only(
                                                    left: 8.0),
                                                child: Image.asset(
                                                  "assets/images/lock.png",
                                                  color: const Color(
                                                      0xFF8DCCFF),
                                                  width: 20,
                                                  height: 20,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      children: [
                                        const Text("대표 카테고리 "),
                                        Text(group.groupCategory,
                                            style: TextStyle(
                                                color: textColor)),
                                        Expanded(child: Container()),
                                        Align(
                                          alignment:
                                          Alignment.centerRight,
                                          child: Text(
                                              "인원 ${group.joinMemberCount}/${group.maxMemberCount}명"),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            "그룹장 ${group.createdUserNickname}"),
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
  final String description;
  final String createdUserNickname;
  final int joinMemberCount;
  final int maxMemberCount;
  final bool isJoined;
  final bool isPublic;

  EntireGroup({
    required this.groupId,
    required this.groupTitle,
    required this.groupCategory,
    required this.description,
    required this.createdUserNickname,
    required this.joinMemberCount,
    required this.maxMemberCount,
    required this.isJoined,
    required this.isPublic,
  });

  factory EntireGroup.fromJson(Map<String, dynamic> json) {
    return EntireGroup(
      groupId: json['groupId'],
      groupTitle: json['groupTitle'],
      groupCategory: json['groupCategory'],
      description: json['description'],
      createdUserNickname: json['createdUserNickname'],
      joinMemberCount: json['joinMemberCount'],
      maxMemberCount: json['maxMemberCount'],
      isJoined: json['isJoined'],
      isPublic: json['isPublic'],
    );
  }
}
