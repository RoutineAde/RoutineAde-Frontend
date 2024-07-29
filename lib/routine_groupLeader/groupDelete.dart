import 'package:flutter/material.dart';
import 'package:routine_ade/routine_group/groupIntroRule.dart';

class groupDelete extends StatefulWidget {
  const groupDelete({super.key});

  @override
  State<groupDelete> createState() => _groupDeleteState();

}



class _groupDeleteState extends State<groupDelete> {

  bool _isChecked = false; // 체크박스의 상태를 관리하는 변수

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
              child: Text("그룹 루틴을 삭제하면,", style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.bold,
              ),),
            ),
            SizedBox(height: 20,),
            Text("● 그룹 내 루틴, 채팅 등 사용자가 설정한 모든 정보가 완전히 삭제되고, 다시 복구할 수 없습니다.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),),

            SizedBox(height: 20,),
            Text("● 루틴 그룹 방에서 나가게 되고, 모든 정보가 즉시 삭제되어, 해당 그룹에 다시 가입하거나 복구할 수 없습니다.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),),

            SizedBox(height: 20,),
            Text("● 루틴원을 모두 그룹 방에서 내보냅니다.",
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),),

            SizedBox(height: 270,),

            // 체크박스를 추가
            Container(

              padding: EdgeInsets.fromLTRB(0, 30, 20, 0),
              child: Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                    checkColor: Colors.white, // 체크 색상
                    activeColor: _isChecked ? Color(0xffE6E288) : Colors.grey, // 체크박스 색상
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0), // 원형으로 만들기
                    ),
                  ),
                  //SizedBox(width: 10),
                  Text("모든 정보를 삭제하는 것에 동의합니다.", style: TextStyle(fontSize: 16)),

                ],
              ),
            ),


            Container(
              width: 400,
              height: 80,
              padding: EdgeInsets.fromLTRB(0, 30, 30, 0),
              child: ElevatedButton(
                onPressed: _isChecked ? () {
                  Navigator.pop(context);
                } : null, // 체크박스가 체크되어야만 버튼 활성화
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    _isChecked ? Color(0xffE6E288) : Colors.grey, // 버튼 색상 조정
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                child: Text(
                  "그룹 삭제",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),



          ],
        ),


      ),
    );
  }
}

