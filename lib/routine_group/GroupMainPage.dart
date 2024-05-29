import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';

class GroupMainPage extends StatefulWidget {
  @override
  _GroupMainPageState createState() => _GroupMainPageState();
  }

  class _GroupMainPageState extends State<GroupMainPage>{
    bool isExpanded = false;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('내 그룹', 
        style: TextStyle(
          color: Colors.black, 
          fontSize: 25, 
          fontWeight: FontWeight.bold ),),
          centerTitle: true,
          backgroundColor: Colors.grey[200],
      ), 
      body: Container(
        color:Colors.grey[200],
        child: Center(
          child: Text("그룹을 추가하세요")), //루틴그룹 내용 표시
      ),


      //바텀 네비게이션 바
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyRoutinePage()),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/routine01.png"),
              ),
            ),
            GestureDetector(
              onTap: () {
                // 그룹 버튼 클릭 시 동작할 코드
              },
              child: Container(
                width: 50,
                height: 50,
                child: Image.asset("assets/images/tap-bar/group02.png"),
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
      //add 버튼
    floatingActionButton: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isExpanded) ...[
                  SizedBox(height: 20), //그룹 추가 버튼
                  FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context){
                          return  GroupRoutinePage();
                        },
                        ));
                    },
                    backgroundColor: Color(0xffF87c3ff),
                  child: Image.asset('assets/images/group-list.png'),
                  shape: CircleBorder(),
                  ),
                  SizedBox(height: 20),
                  
                  //그룹 루틴 추가 버튼
                  FloatingActionButton(
                    onPressed: () {
                      // Second button action code
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
                      isExpanded = !isExpanded;
                    });
                  },
                  backgroundColor: isExpanded? Color(0xffF7C7C7C): Color(0xffF1E977),
                  child: isExpanded
                  ? Image.asset('assets/images/cancel.png')
                  : Image.asset('assets/images/add.png'),
                  shape: CircleBorder(),
                ),
              ],
            ),
          ),
        ],
      ),
    
    );
    
  }
  }