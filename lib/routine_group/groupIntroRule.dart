import 'package:flutter/material.dart';

class groupIntroRule extends StatefulWidget {
  const groupIntroRule({super.key});

  @override
  State<groupIntroRule> createState() => _groupIntroRuleState();

}



class _groupIntroRuleState extends State<groupIntroRule> {
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
              title: Text('그룹 소개/규칙', style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(height: 20.0,),
          ],
        )
      ),
      body: Expanded(
        child:  ListView(
          padding: EdgeInsets.fromLTRB(40, 20, 10, 10),
          children: <Widget>[
            Container(
              child: Text("그룹 소개", style: TextStyle(
                fontSize: 18,
              ),),
            ),
            SizedBox(height: 20,),
            Container(
              child: Text("* 목표 *", style: TextStyle(
                fontSize: 18,
              ),),
            ),

          ],
        ),
      ),
    );
  }
}

