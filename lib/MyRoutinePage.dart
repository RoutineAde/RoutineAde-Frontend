import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'AddRoutinePage.dart';

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
                        icon: Image.asset("imgs/happy.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "imgs/happy.png");

                        },
                      ),

                      IconButton(
                        icon: Image.asset("imgs/depressed.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "imgs/depressed.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),

                      IconButton(
                        icon: Image.asset("imgs/sad.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "imgs/sad.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),

                      IconButton(
                        icon: Image.asset("imgs/angry.png", width: 78,),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.pop(context, "imgs/angry.png");
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
    floatingActionButton: Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        if (_isExpanded)
          Positioned(
            bottom: 90,
            right: 16,
            child: Column(
              children: [
                FloatingActionButton(
                  onPressed: _showBottomSheet,
                  // Action for first button


                  child: Image.asset(
                    'imgs/add-emotion.png',
                    fit: BoxFit.cover,
                    width: 78.0,
                    height: 78.0,
                  ),
                  shape: CircleBorder(),

                ),
                SizedBox(height: 20),
                FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const AddRoutinePage();
                      },
                    ));
                  },

                  child: Image.asset(
                    'imgs/add.png',
                    fit: BoxFit.cover,
                    width: 78.0,
                    height: 78.0,
                  ),
                  shape: CircleBorder(),

                ),
              ],
            ),
          ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _toggleExpand,
            child: Icon(_isExpanded? Icons.close : Icons.add, color: Colors.white,),
            backgroundColor: Color(0xffF1E977),
            shape: CircleBorder(),
          ),
        ),
      ],
    ),

    appBar: PreferredSize(
      child: AppBar(),
      preferredSize: Size.fromHeight(0),
    ),
    bottomNavigationBar: BottomAppBar(
      color: Colors.white,
      child: Expanded(
        child: Row(
          children: [
            IconButton(
              icon: Image.asset("imgs/routine02.png", width: 78,),
              iconSize: 10,
              onPressed: () {

                // 홈 버튼 클릭 시 동작할 코드
              },
            ),
            IconButton(
              icon: Image.asset("imgs/group01.png", width: 78,),
              iconSize: 10,
              onPressed: () {

                // 그룹 버튼 클릭 시 동작할 코드
              },
            ),
            IconButton(
              icon: Image.asset("imgs/statistics01.png", width: 78,),
              iconSize: 10,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return const AddRoutinePage();
                  },
                ));
                // 통계 버튼 클릭 시 동작할 코드
              },
            ),
            IconButton(
              icon: Image.asset("imgs/more01.png", width: 78,),
              iconSize: 10,
              onPressed: () {
                // 더보기 버튼 클릭 시 동작할 코드
              },
            ),
          ],
        ),

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
              Duration(days: -370),
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
                          child: Text("건강", style: TextStyle(
                              color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 22
                          ),),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CheckboxListTile(
                              title: Row(
                                children: <Widget>[
                                  Text("헬스장 가서 운동하기"),
                                  SizedBox(width: 10,),
                                  Image.asset("imgs/bell.png", width: 20, height: 20,),
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

      Expanded(
        child: Container(
          color: Colors.grey[200],
  child: _selectedImage != null
  ? Center(
  child: Container(
  padding: EdgeInsets.all(8),
  child: Image.asset(
  _selectedImage!,
  fit: BoxFit.cover,
  width: 100,  // 이미지의 너비
  height: 100, // 이미지의 높이
  ),
  ),
  )
  :Center(

          ),
        ),
      ),








    ]),
  );

}