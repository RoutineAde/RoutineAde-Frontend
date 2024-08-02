// import 'package:flutter/material.dart';
// import 'package:routine_ade/routine_group/GroupRoutinePage.dart';
// import 'package:routine_ade/routine_group/GroupType.dart';
// import 'package:routine_ade/routine_group/GroupMainPage.dart';
// import 'package:routine_ade/routine_group/OnClickGroupPage.dart';


// //카테고리 색상
// Color getCategoryColor(String category) {
//   switch (category) {
//     case "전체":
//       return Colors.black;
//     case "일상":
//       return Color(0xff5A77B);
//     case "건강":
//       return Color(0xff6ACBF3);
//     case "자기개발":
//       return const Color(0xff7BD7C6);
//     case "자기관리":
//       return const Color(0xffC69FEC);
//     case "기타":
//       return Color(0xffF4A2D8);
//     default:
//       return Colors.black;
//   }
// }



// //그룹 소개 표시 다이얼로그 함수
// void showGroupDetailsDialog(BuildContext context, Group group) {
//   showDialog( 
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(18.0),
//         ),
//         contentPadding: EdgeInsets.symmetric(vertical: 30,horizontal: 20),
//         title: Center(
//           child:Column(
//             children: [
//               Text(group.name, style: TextStyle(color: Colors.black)),
//               SizedBox(height: 1.0), //그룹 여백
//               Text("그룹코드 ${group.groupCode}", 
//               textAlign: TextAlign.center, 
//               style: TextStyle(color: Colors.grey, fontSize: 13)),
//             ],
//           ),
//         ),
//          content: Column(
//             mainAxisSize:MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             SizedBox(height:0), //그룹 코드와 대표 카테고리 사이의 여백
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//             Text("대표 카테고리 "),
//             Text(group.category, style: TextStyle( color: getCategoryColor(group.category))),
//           ],
//           ),
//           SizedBox(height: 4.0,), //대표카테고리와 루틴장 사이의 여백 
//               Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [  
//             Text("루틴장 ${group.leader}"),
//             Text("   인원 ${group.membersCount}/30명"),
//               ],
//             ),
//              SizedBox(height: 12),
//             Divider(
//               height: 20,
//               thickness: 0.5,
//               color: Colors.black,
//             ),
//             SizedBox(height: 12), //간격 조절
//             Text(group.groupIntro),
//             // 다른 정보도 추가
//           SizedBox(height: 80.0,),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) =>OnClickGroupPage()),
//                );

//             },
//             child: Text('그룹 가입', style: TextStyle(color: const Color.fromARGB(255, 210, 197, 81), fontSize: 15)),
//             ),
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // 다이얼로그 닫기
//             },
//             child: Text('취소', style: TextStyle(color: Colors.black, fontSize: 15),),
//           ),
//         ],
//       );
//     },
//   );
// }