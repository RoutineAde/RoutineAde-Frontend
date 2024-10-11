import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:routine_ade/routine_myInfo/MyInfo.dart';
// import 'package:routine_ade/routine_group/GroupType.dart';
// import 'package:routine_ade/routine_group/GroupMainPage.dart';
// import 'package:routine_ade/routine_home/AlarmListPage.dart';
// import 'package:routine_ade/routine_home/ModifiedRoutinePage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:routine_ade/routine_otherUser/OtherUserCalender.dart';
import 'package:routine_ade/routine_otherUser/OtherUserCategory.dart';
import 'package:routine_ade/routine_user/token.dart';
import 'package:routine_ade/routine_statistics/StaticsCalendar.dart';

class OtherUserRoutinePage extends StatefulWidget {
  final int userId;
  final int groupId;

  const OtherUserRoutinePage(
      {required this.userId, required this.groupId, super.key});

  @override
  State<OtherUserRoutinePage> createState() => _OtherUserRoutinePageState();
}

class _OtherUserRoutinePageState extends State<OtherUserRoutinePage>
    with SingleTickerProviderStateMixin {
  Future<RoutineResponse2>? futureRoutineResponse2;
  String selectedDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
  late CalendarWeekController _controller;
  String? userEmotion;
  String? profileImage;
  String? nickname;
  String? intro;

  final bool _isTileExpanded = false;

  late TabController _tabController;
  bool _isExpanded = false;
  String? _selectedImage;

  @override
  void initState() {
    super.initState();
    _controller = CalendarWeekController();

    String todayDate = DateFormat('yyyy.MM.dd').format(DateTime.now());
    // 여기서 widget.userId로 접근해야 함
    futureRoutineResponse2 =
        fetchRoutinesByUserId(widget.userId, widget.groupId, todayDate);
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // bottom:
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.0),
          child: Container(
            color: Colors.white,
            child: const Padding(
              padding: EdgeInsets.only(top: 20.0),
            ),
          ),
        ),
      ),
      // backgroundColor: Colors.white,
      body: FutureBuilder<RoutineResponse2>(
        future: futureRoutineResponse2, // 루틴 데이터를 비동기로 가져옴
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('루틴을 불러오는 중 오류가 발생했습니다: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('루틴 데이터를 찾을 수 없습니다.'));
          }

          // 받은 데이터를 변수에 저장
          final profileImage = snapshot.data?.profileImage ?? '';
          final nickname = snapshot.data?.nickname ?? 'No nickname available';
          final intro = snapshot.data?.intro ?? 'No intro available';
          final userEmotion = snapshot.data?.userEmotion ?? 'null';
          // final personalRoutines = snapshot.data?.personalRoutines ?? [];
          final groupRoutines = snapshot.data?.groupRoutines ?? [];

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: profileImage.isNotEmpty
                          ? NetworkImage(profileImage)
                          : const AssetImage('assets/profile_placeholder.png')
                              as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          intro,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 20),
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: "루틴"),
                    Tab(text: "캘린더"),
                    Tab(text: "카테고리"),
                  ],
                  labelStyle: const TextStyle(fontSize: 18),
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  indicator: const UnderlineTabIndicator(
                    borderSide:
                        BorderSide(width: 3.0, color: Color(0xFF8DCCFF)),
                    insets: EdgeInsets.symmetric(horizontal: 90.0),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        _buildMonthView(),
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFFF8F8EF),
                          child: Center(
                            child: Container(
                              width: 360,
                              height: 70,
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 10),
                                  userEmotion.isNotEmpty &&
                                          getImageEmotion(userEmotion) != null
                                      ? Image.asset(
                                          getImageEmotion(userEmotion)!,
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                        )
                                      : Image.asset(
                                          "assets/images/emotion/no-emotion.png",
                                          width: 50,
                                          height: 50),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
                                        children:
                                            _buildEmotionText(userEmotion),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            color: const Color(0xFFF8F8EF),
                            child: groupRoutines.isEmpty
                                ? const Center(
                                    child: Text(
                                      ' 등록된 루틴이 없습니다.',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.grey),
                                    ),
                                  )
                                : ListView(
                                    padding: const EdgeInsets.fromLTRB(
                                        24, 10, 24, 16),
                                    children: [
                                      // _buildRoutineSection(
                                      //     "개인 루틴", personalRoutines),
                                      const SizedBox(height: 10),
                                      ...groupRoutines.map((group) {
                                        return _buildGroupRoutineSection(group);
                                      }),
                                      const SizedBox(height: 10),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),

                    // 캘린더 탭
                    Otherusercalender(userId: widget.userId), // 캘린더 페이지
                    // 카테고리 탭
                    Otherusercategory(userId: widget.userId), // 카테고리 페이지'
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

// 감정 텍스트를 빌드하는 메서드
  List<TextSpan> _buildEmotionText(String userEmotion) {
    switch (userEmotion) {
      case 'GOOD':
        return [
          const TextSpan(text: '이 날은 기분이 '),
          const TextSpan(
            text: '해피',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow),
          ),
          const TextSpan(text: '한 날이에요')
        ];
      case 'SAD':
        return [
          const TextSpan(text: '이 날은 기분이 '),
          const TextSpan(
            text: '우중충',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          const TextSpan(text: '한 날이에요')
        ];
      case 'OK':
        return [
          const TextSpan(text: '이 날은 기분이 '),
          const TextSpan(
            text: '쏘쏘',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const TextSpan(text: '한 날이에요')
        ];
      case 'ANGRY':
        return [
          const TextSpan(text: '이 날은 기분이 '),
          const TextSpan(
            text: '나쁜',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent),
          ),
          const TextSpan(text: ' 날이에요')
        ];
      default:
        return [
          const TextSpan(
            text: '등록된 기분이 없습니다.',
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
        ];
    }
  }

// 그룹 루틴 섹션 빌드
  Widget _buildGroupRoutineSection(Group2 group) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F5F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 그룹 제목 표시
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Text(
              group.groupTitle,
              style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),

          // 그룹 루틴 카테고리 및 루틴 항목들 표시
          ...group.groupRoutines.map((categoryGroup) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, bottom: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      categoryGroup.routineCategory,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getCategoryColor(categoryGroup.routineCategory),
                      ),
                    ),
                  ),
                ),
                ...categoryGroup.routines
                    .map((routine) => _buildRoutineTile2(routine)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
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

//그룹 루틴
  Widget _buildRoutineTile2(GroupRoutine routine) {
    Color categoryColor = _getCategoryColor(routine.routineCategory);

    // 루틴 이름
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20), // 좌우 여백 조절
        minLeadingWidth: 0,
        leading: const Icon(
          Icons.brightness_1,
          size: 8,
          color: Colors.black,
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              routine.routineTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // const SizedBox(width: 3),
          ],
        ),
        trailing: Transform.scale(
          scale: 1.2, // Checkbox size increased by 1.5 times
          child: Checkbox(
            value: routine.isCompletion,
            onChanged: (bool? value) {
              // if (value != null) {
              //   print("Checkbox changed: $value");
              //   setState(() {
              //     routine.isCompletion = value;
              //   });
              // }
            },
            activeColor: const Color(0xFF8DCCFF),
            checkColor: Colors.white,
            fillColor: WidgetStateProperty.resolveWith<Color>(
                (Set<WidgetState> states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF8DCCFF);
              }
              return Colors.transparent;
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthView() {
    return Align(
      alignment: const FractionalOffset(0.05, 1),
      child: Column(
        children: [
          Container(
            width: double.infinity, // 화면의 양끝까지 채우기
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8), // 상하단 여백 추가
            child: Row(
              children: [
                const SizedBox(width: 20),
                Text(
                  '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월 ${_controller.selectedDate.day}일',
                  style: const TextStyle(
                    color: Colors.black, // 텍스트 색상
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          // const SizedBox(height: 10), 날짜 여백
        ],
      ),
    );
  }
}

//루틴, 감정 조회
Future<RoutineResponse2> fetchRoutinesByUserId(
    int userId, int groupId, String routineDate) async {
  print('사용할 토큰: $token'); // 요청 전에 토큰을 출력하여 확인
  print('API 요청 사용자 ID: $userId'); // 요청할 사용자 ID를 출력하여 확인
  print('요청그룹: $groupId ');

  try {
    final response = await http.get(
      Uri.parse(
          'http://15.164.88.94/groups/$groupId/users/$userId/routines?routineDate=$routineDate'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8', // UTF-8 설정
      },
    );

    print('응답 코드: ${response.statusCode}');
    print('응답 본문: ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      final responseBody = json.decode(utf8.decode(response.bodyBytes));
      print('Parsed data: $responseBody'); // 성공한 경우 응답 데이터 출력
      return RoutineResponse2.fromJson(responseBody);
    } else {
      print(
          'Failed to load routines: ${response.statusCode}'); // 실패한 경우 상태 코드 출력
      print('Response body: ${response.body}'); // 추가로 응답 본문 출력
      throw Exception('Failed to load routines');
    }
  } catch (e) {
    print('Exception occurred: $e');
    throw Exception('Failed to load routines');
  }
}

//기분 조회
String? getImageEmotion(String emotion) {
  switch (emotion) {
    case 'GOOD':
      return 'assets/images/emotion/happy.png';
    case 'OK':
      return 'assets/images/emotion/depressed.png';
    case 'SAD':
      return 'assets/images/emotion/sad.png';
    case 'ANGRY':
      return 'assets/images/emotion/angry.png';
    default:
      return "assets/images/new-icons/김외롭.png"; // 기본 이미지
  }
}

//기분 텍스트
String getTextForEmotion(String emotion) {
  switch (emotion) {
    case 'GOOD':
      return '이 날은 기분이 해피한 날이에요';
    case 'OK':
      return '이 날은 기분이 쏘쏘한 날이에요';
    case 'SAD':
      return '이 날은 기분이 우중충한 날이에요';
    case 'ANGRY':
      return '이 날은 기분이 나쁜 날이에요';
    // case 'null':
    //   return '기분을 추가해보세요!';
    default:
      return '기분을 추가해보세요!'; // 기본 텍스트
  }
}

//루틴, 감정 조회 class
class RoutineResponse2 {
  final int userId;
  final String profileImage;
  final String nickname;
  final String intro;
  // final List<UserRoutineCategory> personalRoutines;
  final List<Group2> groupRoutines; //userGroupInfo
  final String userEmotion;
  // final List<UserRoutineCategory> routines;
  // final List<String> groupRoutineCategories;

  RoutineResponse2({
    required this.userId,
    required this.profileImage,
    required this.nickname,
    required this.intro,
    // required this.personalRoutines,
    required this.groupRoutines,
    required this.userEmotion,
    // required this.routines,
    // required this.groupRoutineCategories,
  });

  factory RoutineResponse2.fromJson(Map<String, dynamic> json) {
    return RoutineResponse2(
      userId: json['userId'] ?? 0, //기본값 설정
      profileImage: json['profileImage'] ?? '', // 한국어로 된 필드명을 사용하여 데이터를 파싱
      nickname: json['nickname'] ?? '기타',
      intro: json['intro'] ?? '기타',
      groupRoutines: (json['userGroupInfo'] as List<dynamic>?)
              ?.map((item) => Group2.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      userEmotion: json['userEmotion'] ?? 'null',
    );
  }
}

//그룹 루틴
class GroupRoutine {
  final int routineId;
  final String routineTitle;
  final String routineCategory;
  bool isCompletion;

  GroupRoutine({
    required this.routineId,
    required this.routineTitle,
    required this.routineCategory,
    this.isCompletion = false,
  });

  factory GroupRoutine.fromJson(Map<String, dynamic> json) {
    return GroupRoutine(
      routineId: json['routineId'] ?? 0,
      routineTitle: json['routineTitle'] ?? '',
      routineCategory: json['routineCategory'] ?? '',
      isCompletion: json['isCompletion'] ?? false,
    );
  }
}

// 루틴 카테고리 그룹
class RoutineCategoryGroup {
  final String routineCategory;
  final List<GroupRoutine> routines;

  RoutineCategoryGroup({
    required this.routineCategory,
    required this.routines,
  });

  factory RoutineCategoryGroup.fromJson(Map<String, dynamic> json) {
    return RoutineCategoryGroup(
      routineCategory: json['routineCategory'] ?? '',
      routines: (json['routines'] as List)
          .map((item) => GroupRoutine.fromJson(item))
          .toList(),
    );
  }
}

// 그룹
class Group2 {
  final int groupId;
  final String groupTitle;
  final List<RoutineCategoryGroup> groupRoutines;

  Group2({
    required this.groupId,
    required this.groupTitle,
    required this.groupRoutines,
  });

  factory Group2.fromJson(Map<String, dynamic> json) {
    return Group2(
      groupId: json['groupId'] ?? 0,
      groupTitle: json['groupTitle'] ?? '',
      groupRoutines: (json['groupRoutines'] as List)
          .map((item) => RoutineCategoryGroup.fromJson(item))
          .toList(),
    );
  }
}
