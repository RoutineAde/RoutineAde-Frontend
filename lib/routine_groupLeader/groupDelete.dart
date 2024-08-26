import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_user/token.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';

class groupDelete extends StatefulWidget {
  final int groupId;
  const groupDelete({super.key, required this.groupId});

  @override
  State<groupDelete> createState() => _groupDeleteState();
}

class _groupDeleteState extends State<groupDelete> {
  bool _isChecked = false;

  // 그룹 삭제 API 호출 함수
  Future<void> _deleteGroup() async {
    if (!_isChecked) {
      _showDialog("경고", "모든 정보를 삭제하는 것에 동의해 주세요.");
      return;
    }

    final url = Uri.parse('http://15.164.88.94:8080/groups/${widget.groupId}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // 토큰 추가
    };

    try {
      final response = await http.delete(url, headers: headers);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (ctx) => const GroupMainPage()),
        );
      } else if (response.statusCode == 404) {
        _showDialog('삭제 지연', '그룹 삭제 작업이 지연되고 있습니다. 잠시 후 다시 확인해 주세요.');
      } else {
        _showDialog('오류', '그룹 삭제에 실패했습니다: ${response.body}');
      }
    } catch (e) {
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
        padding: const EdgeInsets.fromLTRB(40, 20, 10, 10),
        child: ListView(
          children: <Widget>[
            const Text(
              "그룹을 삭제하면,",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "● 그룹 내 루틴, 채팅 등 사용자가 설정한 모든 정보가 완전히 삭제되고, 다시 복구할 수 없습니다.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "● 루틴 그룹 방에서 나가게 되고, 모든 정보가 즉시 삭제되어, 해당 그룹에 다시 가입하거나 복구할 수 없습니다.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "● 루틴원을 모두 그룹 방에서 내보냅니다.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),
            ),
            const SizedBox(
              height: 270,
            ),
            // 체크박스를 추가
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
                  activeColor: _isChecked
                      ? const Color(0xffA1D1F9)
                      : Colors.grey, // 체크박스 색상
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0), // 원형으로 만들기
                  ),
                ),
                const Text("모든 정보를 삭제하는 것에 동의합니다.",
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            Container(
              width: 400,
              height: 80,
              padding: const EdgeInsets.fromLTRB(0, 30, 30, 0),
              child: ElevatedButton(
                onPressed:
                _isChecked ? _deleteGroup : null, // 체크박스가 체크되어야만 버튼 활성화
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    _isChecked ? const Color(0xffA1D1F9) : Colors.grey,
                  ),
                  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: const Text(
                  "그룹 삭제",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}