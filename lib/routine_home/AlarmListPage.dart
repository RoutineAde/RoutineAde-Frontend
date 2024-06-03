import 'package:flutter/material.dart';

class AlarmListPage extends StatefulWidget {
  const AlarmListPage({super.key});

  @override
  State<AlarmListPage> createState() => _AlarmListPageState();

}



class _AlarmListPageState extends State<AlarmListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // AppBar 높이 설정
        child: Column(
          children: [
            SizedBox(height: 10,),
            AppBar(
              centerTitle: true,
              title: Text('알림', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(height: 20.0,),
            Container(
              height: 1.0,
              color: Colors.grey,
            )
          ],
        )
      ),
      body: Expanded(
        child:  ListView(
          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          children: <Widget>[
            ListTile(
              title: Wrap(
                children: [
                  Container(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Text("30분 이상 걷기 할 시간이에요!", style: TextStyle(
                        fontSize:18,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[

                Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 0),
                  child: Column(
                    children: <Widget>[


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Text("건강", style: TextStyle(
                                color: Colors.blueAccent, fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),),
                              SizedBox(width: 20,),
                              Text("2024.05.25", style: TextStyle(
                                color: Colors.grey, fontSize: 17,
                              ),),

                            ],
                          ),


                        ],
                      ),



                      SizedBox(height: 30,),






                    ],
                  ),
                )
              ],
            ),

            Divider(),
            SizedBox(height: 10,),


            ListTile(
              title: Wrap(
                children: [
                  Container(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Text("일기 쓸 시간이에요!", style: TextStyle(
                        fontSize:18,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[

                Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 0),
                  child: Column(
                    children: <Widget>[


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Text("자기 개발", style: TextStyle(
                                color: Color.fromARGB(255, 68, 252, 255), fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),),
                              SizedBox(width: 20,),
                              Text("2024.05.25", style: TextStyle(
                                color: Colors.grey, fontSize: 17,
                              ),),

                            ],
                          ),


                        ],
                      ),



                      SizedBox(height: 20,),




                    ],
                  ),
                )
              ],
            ),


            Divider(),
            SizedBox(height: 10,),


            ListTile(
              title: Wrap(
                children: [
                  Container(
                    child: Padding(
                      padding: EdgeInsets.zero,
                      child: Text("스트레칭 할 시간이에요!", style: TextStyle(
                        fontSize:18,),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: <Widget>[

                Container(
                  padding: EdgeInsets.fromLTRB(20.0, 0.0, 0, 0),
                  child: Column(
                    children: <Widget>[


                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              Text("자기 관리", style: TextStyle(
                                color: Color.fromARGB(255, 226, 131, 247), fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),),
                              SizedBox(width: 20,),
                              Text("2024.05.25", style: TextStyle(
                                color: Colors.grey, fontSize: 17,
                              ),),

                            ],
                          ),


                        ],
                      ),



                      SizedBox(height: 20,),




                    ],
                  ),
                )
              ],
            ),










          ],
        ),
      ),
    );
  }
}

