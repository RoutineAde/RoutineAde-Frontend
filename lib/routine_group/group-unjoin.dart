import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_user/token.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';

class Groupunjoin extends StatefulWidget {
  final int groupId;
  const Groupunjoin({super.key, required this.groupId});

  @override
  State<Groupunjoin> createState() => _GroupunjoinState();
}

class _GroupunjoinState extends State<Groupunjoin> {
  bool _isChecked = false;
  bool isLoading = false;

  // 그룹 삭제 API 호출 함수
  Future<void> _deleteGroup() async {
    if (!_isChecked) {
      _showDialog("경고", "모든 정보를 삭제하는 것에 동의해 주세요.");
      return;
    }

    setState(() {
      isLoading = true; // 로딩 상태 시작
    });

    final url =
        Uri.parse('http://15.164.88.94:8080/groups/${widget.groupId}/un-join');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 토큰 추가
    };

    try {
      final response = await http.delete(url, headers: headers);

      setState(() {
        isLoading = false; // 로딩 상태 종료
      });

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const GroupMainPage()),
        );
      } else if (response.statusCode == 404) {
        _showDialog('탈퇴 지연', '그룹 탈퇴 작업이 지연되고 있습니다. 잠시 후 다시 확인해 주세요.');
      } else {
        _showDialog('오류', '그룹 탈퇴에 실패했습니다: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false; // 로딩 상태 종료
      });
      _showDialog('오류', '오류가 발생했습니다: $e');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                if (title == '성공') {
                  Navigator.pop(context); // 그룹 삭제 성공 시 이전 화면으로 돌아감
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100),
        child: Column(
          children: [
            const SizedBox(height: 10),
            AppBar(
              leading: IconButton(
                icon: Image.asset(
                  "assets/images/new-icons/cross-mark.png",
                  width: 30,
                  height: 30,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  const Text(
                    "그룹을 탈퇴하면,",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "● 루틴 그룹 방에서 나가게 되고, 모든 정보가 즉시 삭제되어, 해당 그룹에 다시 가입 가능하나 이전 기록들을 복구할 수 없습니다.",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 400),
                  Row(
                    children: [
                      Checkbox(
                        value: _isChecked,
                        onChanged: (bool? value) {
                          setState(() {
                            _isChecked = value ?? false;
                          });
                        },
                        checkColor: Colors.white,
                        activeColor:
                            _isChecked ? const Color(0xffB4DDFF) : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      const Text("그룹을 탈퇴합니다.", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  // const SizedBox(height: 90),
                  Container(
                    width: 400,
                    height: 90,
                    padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                    child: ElevatedButton(
                      onPressed: _isChecked ? _deleteGroup : null,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          _isChecked ? const Color(0xffB4DDFF) : Colors.grey,
                        ),
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      child: const Text(
                        "그룹 탈퇴",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
