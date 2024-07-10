import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_group/OnClickGroupPage.dart';
import 'package:routine_ade/routine_home/AlarmListPage.dart';
import 'AddRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';
import 'package:routine_ade/routine_home/ModifiedRoutinePage.dart';
import 'RoutineDetail.dart';


// 루틴 데이터 생성
List<Routine> routines = [
  Routine(
    category: "건강",
    name: "헬스장 가서 운동하기" ,
  ),

  Routine(
    category: "자기 개발",
    name: "일기 쓰기" ,
  ),

  Routine(
    category: "일상",
    name: "스트레칭하기" ,
  ),

];

//전체화면 어둡게
class DarkOverlay extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback onTap;

  DarkOverlay({required this.child, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        child,
        if (isDark)
          Positioned.fill(
            child: GestureDetector(
              onTap: onTap, // 클릭 방지용 빈 함수
              child: Container(
                color: Colors.black.withOpacity(0.5), // 어두운 배경색, 투명도 조절 가능
              ),
            ),
          ),
      ],
    );
  }
}

void main() async {
  await initializeDateFormatting();
  runApp(const MyRoutinePage());
}

class MyRoutinePage extends StatefulWidget {
  const MyRoutinePage({super.key});

  @override
  State<MyRoutinePage> createState() => _MyRoutinePageState();
}


class CalendarStyle {
  late final String locale;
}

class _MyRoutinePageState extends State<MyRoutinePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final CalendarWeekController _controller = CalendarWeekController();

  List<bool> _checked = [];

  /*
  bool _checked1 = false;
  bool _checked2 = false;
  bool _checked3 = false;
  bool _checked4 = false;
  bool _checked5 = false;

   */





  bool _isExpanded = false;

  String? _selectedImage;


  /*
  void _showDialog(BuildContext context) {
    showDialog(
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return AlertDialog(                   // 수정, 삭제 다이얼로그
                                                    title: Text(routines[index].name,
                                                      style: TextStyle(fontSize: 24),),
                                                    content: Column(
                                                      mainAxisSize: MainAxisSize.min,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(routines[index].category, style: TextStyle(fontSize: 15, color: Color(0xff6ACBF3)),),
                                                        SizedBox(height: 20),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(builder: (context) => ModifiedRoutinePage()),
                                                            );
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                "assets/images/edit.png",
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              SizedBox(width: 20,),
                                                              Text('수정', style: TextStyle(fontSize: 18),),
                                                            ],
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              routines.removeAt(index);
                                                              //_chekced.removeAt(index);
                                                              Navigator.of(context).pop();
                                                            });
                                                          },
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                "assets/images/delete.png",
                                                                width: 20,
                                                                height: 20,
                                                              ),
                                                              SizedBox(width: 20,),
                                                              Text('삭제', style: TextStyle(fontSize: 18),),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
  }

   */

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showBottomSheet() async {
    final String? selectedImage = await showModalBottomSheet<String>(
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 250,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30,),
                        ),
                        Text(
                          '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월 ${_controller.selectedDate.day}일',
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Image.asset(
                          "assets/images/emotion/happy.png",
                          width: 78,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          Navigator.pop(
                              context, "assets/images/emotion/happy.png");
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          "assets/images/emotion/depressed.png",
                          width: 78,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          Navigator.pop(
                              context, "assets/images/emotion/depressed.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          "assets/images/emotion/sad.png",
                          width: 78,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          Navigator.pop(
                              context, "assets/images/emotion/sad.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),
                      IconButton(
                        icon: Image.asset(
                          "assets/images/emotion/angry.png",
                          width: 78,
                        ),
                        iconSize: 20,
                        onPressed: () {
                          Navigator.pop(
                              context, "assets/images/emotion/angry.png");
                          // 홈 버튼 클릭 시 동작할 코드
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
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
    _checked = List.generate(routines.length, (index) => false);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("기분 추가", style:
                    TextStyle( color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(width: 10),
                    FloatingActionButton(
                      onPressed: _showBottomSheet,
                      backgroundColor: Color(0xffFFB065),
                      child: Image.asset('assets/images/add-emotion.png'),
                      shape: CircleBorder(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("루틴 추가", style: TextStyle( color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                    SizedBox(width: 10),

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
                  ],
                ),
                SizedBox(height: 20),
              ],
              //add 버튼, X버튼
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(""),
                  SizedBox(width: 10),
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    backgroundColor:
                    _isExpanded ? Color(0xffF7C7C7C) : Color(0xffF1E977),
                    child: _isExpanded
                        ? Image.asset('assets/images/cancel.png')
                        : Image.asset('assets/images/add.png'),
                    shape: CircleBorder(),
                  ),
                ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => OnClickGroupPage()),
              );
            },
            child: Container(
              width: 50,
              height: 50,
              child: Image.asset("assets/images/tap-bar/statistics01.png"),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
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
            dayOfWeekStyle: TextStyle(
                color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17),
            dayOfWeek: ['월', '화', '수', '목', '금', '토', '일'],
            dateStyle: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17,),
            todayDateStyle: TextStyle(
              color: Color(0xffFFFFFF), fontWeight: FontWeight.w600, fontSize: 17,
            ),
            todayBackgroundColor: Color(0xffE6E288),
            weekendsStyle: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red,
            ),

            monthViewBuilder: (DateTime time) => Align(
              alignment: FractionalOffset(0.05, 1),
              child: Container(
                child: Row(
                  children: [
                    SizedBox(width: 20,),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                          '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월',
                          //locale: const Locale('ko', 'KR'),
                          //DateFormat.yMMMM().format(time),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.black45,
                              fontWeight: FontWeight.bold,
                              fontSize: 24)),

                    ),
                    SizedBox(width: 220,),
                    IconButton(
                      icon: Image.asset("assets/images/bell.png",
                        width: 30,
                        height: 30,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AlarmListPage()),
                        );
                      },
                    ),


                  ],
                ),
              ),
            ),
          )),

      Expanded(
        child: Container(
          color: Colors.grey[200],
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent, // 구분선을 투명하게 설정
            ),
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
              children: <Widget>[


                ExpansionTile(
                  title: Text(
                    "개인 루틴",
                    style: TextStyle(fontSize: 20),
                  ),
                  children: [
                    SizedBox(height: 10), // 여백 추가
                    SingleChildScrollView(
                      child: Column(
                        children: List.generate(routines.length, (index) {

                          //카테고리에 따라 색상을 반환하는 함수
                          Color getCategoryColor(String category) {
                            switch (category) {
                              case '건강' :
                                return Color(0xff6ACBF3);

                              case '자기 개발' :
                                return Color(0xff7BD7C6);

                              case '일상' :
                                return Color(0xffF5A77B);

                              case '자기 관리' :
                                return Color(0xffC69FEC);

                              case '기타' :
                                return Color(0xffF4A2D8);

                              default :
                                return Colors.black;

                            }
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0), // 컨테이너 사이의 간격 추가
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          SizedBox(width: 6,),
                                          TextButton(
                                            onPressed: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog( // 수정, 삭제 다이얼로그
                                                      title: Text(routines[index].name,
                                                        style: TextStyle(fontSize: 24),),
                                                      content: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(routines[index].category, style: TextStyle(fontSize: 15, color: getCategoryColor(routines[index].category),),),
                                                          SizedBox(height: 20),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(builder: (context) => ModifiedRoutinePage()),
                                                              );
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  "assets/images/edit.png",
                                                                  width: 20,
                                                                  height: 20,
                                                                ),
                                                                SizedBox(width: 20,),
                                                                Text('수정', style: TextStyle(fontSize: 18),),
                                                              ],
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              setState(() {
                                                                routines.removeAt(index);
                                                                //_chekced.removeAt(index);
                                                                Navigator.of(context).pop();
                                                              });
                                                            },
                                                            child: Row(
                                                              children: [
                                                                Image.asset(
                                                                  "assets/images/delete.png",
                                                                  width: 20,
                                                                  height: 20,
                                                                ),
                                                                SizedBox(width: 20,),
                                                                Text('삭제', style: TextStyle(fontSize: 18),),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }
                                                  );
                                            },
                                            child: Text(routines[index].category, style: TextStyle(
                                                color: getCategoryColor(routines[index].category),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18
                                            ),
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 20),
                                          Text(routines[index].name, style: TextStyle(fontSize: 18),),
                                          SizedBox(width: 10),
                                          Image.asset(
                                            "assets/images/bell.png",
                                            width: 20,
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 100),
                                      Transform.scale(
                                        scale: 1.5, // 원하는 크기로 체크박스를 스케일
                                        child: Checkbox(
                                          value: _checked[index],
                                          onChanged: (bool? newValue) {
                                            setState(() {
                                              _checked[index] = newValue!;
                                            });
                                          },
                                          activeColor: Color(0xffE6E288),
                                          checkColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    SizedBox(height: 10),


                  ],
                ),
                /*
                SizedBox(height: 10), // 여백 추가



                ExpansionTile(
                  title: Text(
                    "그룹 취미 부자들",
                    style: TextStyle(fontSize: 20),
                  ),
                  children: [
                    SizedBox(height: 10), // 여백 추가
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0.0, 0, 0),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(width: 6,),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(                   // 수정, 삭제 다이얼로그
                                              title: Text('자기 전 스트레칭',
                                                style: TextStyle(fontSize: 24),),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('자기 관리', style: TextStyle(fontSize: 15, color: Color(0xffC69FEC),),),
                                                  SizedBox(height: 20),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => ModifiedRoutinePage()),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          "assets/images/edit.png",
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                        SizedBox(width: 20,),
                                                        Text('수정', style: TextStyle(fontSize: 18),),
                                                      ],
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          "assets/images/delete.png",
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                        SizedBox(width: 20,),
                                                        Text('삭제', style: TextStyle(fontSize: 18),),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Text("자기 관리", style: TextStyle(
                                        color: Color(0xffC69FEC),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                    ),

                                    ),
                                  )

                                ],
                              )
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 20),
                                  Text("자기 전 스트레칭", style: TextStyle(fontSize: 18),),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    "assets/images/bell.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                              SizedBox(width: 100),
                              Transform.scale(
                                scale: 1.5, // 원하는 크기로 체크박스를 스케일
                                child: Checkbox(
                                  value: _checked3,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _checked3 = newValue!;
                                    });
                                  },
                                  activeColor: Color(0xffE6E288),
                                  checkColor: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),


                SizedBox(height: 10), // 여백 추가
                ExpansionTile(
                  title: Text(
                    "그룹 여고추리반",
                    style: TextStyle(fontSize: 20),
                  ),
                  children: [
                    SizedBox(height: 10), // 여백 추가
                    Container(
                      padding: const EdgeInsets.fromLTRB(0, 0.0, 0, 0),
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: <Widget>[


                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: [
                                  SizedBox(width: 6,),
                                  TextButton(
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(                   // 수정, 삭제 다이얼로그
                                              title: Text('물 마시기',
                                                style: TextStyle(fontSize: 24),),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('일상', style: TextStyle(fontSize: 15, color: Color(0xffF5A77B),),),
                                                  SizedBox(height: 20),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(builder: (context) => ModifiedRoutinePage()),
                                                      );
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          "assets/images/edit.png",
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                        SizedBox(width: 20,),
                                                        Text('수정', style: TextStyle(fontSize: 18),),
                                                      ],
                                                    ),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Image.asset(
                                                          "assets/images/delete.png",
                                                          width: 20,
                                                          height: 20,
                                                        ),
                                                        SizedBox(width: 20,),
                                                        Text('삭제', style: TextStyle(fontSize: 18),),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    child: Text("일상", style: TextStyle(
                                        color: Color(0xffF5A77B),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18
                                    ),

                                    ),
                                  )

                                ],
                              )
                            ],
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  SizedBox(width: 20),
                                  Text("물 마시기", style: TextStyle(fontSize: 18),),
                                  SizedBox(width: 10),
                                  Image.asset(
                                    "assets/images/bell.png",
                                    width: 20,
                                    height: 20,
                                  ),
                                ],
                              ),
                              SizedBox(width: 100),
                              Transform.scale(
                                scale: 1.5, // 원하는 크기로 체크박스를 스케일
                                child: Checkbox(
                                  value: _checked4,
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      _checked4 = newValue!;
                                    });
                                  },
                                  activeColor: Color(0xffE6E288),
                                  checkColor: Colors.white,
                                ),
                              ),

                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                */

                SizedBox(height: 10), // 여백 추가
              ],
            ),
          ),
        ),
      ),

      Container(
          color: Colors.grey[200],
          child: _selectedImage != null
              ? Row(
            //mainAxisAlignment: MainAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
                  child: Column(
                    children: [
                      Text("오늘의 기분", style: TextStyle(fontSize: 18),),
                      SizedBox(height: 10,),
                      Image.asset(
                        _selectedImage!,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70, // 기분 선택했을 때 루틴페이지에 나타나는 기분 이미지 크기
                      ),
                    ],
                  )
              )
            ],
          )
              : Center()),
    ]),
  );
}