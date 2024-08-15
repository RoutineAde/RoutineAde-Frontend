import 'package:flutter/material.dart';
import 'package:routine_ade/routine_group/groupIntroRule.dart';

class groupManagement extends StatefulWidget {
  const groupManagement({super.key});

  @override
  State<groupManagement> createState() => _groupManagementState();

}



class _groupManagementState extends State<groupManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100), // AppBar 높이 설정
        child: Column(
          children: [
            SizedBox(height: 10),
            AppBar(
              leading: IconButton(
                icon: Image.asset("assets/images/new-icons/cross-mark.png",
                  width: 30,
                  height: 30,
                ),
                onPressed: () {
                  Navigator.pop(context); // 현재 화면 닫기
                },
              ),
            ),
          ],
        ),
      ),

      body: Expanded(
        child:  ListView(
          padding: EdgeInsets.fromLTRB(40, 20, 10, 10),
          children: <Widget>[
            Container(
              child: Text("그룹 관리", style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(height: 20,),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                minimumSize: MaterialStateProperty.all<Size>(Size(0, 0)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 210.0), // 왼쪽으로 8.0만큼 패딩을 추가
                child: Text(
                  "그룹 소개/규칙",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => groupIntroRule()));
              },
            ),

            SizedBox(height: 20,),
            TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                minimumSize: MaterialStateProperty.all<Size>(Size(0, 0)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
              ),
              child: Padding(
                padding: const EdgeInsets.only(right: 235.0), // 왼쪽으로 8.0만큼 패딩을 추가
                child: Text(
                  "그룹 나가기",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),


          ],
        ),

      ),
    );
  }
}

