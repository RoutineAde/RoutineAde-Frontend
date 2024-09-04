import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; //날짜 포맷팅 init 패키지
import 'package:http/http.dart' as http;
import 'MyRoutinePage.dart';
import 'package:routine_ade/routine_user/token.dart';

class ModifiedroutinePage extends StatefulWidget {
  final int routineId;
  final String routineTitle;
  final String? routineCategory;
  final bool isAlarmEnabled;
  final String startDate;
  final List<String> repeatDays;

  const ModifiedroutinePage({
    super.key,
    required this.routineId,
    required this.routineTitle,
    this.routineCategory,
    required this.isAlarmEnabled,
    required this.startDate,
    required this.repeatDays,
  });

  @override
  State<ModifiedroutinePage> createState() => _ModifiedRoutinePageState();
}

class _ModifiedRoutinePageState extends State<ModifiedroutinePage> {
  final TextEditingController _controller = TextEditingController();
  // late final String _token = '$token';

  int _currentLength = 0;
  final int _maxLength = 15;

  List<bool> isSelected = [false, false, false, false, false, false, false];
  int selectedCategoryIndex = -1;
  List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"];

  bool _isAlarmOn = false;
  DateTime _selectedDate = DateTime.now();
  List<String> selectedDays = [];

  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _controller.text = widget.routineTitle;
    _currentLength = widget.routineTitle.length;
    selectedCategoryIndex = _getIndexFromCategory(widget.routineCategory ?? '');
    _isAlarmOn = widget.isAlarmEnabled;
    _selectedDate = _parseDate(widget.startDate);
    selectedDays = List<String>.from(widget.repeatDays);

    for (var day in selectedDays) {
      int index = _getDayIndex(day);
      if (index != -1) {
        isSelected[index] = true;
      }
    }

    _controller.addListener(() {
      setState(() {
        _currentLength = _controller.text.length;
      });
    });
  }

  DateTime _parseDate(String date) {
    try {
      if (date.contains('.')) {
        return DateFormat('yyyy.MM.dd').parse(date);
      }
      return DateTime.parse(date);
    } catch (e) {
      return DateTime.now();
    }
  }

  int _getIndexFromCategory(String category) {
    return isCategory.indexOf(category);
  }

  int _getDayIndex(String day) {
    switch (day) {
      case '월':
        return 0;
      case '화':
        return 1;
      case '수':
        return 2;
      case '목':
        return 3;
      case '금':
        return 4;
      case '토':
        return 5;
      case '일':
        return 6;
      default:
        return -1;
    }
  }

  void _ModifiedRoutine() async {
    final url =
        Uri.parse('http://15.164.88.94:8080/routines/${widget.routineId}');
    //   'routineTitle=${Uri.encodeComponent(_controller.text)}&'
    //   'routineCategory=${Uri.encodeComponent(_getCategoryFromIndex(selectedCategoryIndex))}&'
    //   'isAlarmEnabled=$_isAlarmOn&'
    //   'startDate=${Uri.encodeComponent(formattedDate)}&'
    //   'repeatDays=${Uri.encodeComponent(selectedDays.join(','))}'
    // );

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'routineTitle': _controller.text,
      'routineCategory': _getCategoryFromIndex(selectedCategoryIndex),
      'isAlarmEnabled': _isAlarmOn,
      'startDate': formattedDate,
      'repeatDays': selectedDays,
    });

    try {
      final response = await http.put(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showDialog('성공', '수정완료');
      } else {
        _showDialog('오류', '수정에 실패했습니다: ${response.body}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8EF),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          backgroundColor: const Color(0xFF8DCCFF),
          title: const Text(
            '루틴 수정',
            style: TextStyle(
                fontSize: 25, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8EF),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _controller,
                maxLength: _maxLength,
                style: const TextStyle(color: Colors.black, fontSize: 18),
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  labelText: '루틴 이름을 입력해주세요',
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 10,
              ),
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "반복요일",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10)),
              ),
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  for (int i = 0; i < 7; i++)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isSelected[i] = !isSelected[i];
                          if (isSelected[i]) {
                            selectedDays.add(_getWeekdayName(i));
                          } else {
                            selectedDays.remove(_getWeekdayName(i));
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected[i]
                              ? const Color(0xFFB4DDFF)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getWeekdayName(i),
                          style: TextStyle(
                            color: isSelected[i] ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            //카테고리
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Image.asset(
                        "assets/images/category.png",
                        width: 30,
                        height: 30,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "카테고리",
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
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          decoration: BoxDecoration(
                            color: selectedCategoryIndex == index
                                ? const Color(0xFFB4DDFF)
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
                                    : Colors.grey),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //알림 설정
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.only(
                  top: 10, bottom: 10, left: 10, right: 10),
              margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/bell.png",
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  const Text("알림",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.only(left: 228),
                  ),
                  CupertinoSwitch(
                    value: _isAlarmOn,
                    activeColor: const Color(0xFFB4DDFF),
                    onChanged: (value) {
                      setState(() {
                        _isAlarmOn = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 15, left: 10, right: 10),
              margin: const EdgeInsets.only(top: 30, left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/calendar.png",
                    width: 30,
                    height: 30,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "루틴 시작일",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 130),
                  ),
                  //시작일 선택
                  GestureDetector(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null && pickedDate != _selectedDate) {
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        formattedDate,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 120),
            //루틴 추가 버튼
            Container(
              width: 400,
              height: 90,
              padding: const EdgeInsets.only(top: 30),
              child: ElevatedButton(
                onPressed: _ModifiedRoutine,
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
                  "수정하기",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _getWeekdayName(int index) {
    switch (index) {
      case 0:
        return '월';
      case 1:
        return '화';
      case 2:
        return '수';
      case 3:
        return '목';
      case 4:
        return '금';
      case 5:
        return '토';
      case 6:
        return '일';
      default:
        return '';
    }
  }
}
