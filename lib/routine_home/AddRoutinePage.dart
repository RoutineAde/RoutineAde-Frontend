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

class AddRoutinePage extends StatefulWidget {
  const AddRoutinePage({super.key});

  @override
  State<AddRoutinePage> createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends State<AddRoutinePage> {
  //텍스트필드
  final TextEditingController _controller = TextEditingController();
  late final String _token = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE3MjA0MzIzMDYsImV4cCI6MTczNTk4NDMwNiwidXNlcklkIjoxfQ.gVbh87iupFLFR6zo6PcGAIhAiYIRfLWV_wi8e_tnqyM'; // 토큰 입력

  int _currentLength = 0;
  final int _maxLength = 15;

  //요일 선택 리스트
  List<bool> isSelected = [false, false, false, false, false, false, false];
  //카테고리 선택 (한번에 하나만)
  int selectedCategoryIndex = -1;
  List<String> isCategory = ["일상", "건강", "자기개발", "자기관리", "기타"]; //.

  bool _isAlarmOn = false; //알람
  DateTime _selectedDate = DateTime.now(); //선택된 날짜
  List<String> selectedDays =[];

  //날짜 포맷팅
  String get formattedDate => DateFormat('yyyy.MM.dd').format(_selectedDate);

  //텍스트필드
  @override
  void initState() {
    super.initState();
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

// 루틴 추가 API 호출 함수
  void _addRoutine() async {
    //카테고리 선택 여부 확인
    if(selectedCategoryIndex == -1){
      _showDialog("경고", "키테고리를 선택해주세요.");
      return;
    }

    void _addRoutine() async{
      if(selectedCategoryIndex == -1){
        _showDialog("경고", "카테고리를 선택해주세요.");
        return;
      }
      if(_controller.text.isEmpty){
        _showDialog("경고", "루틴 이름을 입력해주세요.");
        return;
      }
      if(selectedDays.isEmpty){
        _showDialog("경고", "반복 요일을 선택해주세요.");
        return;
      }
    }
    // 요청 바디 준비
    final url = Uri.parse('http://15.164.88.94:8080/routines');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };
    final body = jsonEncode({
      'routineTitle':_controller.text,
      'routineCategory': _getCategoryFromIndex(selectedCategoryIndex),
      'isAlarmEnabled': _isAlarmOn,
      'startDate': formattedDate,
      'repeatDays': selectedDays,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showDialog('성공', '루틴이 성공적으로 추가되었습니다.');
      } else {
        _showDialog('오류', '루틴 추가에 실패했습니다: ${response.body}');
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
    if (index < 0 || index >= isCategory.length) {
      return '';
    }
    return isCategory[index];
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: AppBar(
            backgroundColor: Colors.grey[200],
            title: Text(
              '루틴 추가',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        body: SingleChildScrollView(
          //스크롤 가능하게 변경  bottom overflowed 오류 해결
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
                      borderSide: BorderSide.none, //밑줄 없앰
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
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
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
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10)),
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
                                ? Color(0xffE6E288)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _getWeekdayName(i),
                            style: TextStyle(
                              color:
                              isSelected[i] ? Colors.white : Colors.black,
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
                        SizedBox(width: 10),
                        Text(
                          "카테고리",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
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
                            margin: EdgeInsets.only(
                              bottom: 10,
                            ),
                            decoration: BoxDecoration(
                              color: selectedCategoryIndex == index
                                  ? Color(0xffE6E288)
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
                padding:
                EdgeInsets.only(top: 10, bottom: 10, left: 10, right: 10),
                margin: EdgeInsets.only(top: 30, left: 10, right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/bell.png",
                      width: 30,
                      height: 30,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("알림",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: EdgeInsets.only(left: 228),
                    ),
                    CupertinoSwitch(
                      value: _isAlarmOn,
                      activeColor: Color(0xffE6E288),
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
                padding:
                EdgeInsets.only(top: 20, bottom: 15, left: 10, right: 10),
                margin: EdgeInsets.only(top: 30, left: 10, right: 10),
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
                    SizedBox(width: 10),
                    Text(
                      "루틴 시작일",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(left: 130),
                    ),
                    //시작일 선택
                    GestureDetector(
                      onTap: () async {
                        DateTime? pickeDate = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickeDate != null && pickeDate != _selectedDate) {
                          setState(() {
                            _selectedDate = pickeDate;
                          });
                        }
                      },
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          formattedDate,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //루틴 추가 버튼
              Container(
                width: 400,
                height: 80,
                padding: EdgeInsets.only(top: 30),
                child: ElevatedButton(
                  onPressed: _addRoutine,
                  style: ButtonStyle(
                    backgroundColor:
                    MaterialStateProperty.all<Color>(Color(0xffE6E288)),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), //테두리 둥글게
                        // side: BorderSide(color: Colors.grey), //테두리 색 변경
                      ),
                    ),
                  ),
                  child: Text(
                    "루틴 추가하기",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20), //버튼 아래 여백
            ],
          ),
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