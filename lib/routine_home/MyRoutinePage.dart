import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_calendar_week/flutter_calendar_week.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'AddRoutinePage.dart';
import 'package:routine_ade/routine_group/ChatScreen.dart';
import 'package:routine_ade/routine_group/GroupMainPage.dart';
import 'package:routine_ade/routine_group/OnClickGroupPage.dart';
import 'package:routine_ade/routine_home/AlarmListPage.dart';
import 'package:routine_ade/routine_home/ModifiedRoutinePage.dart';
void main() async {
  await initializeDateFormatting();
  runApp(const MyRoutinePage());
}

class MyRoutinePage extends StatefulWidget {
  const MyRoutinePage({super.key});

  @override
  State<MyRoutinePage> createState() => _MyRoutinePageState();
}

class _MyRoutinePageState extends State<MyRoutinePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CalendarWeekController _controller = CalendarWeekController();
  bool _isExpanded = false;
  String? _selectedImage;

  List<Routine> routines = [
    Routine(category: "건강", name: "헬스장 가서 운동하기"),
    Routine(category: "자기 개발", name: "일기 쓰기"),
    Routine(category: "일상", name: "스트레칭하기"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showBottomSheet() async {
    final String? selectedImage = await showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheetContent();
      },
    );

    if (selectedImage != null) {
      setState(() {
        _selectedImage = selectedImage;
      });
    }
  }

  Widget _buildBottomSheetContent() {
    return Container(
      height: 250,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Text(
              '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월 ${_controller.selectedDate.day}일',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEmotionIcon("assets/images/emotion/happy.png"),
              _buildEmotionIcon("assets/images/emotion/depressed.png"),
              _buildEmotionIcon("assets/images/emotion/sad.png"),
              _buildEmotionIcon("assets/images/emotion/angry.png"),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmotionIcon(String asset) {
    return IconButton(
      icon: Image.asset(asset, width: 78),
      onPressed: () {
        Navigator.pop(context, asset);
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    floatingActionButton: _buildFloatingActionButton(),
    appBar: PreferredSize(
      child: AppBar(),
      preferredSize: Size.fromHeight(0),
    ),
    bottomNavigationBar: _buildBottomAppBar(),
    body: Column(
      children: [
        _buildCalendarWeek(),
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: _buildRoutineList(),
          ),
        ),
      ],
    ),
  );

  Widget _buildFloatingActionButton() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 10, right: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isExpanded) ...[
                _buildFABRow("기분 추가", _showBottomSheet, 'assets/images/add-emotion.png'),
                SizedBox(height: 20),
                _buildFABRow("루틴 추가", () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddRoutinePage()));
                }, 'assets/images/add.png'),
                SizedBox(height: 20),
              ],
              _buildMainFAB(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFABRow(String text, VoidCallback onPressed, String asset) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(text, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        SizedBox(width: 10),
        FloatingActionButton(
          onPressed: onPressed,
          backgroundColor: Color(0xffF1E977),
          child: Image.asset(asset),
          shape: CircleBorder(),
        ),
      ],
    );
  }

  Widget _buildMainFAB() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(""),
        SizedBox(width: 10),
        FloatingActionButton(
          onPressed: _toggleExpand,
          backgroundColor: _isExpanded ? Color(0xffF7C7C7C) : Color(0xffF1E977),
          child: Image.asset(_isExpanded ? 'assets/images/cancel.png' : 'assets/images/add.png'),
          shape: CircleBorder(),
        ),
      ],
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomAppBarItem("assets/images/tap-bar/routine02.png"),
          _buildBottomAppBarItem("assets/images/tap-bar/group01.png", GroupMainPage()),
          _buildBottomAppBarItem("assets/images/tap-bar/statistics01.png", OnClickGroupPage()),
          _buildBottomAppBarItem("assets/images/tap-bar/more01.png", ChatScreen()),
        ],
      ),
    );
  }

  Widget _buildBottomAppBarItem(String asset, [Widget? page]) {
    return GestureDetector(
      onTap: () {
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => page));
        }
      },
      child: Container(
        width: 50,
        height: 50,
        child: Image.asset(asset),
      ),
    );
  }

  Widget _buildCalendarWeek() {
    return Container(
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, spreadRadius: 1)
      ]),
      child: CalendarWeek(
        controller: _controller,
        height: 130,
        showMonth: true,
        minDate: DateTime.now().add(Duration(days: -367)),
        maxDate: DateTime.now().add(Duration(days: 365)),
        onDatePressed: (DateTime datetime) => setState(() {}),
        dayOfWeekStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17),
        dayOfWeek: ['월', '화', '수', '목', '금', '토', '일'],
        dateStyle: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 17),
        todayDateStyle: TextStyle(color: Color(0xffFFFFFF), fontWeight: FontWeight.w600, fontSize: 17),
        todayBackgroundColor: Color(0xffE6E288),
        weekendsStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.red),
        monthViewBuilder: (DateTime time) => _buildMonthView(),
      ),
    );
  }

  Widget _buildMonthView() {
    return Align(
      alignment: FractionalOffset(0.05, 1),
      child: Row(
        children: [
          SizedBox(width: 20),
          Text(
            '${_controller.selectedDate.year}년 ${_controller.selectedDate.month}월',
            style: TextStyle(color: Colors.black45, fontWeight: FontWeight.bold, fontSize: 24),
          ),
          Spacer(),
          IconButton(
            icon: Image.asset("assets/images/bell.png", width: 30, height: 30),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => AlarmListPage()));
            },
          ),
        ],
      ),
    );
  }


  Widget _buildRoutineList() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
            children: <Widget>[
              SizedBox(height: 10,), //여백 추가
              Theme(
                data: Theme.of(context).copyWith(
                  dividerColor: Colors.transparent,
                ),
                child: ExpansionTile(
                  title: Text("개인 루틴", style: TextStyle(fontSize: 20)),
                  children: routines.map((routine) => _buildRoutineTile(routine)).toList(),
                ),
              ),
              SizedBox(height: 10,), //여백추가
            ],
          ),
        ),
        //기분추가
        if(_selectedImage!=null)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[200],
            child:Column(
              children:[
                Text("오늘의 기분", style:TextStyle(fontSize: 18)),
                SizedBox(height: 10,),
                Image.asset(
                  _selectedImage!,
                  fit:BoxFit.cover,
                  width: 70,
                  height: 70,
                ),
              ],
            ),
          ),
      ],

    );
  }
  Widget _buildRoutineTile(Routine routine) {
    Color categoryColor;

    // 카테고리 색상
    switch(routine.category){
      case "건강":
        categoryColor=Color(0xff6ACBF3);
        break;
      case "자기 개발":
        categoryColor=Color(0xff7BD7C6);
        break;
      case "일상":
        categoryColor=Color(0xffF5A77B);
        break;
      case "자기 관리":
        categoryColor=Color(0xffC69FEC);
        break;
      default:
        categoryColor=Color(0xffF4A2D8);
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10,),
          // 카테고리 텍스트
          Container(
            padding: EdgeInsets.only(left: 13), // 왼쪽에 10의 간격 추가
            child:Text(
              routine.category,
              style:TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          // 루틴 이름
          ListTile(
            title: Text(routine.name, style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Checkbox(
              value: routine.isChecked,
              onChanged: (bool? value) {
                setState(() {
                  routine.isChecked = value!;
                });
              },
            ),
            onTap: () => _showDialog(context, routine),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, Routine routine) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(routine.name),
          content: Text(routine.category),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModifiedRoutinePage()),
                );
              },
              child: Text('수정'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  routines.remove(routine);
                });
                Navigator.of(context).pop();
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}

class Routine {
  final String category;
  final String name;
  bool isChecked;

  Routine({required this.category, required this.name, this.isChecked = false});
}