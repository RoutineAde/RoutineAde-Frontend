import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'GroupType.dart';
import 'package:routine_ade/routine_user/token.dart';

class AddGroupPage extends StatefulWidget {
  const AddGroupPage({super.key});

  @override
  State<AddGroupPage> createState() => _AddGroupPageState();
}

class _AddGroupPageState extends State<AddGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _groupDescriptionController =
  TextEditingController();
  int _selectedMemberCount = 0;

  // 카테고리 선택 (한번에 하나만)
  int selectedCategoryIndex = -1;
  List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"];

  @override
  void dispose() {
    _groupNameController.dispose();
    _passwordController.dispose();
    _groupDescriptionController.dispose();
    super.dispose();
  }

  // 그룹 추가 API 호출 함수
  void _addGroup() async {
    // 카테고리 선택 여부 확인
    if (selectedCategoryIndex == -1) {
      _showDialog("경고", "카테고리를 선택해주세요.");
      return;
    }
    if (_groupNameController.text.isEmpty) {
      _showDialog("경고", "그룹 이름을 입력해주세요.");
      return;
    }
    if (_groupDescriptionController.text.isEmpty) {
      _showDialog("경고", "그룹 소개를 입력해주세요.");
      return;
    }

    // 비밀번호 값 설정
    final groupPassword =
    _passwordController.text.isEmpty ? null : _passwordController.text;

    // 요청 바디 준비
    final url = Uri.parse('http://15.164.88.94:8080/groups');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      'groupTitle': _groupNameController.text,
      'groupPassword': groupPassword,
      'groupCategory': _getCategoryFromIndex(selectedCategoryIndex),
      'maxMember': _selectedMemberCount,
      'description': _groupDescriptionController.text,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showDialog('성공', '그룹이 성공적으로 추가되었습니다.');
      } else {
        _showDialog('오류', '그룹 추가에 실패했습니다: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
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
              },
            ),
          ],
        );
      },
    );
  }

  String _getCategoryFromIndex(int index) {
    if (index < 0 || index >= isCategory.length) {
      return '';
    }
    return isCategory[index];
  }

  Future<void> _selectMemberCount() async {
    final int? selectedCount = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '모집인원 선택',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 23),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: 29,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text('${index + 2}명'),
                  onTap: () {
                    Navigator.of(context).pop(index + 2);
                  },
                );
              },
            ),
          ),
        );
      },
    );

    if (selectedCount != null) {
      setState(() {
        _selectedMemberCount = selectedCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF8F8EF),
        appBar: AppBar(
          backgroundColor: const Color(0xFF8DCCFF),
          title: const Text(
            '그룹 만들기',
            style: TextStyle(
              fontSize: 25,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 10,
              ),
              Container(
                color: const Color(0xFFF8F8EF),
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _groupNameController,
                      maxLength: 10,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '그룹명을 입력해주세요',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 15), // 세로 여백 조정
                        counterText: "", // 글자 수 표시 없애기
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                      decoration: const InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        labelText: '비밀번호(선택사항)',
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 15), // 세로 여백 조정
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      padding:
                      const EdgeInsets.only(left: 10, right: 10, top: 10),
                      margin: const EdgeInsets.only(top: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Row(
                            children: [
                              Text(
                                "대표 카테고리",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              5,
                                  (index) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCategoryIndex = index;
                                  });
                                },
                                child: Container(
                                  width: 70,
                                  height: 35,
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: selectedCategoryIndex == index
                                        ? const Color(0xffB4DDFF)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    isCategory[index],
                                    style: TextStyle(
                                      color: selectedCategoryIndex == index
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      margin: const EdgeInsets.only(top: 20),
                      color: Colors.white,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "모집인원",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _selectMemberCount,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                '$_selectedMemberCount명',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFFF8F8EF),
                padding: const EdgeInsets.only(
                    top: 20, bottom: 15, left: 10, right: 10),
                child: TextField(
                  controller: _groupDescriptionController,
                  maxLines: 6,
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: '그룹 소개를 입력해주세요',
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 90),
              Container(
                width: 400,
                height: 80,
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _addGroup,
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStateProperty.all<Color>(const Color(0xFFB4DDFF)),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                  child: const Text(
                    "그룹 추가하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // 버튼 아래 여백
            ],
          ),
        ),
      ),
    );
  }
}