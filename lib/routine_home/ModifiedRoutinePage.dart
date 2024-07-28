import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'MyRoutinePage.dart';

class ModifiedroutinePage extends StatefulWidget {
  static const List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"];

  final int routineId;
  final String routineTitle;
  final String? routineCategory;
  final bool isAlarmEnabled;
  final String startDate;
  final List<String> repeatDays;

  const ModifiedroutinePage({
    required this.routineId,
    required this.routineTitle,
    this.routineCategory,
    required this.isAlarmEnabled,
    required this.startDate,
    required this.repeatDays,
    Key? key,
  }) : super(key: key);

  @override
  State<ModifiedroutinePage> createState() => _ModifiedRoutinePageState();
}

class _ModifiedRoutinePageState extends State<ModifiedroutinePage> {
  final TextEditingController _controller = TextEditingController();
  late String _token;

  late int _currentLength;
  final int _maxLength = 15;
  late int selectedCategoryIndex;
  late bool _isAlarmOn;
  late DateTime _selectedDate;
  late List<String> selectedDays;
  List<bool> isSelected = [false, false, false, false, false, false, false];

  @override
  void initState() {
    super.initState();
    _token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjA0MzIzMDYsImV4cCI6MTczNTk4NDMwNiwidXNlcklkIjoxfQ.gVbh87iupFLFR6zo6PcGAIhAiYIRfLWV_wi8e_tnqyM';
    _controller.text = widget.routineTitle;
    _currentLength = widget.routineTitle.length;
    selectedCategoryIndex = _getIndexFromCategory(widget.routineCategory ?? '');
    _isAlarmOn = widget.isAlarmEnabled;
    _selectedDate = widget.startDate.isNotEmpty ? DateTime.parse(widget.startDate) : DateTime.now();
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _editRoutine() async {
    final url = Uri.parse('http://15.164.88.94:8080/routines/${widget.routineId}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjEwMzkzMDEsImV4cCI6MTczNjU5MTMwMSwidXNlcklkIjoyfQ.XLthojYmD3dA4TSeXv_JY7DYIjoaMRHB7OLx9-l2rvw',
    };
    final body = jsonEncode({
      'routineTitle': _controller.text,
      'routineCategory': _getCategoryFromIndex(selectedCategoryIndex),
      'isAlarmEnabled': _isAlarmOn,
      'startDate': formattedDate,
      'repeatDays': selectedDays,
    });

    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    try {
      final response = await http.put(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showDialog('성공', '루틴이 성공적으로 수정되었습니다.');
      } else {
        _showDialog('오류', '루틴 수정에 실패했습니다: ${response.body}');
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
              child: Text('확인'),
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
    switch (index) {
      case 0:
        return '일상';
      case 1:
        return '건강';
      case 2:
        return '자기개발';
      case 3:
        return '자기관리';
      case 4:
        return '기타';
      default:
        return '';
    }
  }

  int _getIndexFromCategory(String? category) {
    if (category == null) {
      return 4; // 기본 카테고리는 "기타"
    }
    switch (category) {
      case '일상':
        return 0;
      case '건강':
        return 1;
      case '자기개발':
        return 2;
      case '자기관리':
        return 3;
      case '기타':
        return 4;
      default:
        return 4;
    }
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

  String _getWeekdayAbbreviation(int index) {
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

  // String _getWeekdayName(int index) {
  //   switch (index) {
  //     case 0:
  //       return '월';
  //     case 1:
  //       return '화';
  //     case 2:
  //       return '수';
  //     case 3:
  //       return '목';
  //     case 4:
  //       return '금';
  //     case 5:
  //       return '토';
  //     case 6:
  //       return '일';
  //     default:
  //       return '';
  //   }
  // }

  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.grey[200],
        title: Text(
          '루틴 수정',
          style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _controller,
                maxLength: _maxLength,
                style: TextStyle(color: Colors.black, fontSize: 18),
                decoration: InputDecoration(
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Row(
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
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10)),
              ),
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
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
                            selectedDays.add(_getWeekdayAbbreviation(i));
                          } else {
                            selectedDays.remove(_getWeekdayAbbreviation(i));
                          }
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected[i] ? Color(0xffE6E288) : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _getWeekdayAbbreviation(i),
                          style: TextStyle(
                            color: isSelected[i] ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // 카테고리
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: Row(
                children: [
                  Text(
                    '카테고리',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<int>(
                      value: selectedCategoryIndex,
                      items: ModifiedroutinePage.isCategory.asMap().entries.map((entry) {
                        int index = entry.key;
                        String value = entry.value;
                        return DropdownMenuItem<int>(
                          value: index,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (int? newIndex) {
                        if (newIndex != null) {
                          setState(() {
                            selectedCategoryIndex = newIndex;
                          });
                        }
                      },
                      isExpanded: true,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Text(
                    '알림',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoSwitch(
                        value: _isAlarmOn,
                        onChanged: (bool value) {
                          setState(() {
                            _isAlarmOn = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              margin: const EdgeInsets.only(left: 10, right: 10),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '시작 날짜',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  ListTile(
                    title: Text(formattedDate),
                    trailing: Icon(Icons.calendar_today),
                    onTap: _pickStartDate,
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 10),
              margin: const EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '반복 요일',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  ToggleButtons(
                    children: List.generate(7, (index) {
                      return Text(_getWeekdayAbbreviation(index));
                    }),
                    isSelected: isSelected,
                    onPressed: (int index) {
                      setState(() {
                        isSelected[index] = !isSelected[index];
                        if (isSelected[index]) {
                          selectedDays.add(_getWeekdayAbbreviation(index));
                        } else {
                          selectedDays.remove(_getWeekdayAbbreviation(index));
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _editRoutine,
              child: Text('루틴 수정하기'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}