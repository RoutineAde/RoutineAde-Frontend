import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'AddRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
// import 'package:shelf/shelf_io.dart' as io;
// import 'package:shelf_swagger_ui/shelf_swagger_ui.dart';

void main() async {

  await initializeDateFormatting();
  runApp(const MyRoutinePage());
}

class MyRoutinePage extends StatefulWidget {
  const MyRoutinePage({super.key});

  @override
  State<MyRoutinePage> createState() => _MyRoutinePageState();
  

}

class CalendarStyle{
  late final String locale;

}

class _MyRoutinePageState extends State<MyRoutinePage>
    with SingleTickerProviderStateMixin{
  late TabController _tabController;
  int _selectedIndex = 0;
  final CalendarWeekController _controller = CalendarWeekController();

  bool _checked1 = false;
  bool _checked2 = false;
  bool _checked3 = false;
  bool _checked4 = false;

  bool _isExpanded = false;

  String? _selectedImage;

  List<Map<String, dynamic>> _routineData = [];


  void _showDialog(BuildContext context) {
    showDialog(context: context,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.all(0),
            title: Text('헬스장 가서 운동하기'),
            content: Text('건강'),
            actions: <Widget>[
              ElevatedButton(onPressed: () => Navigator.of(context).pop(),
                  child: Text('edit')),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(),
                  child: Text('delete'))
            ],
          );
        });
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showBottomSheet() async{
    final String? selectedImage = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: Column(
              children: [
                Expanded(
                  child: Text(
                    '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월 ${_controller.selectedDate.day}일',
                    style: TextStyle(fontSize: 30),
                  ),

                ),
                Container(

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      IconButton(
                        icon: Image.asset("assets/images/emotion/happy.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context,"assets/images/emotion/happy.png");

                        },
                      ),

                      IconButton(
                        icon: Image.asset("assets/images/emotion/depressed.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "assets/images/emotion/depressed.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),

                      IconButton(
                        icon: Image.asset("assets/images/emotion/sad.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "assets/images/emotion/sad.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),

                      IconButton(
                        icon: Image.asset("assets/images/emotion/angry.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "assets/images/emotion/angry.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),
                    ],
                  ),

                ),

                Container(
                  margin: EdgeInsets.all(30),
                ),
              ],
            ),
          );
        });
    if (selectedImage != null) {
      setState(() {
        _selectedImage = selectedImage;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(
            () => setState(() => _selectedIndex = _tabController.index));

  }



  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    //추가 버튼 
    floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isExpanded) ...[
                  SizedBox(height: 20), //기분 추가 버튼
                  FloatingActionButton(
                    onPressed:
                      _showBottomSheet,
                    
                    backgroundColor: Color(0xffFeae6a8),
                  child: Image.asset('assets/images/add-emotion.png'),
                  shape: CircleBorder(),
                  ),
                  SizedBox(height: 20),
                  
                  //루틴 추가 버튼
                  FloatingActionButton(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return const AddRoutinePage();
                          },
                        ));      
                    },  
                    backgroundColor: Color(0xffF1E977),
                  child: Image.asset('assets/images/add.png'),
                  shape: CircleBorder(),
                  ),
                  SizedBox(height: 20),
                ],
                //add 버튼, X버튼
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  backgroundColor: _isExpanded? Color(0xffF7C7C7C): Color(0xffF1E977),
                  child: _isExpanded
                  ? Image.asset('assets/images/cancel.png')
                  : Image.asset('assets/images/add.png'),
                  shape: CircleBorder(),
                ),
              ],
            ),
          ),
        ],
      ),

    appBar: PreferredSize(
      child: AppBar(),
      preferredSize: Size.fromHeight(0),
    ),
    //bottomBar
    bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/routine02.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupMainPage()),
                );
              },
             
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/group01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 통계 버튼 클릭 시 동작할 코드
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/statistics01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 더보기 버튼 클릭 시 동작할 코드
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/more01.png"),
              ),
            ),
          ],
        ),
      ),


    body: Column(children: [
      Container(
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1)
          ]),
          child: CalendarWeek(
            controller: _controller,
            height: 130,
            showMonth: true,
            minDate: DateTime.now().add(
              Duration(days: -367),
            ),
            maxDate: DateTime.now().add(
              Duration(days: 365),
            ),

            onDatePressed: (DateTime datetime) {
              // Do something
              setState(() {});
            },
            onDateLongPressed: (DateTime datetime) {
              // Do something
            },
            onWeekChanged: () {
              // Do something
            },
            dayOfWeekStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),

            dayOfWeek: ['월', '화', '수', '목', '금', '토', '일'],

            dateStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),



            monthViewBuilder: (DateTime time) => Align(
              alignment: FractionalOffset(0.05, 1),
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                      locale: const Locale('ko', 'KR'),
                      DateFormat.yMMMM().format(time),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 28)
                  )),
            ),
          )),

      Expanded(
        child: Container(
          color: Colors.grey[200],
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
            children: <Widget>[
              ExpansionTile(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                    height:100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment(-0.9, 1.0),
                          child: Row(
                            children: [
                              SizedBox(width: 15,),
                              Text("건강", style: TextStyle(
                                color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22
                              )),
                              SizedBox(width: 15,),
                              GestureDetector(
                                onTap: () => _showDialog(context),
                                child: Icon(Icons.edit, size: 30,),
                              )

                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CheckboxListTile(
                              title: Row(
                                children: <Widget>[
                                  Text("헬스장 가서 운동하기"),
                                  SizedBox(width: 10,),
                                  Image.asset("assets/images/bell.png", width: 20, height: 20,),
                                ],
                              ),
                              value: _checked1, onChanged: (bool ? newValue) {
                              setState(() {
                                _checked1 = newValue!;
                              });
                            },
                            )
                          ],
                        )
                      ],
                    ),
                  ),


                  Container(
                    margin: EdgeInsets.all(10.0),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                    height:100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment(-0.9, 1.0),
                          child: Text("자기 개발", style: TextStyle(
                              color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22
                          ),),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CheckboxListTile(
                              title: Text("일기 쓰기"),
                              value: _checked2, onChanged: (bool ? newValue) {
                              setState(() {
                                _checked2 = newValue!;
                              });
                            },
                            )
                          ],
                        )
                      ],
                    ),
                  ),


                ],
                title: Text("개인 루틴", style: TextStyle(
                    fontSize: 24
                ),),
              ),


              Container(
                margin: EdgeInsets.all(10.0),
              ),

              ExpansionTile(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 0),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                    height:100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment(-0.9, 1.0),
                          child: Text("건강", style: TextStyle(
                              color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22
                          ),),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CheckboxListTile(
                              title: Text("헬스장 가서 운동하기"),
                              value: _checked3, onChanged: (bool ? newValue) {
                              setState(() {
                                _checked3 = newValue!;
                              });
                            },
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                ],
                title: Text("그룹 취미 부자들", style: TextStyle(
                    fontSize: 24
                ),),
              ),
              Container(
                margin: EdgeInsets.all(10.0),
              ),
              ExpansionTile(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10, bottom: 0),
                  ),

                  Container(
                    padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                    height:100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment(-0.9, 1.0),
                          child: Text("건강", style: TextStyle(
                              color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22
                          ),),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CheckboxListTile(
                              title: Text("헬스장 가서 운동하기"),
                              value: _checked4, onChanged: (bool ? newValue) {
                              setState(() {
                                _checked4 = newValue!;
                              });
                            },
                            )
                          ],
                        )
                      ],
                    ),
                  ),

                ],
                title: Text("그룹 여고추리반", style: TextStyle(
                    fontSize: 24
                ),),
              ),


              Container(
                margin: EdgeInsets.all(10.0),
              ),
            ],
          ),
        ),
      ),

      Container(
          color: Colors.grey[200],
  child: _selectedImage != null
          ? Row(
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
        child: Image.asset(
          _selectedImage!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        ),
      )
    ],
  )
      :Center()

        ),
    ]),
  );

}