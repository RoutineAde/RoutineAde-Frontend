import 'package:flutter/material.dart';
import 'package:routine_ade/routine_group/GroupRoutinePage.dart';

//그룹 소개 표시 다이얼로그 함수
void showGroupDetailsDialog(BuildContext context, Group group) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        title: Text(group.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("루틴장: ${group.leader}"),
            Text("인원수 : ${group.membersCount}"),
            Text("그룹코드: ${group.groupCode}"),
            Divider(
              height: 100,
              thickness: 0.5,
              color: Colors.black,
            ),
            Text("테스트용 입니다."),
            // 다른 정보도 추가
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
            },
            child: Text('취소'),
          ),
        ],
      );
    },
  );
}
