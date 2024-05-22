import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:routine_ade/MyRoutinePage.dart';

class AddRoutinePage extends StatefulWidget {
  const AddRoutinePage({super.key});

  @override
  State<AddRoutinePage> createState() => _AddRoutinePageState();
}

class _AddRoutinePageState extends State<AddRoutinePage> {
  final TextEditingController _controller = TextEditingController();
  int _currentLength = 0;
  final int _maxLength = 15;

  bool _isAlarmOn = false;

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(50),
        child: AppBar(
          backgroundColor: Colors.grey[200],

          title: Text('루틴 추가',
            style: TextStyle(
                fontSize: 30,
                color: Colors.black, fontWeight: FontWeight.bold
            ),

          ),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, size: 20,),

            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),



      body: Column(children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.grey[200],
            child: ListView(
              padding: EdgeInsets.fromLTRB(24, 10, 24, 16),
              children: <Widget>[
              Container(
              height: 90,
              margin: EdgeInsets.only(left: 0, right: 0, top: 15),
              padding: EdgeInsets.only(left: 20, right: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),

              ),
              child: Padding(
                child: TextField(
                  controller: _controller,
                  maxLength: _maxLength,
                  style: TextStyle(
                      color: Colors.black, fontSize: 20
                  ),
                  decoration: InputDecoration(
                    hintText: '루틴 이름을 입력해주세요',
                    counterText: '$_currentLength/$_maxLength',
                  ),
                ),
                padding: EdgeInsets.fromLTRB(5, 20, 5, 10),
              ),
          ),

                Container(
                  margin: EdgeInsets.all(10.0),
                ),

                Container(
                  height:110,
                  margin: EdgeInsets.only(left: 0, right: 0, top: 15),
                  padding: EdgeInsets.only(left: 15, top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),

                  ),
                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment(-1.0, 1.0),
                        child: Text("반복 요일", style: TextStyle(
                          color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20
                        ),),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 5, 0),
                        padding: EdgeInsets.all(0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              child: Text('월', style: TextStyle(fontSize: 18),),
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(100.0)
                                  )
                                )
                              ),
                            ),


                            IconButton(
                              icon: Icon(Icons.circle, size: 33,),
                              onPressed: () {},
                            ),
                            SizedBox(width: 0,),

                            IconButton(
                              icon: Icon(Icons.circle, size: 33,),
                              onPressed: () {},
                            ),
                            SizedBox(width: 0,),

                            IconButton(
                              icon: Icon(Icons.circle, size: 33,),
                              onPressed: () {},
                            ),
                            SizedBox(width: 0,),

                            IconButton(
                              icon: Icon(Icons.circle, size: 33,),
                              onPressed: () {},
                            ),
                            SizedBox(width: 0,),

                            IconButton(
                              icon: Icon(Icons.circle, size: 33,),
                              onPressed: () {},
                            ),
                            SizedBox(width: 0,),

                            IconButton(
                              icon: Icon(Icons.circle, size: 33,),
                              onPressed: () {},
                            ),
                            SizedBox(width: 0,),
                          ],
                        ),

                      )
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(10.0),
                ),


                Container(
                  height: 180,
                  margin: EdgeInsets.only(left: 0, right: 0, top: 15),
                  padding: EdgeInsets.only(left: 15, top: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),

                  child: Column(
                    children: <Widget>[
                      Align(
                        alignment: Alignment(-1.0, 1.0),
                        child: Row(
                          children: [
                            Image.asset("imgs/category.png", width: 40, height: 40,),
                            SizedBox(width: 10,),
                            Text("카테고리", style: TextStyle(
                              color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20
                            ),)
                          ],
                        ),

                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(0, 10, 5, 0),
                        padding: EdgeInsets.all(0),
                        child: Wrap(
                          //mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton(
                              child: Text('일상', style: TextStyle(fontSize: 18),),
                              onPressed: () {},
                            ),
                            SizedBox(width: 20,),

                            OutlinedButton(
                              child: Text('건강', style: TextStyle(fontSize: 18),),
                              onPressed: () {},
                            ),
                            SizedBox(width: 20,),

                            OutlinedButton(
                              child: Text('자기개발', style: TextStyle(fontSize: 18),),
                              onPressed: () {},
                            ),
                            SizedBox(width: 20,),

                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            ),

                            OutlinedButton(
                              child: Text('자기관리', style: TextStyle(fontSize: 18),),
                              onPressed: () {},
                            ),
                            SizedBox(width: 20,),

                            OutlinedButton(
                              child: Text('기타', style: TextStyle(fontSize: 18),),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                Container(
                  margin: EdgeInsets.all(10.0),
                ),


                Container(
                  height: 70,
                  margin: EdgeInsets.only(left: 0, right: 0, top: 15),
                  padding: EdgeInsets.only(left: 15, top: 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("imgs/bell.png", width: 40, height: 40,),
                      SizedBox(width: 10,),
                      Text(
                        '알림',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20),

                      ),
                      Container(
                        margin: EdgeInsets.all(90.0),
                      ),
                      CupertinoSwitch(
                        value: _isAlarmOn,
                        onChanged: (value) {
                          setState(() {
                            _isAlarmOn = value;
                          });
                        },
                      ),
                      SizedBox(width: 10,),
                    ],
                  ),

                ),

                Container(
                  margin: EdgeInsets.all(10.0),
                ),


                Container(
                  height: 70,
                  margin: EdgeInsets.only(left: 0, right: 0, top: 15),
                  padding: EdgeInsets.only(left: 15, top: 0),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.asset("imgs/calendar.png", width: 40, height: 40,),
                      SizedBox(width: 10,),
                      Text(
                        '루틴 시작일',
                        style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 20),

                      ),
                      Container(
                        margin: EdgeInsets.all(90.0),
                      ),




                      //SizedBox(width: 10,),
                    ],
                  ),

                ),







            ],
          ),
          /*
          height: 70,
          margin: EdgeInsets.only(left: 20, right: 20, top: 15),
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(5),

          ),
          child: Padding(
            child: TextField(
              style: TextStyle(
                color: Colors.black, fontSize: 20
              ),
              decoration: InputDecoration(
                hintText: '루틴 이름을 입력해주세요',
              ),
            ),
            padding: EdgeInsets.fromLTRB(10, 20, 10, 10),
          ),


           */
        ),






        )],),

    );
  }
}
