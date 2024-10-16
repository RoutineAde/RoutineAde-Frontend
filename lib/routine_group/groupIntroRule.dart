import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_groupLeader/groupEdit.dart';
import 'package:routine_ade/routine_user/token.dart';

// GroupInfo 모델 클래스 정의
class GroupInfo {
  final String groupTitle;
  final String groupDescription;
  final int groupId;

  GroupInfo({
    required this.groupTitle,
    required this.groupDescription,
    required this.groupId,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    final groupInfo = json['groupInfo'] as Map<String, dynamic>;
    print("Parsing JSON: $json");
    return GroupInfo(
      groupTitle: groupInfo['groupTitle'] ?? "No title",
      groupDescription: groupInfo['description'] ?? "No description",
      groupId: groupInfo['groupId'] is int ? groupInfo['groupId'] : 0,
    );
  }
}

// API 응답을 처리하는 모델 클래스 정의
class ApiResponse {
  final GroupInfo groupInfo;
  final List<dynamic> groupMembers;
  final List<dynamic> groupRoutines;

  ApiResponse({
    required this.groupInfo,
    required this.groupMembers,
    required this.groupRoutines,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      groupInfo: GroupInfo.fromJson(json),
      groupMembers: json['groupMembers'] as List<dynamic>,
      groupRoutines: json['groupRoutines'] as List<dynamic>,
    );
  }
}

class GroupIntroRule extends StatefulWidget {
  final int groupId;

  const GroupIntroRule({required this.groupId, super.key});

  @override
  State<GroupIntroRule> createState() => _GroupIntroRuleState();
}

class _GroupIntroRuleState extends State<GroupIntroRule> {
  late Future<ApiResponse> futureGroupInfo;
  @override
  void initState() {
    super.initState();
    futureGroupInfo = fetchGroupInfo(widget.groupId);
  }

  Future<ApiResponse> fetchGroupInfo(int groupId) async {
    final url = Uri.parse("http://15.164.88.94/groups/$groupId");

    // 요청 전 로그 추가
    print("Requesting group info for groupId: $groupId");
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    // 응답 후 로그 추가
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      print("Decoded response: $decodedResponse");
      final data = jsonDecode(decodedResponse);
      return ApiResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      // 404 오류 처리
      print("그룹이 존재하지 않습니다.");
      throw Exception("그룹을 찾을 수 없습니다. 유효한 그룹 ID를 사용해 주세요.");
    } else {
      // 기타 오류 처리
      print(
          "Failed to load group information. Status code: ${response.statusCode}");
      throw Exception("Failed to load group information");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '그룹 소개/규칙',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 30),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => groupEdit(groupId: widget.groupId),
            //       ),
            //     );
            //   },
            //   child: Image.asset(
            //     '',
            //     width: 24,
            //     height: 24,
            //   ),
            // ),
          ],
        ),
        backgroundColor: const Color(0xffA1D1F9),
      ),
      body: FutureBuilder<ApiResponse>(
        future: futureGroupInfo,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No group info available'));
          } else {
            final groupInfo = snapshot.data!.groupInfo;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "그룹 아이디: ${groupInfo.groupId}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "그룹 소개",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    groupInfo.groupDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}