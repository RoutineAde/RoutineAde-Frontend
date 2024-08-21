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
        preferredSize: const Size.fromHeight(100), // AppBar 높이 설정
        child: Column(
          children: [
            const SizedBox(height: 10),
            AppBar(
              leading: IconButton(
                icon: Image.asset(
                  "assets/images/new-icons/cross-mark.png",
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
        child: ListView(
          padding: const EdgeInsets.fromLTRB(40, 20, 10, 10),
          children: <Widget>[
            Container(
              child: const Text(
                "그룹 관리",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all<Size>(const Size(0, 0)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor:
                WidgetStateProperty.all<Color>(Colors.transparent),
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 210.0), // 왼쪽으로 8.0만큼 패딩을 추가
                child: Text(
                  "그룹 소개/규칙",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
              onPressed: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             const groupIntroRule(widget.groupId)));
              },
            ),
            const SizedBox(
              height: 20,
            ),
            TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all<EdgeInsets>(EdgeInsets.zero),
                minimumSize: WidgetStateProperty.all<Size>(const Size(0, 0)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                overlayColor:
                WidgetStateProperty.all<Color>(Colors.transparent),
              ),
              child: const Padding(
                padding: EdgeInsets.only(right: 235.0), // 왼쪽으로 8.0만큼 패딩을 추가
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