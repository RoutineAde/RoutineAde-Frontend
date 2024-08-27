import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../routine_groupLeader/glOnClickGroupPage.dart';
import 'GroupRoutinePage.dart';
import 'package:routine_ade/routine_user/token.dart';
import 'OnClickGroupPage.dart';

class GroupSearchPage extends StatefulWidget {
  const GroupSearchPage({super.key});

  @override
  _GroupSearchPageState createState() => _GroupSearchPageState();
}

class _GroupSearchPageState extends State<GroupSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<EntireGroup> allGroups = [];
  List<EntireGroup> filteredGroups = [];
  bool _isPasswordIncorrect = false;
  bool _isLoading = false;
  bool searchByGroupName = true;
  bool _hasSearched = false; //검색 수행 여부

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  Future<void> fetchGroups({bool loadMore = false}) async {
    setState(() {
      _isLoading = true;
      allGroups.clear();
    });

    final url = Uri.parse(
        'http://15.164.88.94:8080/groups?groupCategory=%EC%A0%84%EC%B2%B4');

    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
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

  void _sortGroupsByGroupIdDescending() {
    filteredGroups.sort((a, b) => b.groupId.compareTo(a.groupId));
  }

  void filterGroups(String query) {
    setState(() {
      _hasSearched = query.isNotEmpty; // 검색어가 있으면 검색된 것으로 간주
      if (query.isNotEmpty) {
        filteredGroups = allGroups.where((group) {
          if (searchByGroupName) {
            return group.groupTitle.toLowerCase().contains(query.toLowerCase());
          } else {
            return group.groupId.toString().contains(query);
          }
        }).toList();
      } else {
        // filteredGroups = allGroups;
        filteredGroups = [];
      }
      _sortGroupsByGroupIdDescending(); // 필터 후 정렬 유지
    });
  }

  void toggleSearchBy() {
    setState(() {
      searchByGroupName = !searchByGroupName;
      _searchController.clear();
      filterGroups('');
    });
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
                    const Text("루틴장 ",
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
              ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
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
                  TextButton(
                    child:
                        const Text("취소", style: TextStyle(color: Colors.grey)),
                    onPressed: () {
                      Navigator.of(context).pop();
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
          builder: (context) => OnClickGroupPage(
            groupId: groupId,
          ),
        ),
      );
    }
  }

  Future<bool> fetchIsGroupAdmin(int groupId) async {
    final url = Uri.parse('http://15.164.88.94:8080/groups/$groupId');
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
      'http://15.164.88.94:8080/groups/$groupId/join?password=${Uri.encodeComponent(password ?? '')}',
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
                ButtonBar(
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
          "그룹 검색",
          style: TextStyle(
              color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF8DCCFF),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ToggleButtons(
                          isSelected: [searchByGroupName, !searchByGroupName],
                          onPressed: (int index) {
                            toggleSearchBy();
                          },
                          color: Colors.grey, //선택되지 않았을 때 글자 색
                          selectedColor: Colors.white, //선택 글자 색
                          fillColor: const Color(0xFF8DCCFF), // 선택 배경
                          borderRadius: BorderRadius.circular(10),
                          constraints: const BoxConstraints(
                              minHeight: 40.0, maxWidth: 90.0),
                          borderWidth: 0,
                          borderColor: Colors.grey,
                          selectedBorderColor: Colors.transparent, // 선택된 테두리 제거
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text('그룹명',
                                  style: TextStyle(
                                    color: searchByGroupName
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Text('그룹 코드',
                                  style: TextStyle(
                                    color: !searchByGroupName
                                        ? Colors.white
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: searchByGroupName
                                  ? '그룹명을 입력해주세요'
                                  : '그룹 코드를 입력해주세요',
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () {
                                  filterGroups(_searchController.text);
                                },
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onChanged: (value) {
                              filterGroups(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _hasSearched
                            ? ListView.builder(
                                itemCount: filteredGroups.length,
                                itemBuilder: (context, index) {
                                  final group = filteredGroups[index];
                                  Color textColor =
                                      getCategoryColor(group.groupCategory); //
                                  return InkWell(
                                    onTap: () {
                                      _showGroupDialog(
                                          group); // Show group details when tapped
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.all(8.0),
                                      color: const Color(
                                          0xFFE6F5F8), // Card background color
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                            const EdgeInsets
                                                                .only(
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
                                                Expanded(
                                                    child:
                                                        Container()), // Spacer to push text to the right
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    "루틴장 ${group.createdUserNickname}"),
                                                Text("그룹코드 ${group.groupId}"),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : const Center(child: Text("")),
                  ),
                ],
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
  final String description;
  final String groupCategory;
  final String createdUserNickname;
  final int maxMemberCount;
  final int joinMemberCount;
  final bool isPublic;
  final bool isJoined;

  EntireGroup({
    required this.groupId,
    required this.groupTitle,
    required this.description,
    required this.groupCategory,
    required this.createdUserNickname,
    required this.maxMemberCount,
    required this.joinMemberCount,
    required this.isPublic,
    required this.isJoined,
  });

  factory EntireGroup.fromJson(Map<String, dynamic> json) {
    return EntireGroup(
      groupId: json['groupId'] ?? 0,
      groupTitle: json['groupTitle'] ?? 'Unknown',
      description: json['description'],
      groupCategory: json['groupCategory'] ?? '기타',
      createdUserNickname: json['createdUserNickname'] ?? 'Unknown',
      maxMemberCount: json['maxMemberCount'] ?? 0,
      joinMemberCount: json['joinMemberCount'] ?? 0,
      isPublic: json['isPublic'] ?? true,
      isJoined: json['isJoined'] ?? true,
    );
  }
}
