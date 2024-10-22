import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'RoutineAdeIntro/RoutineAde1.dart';
import 'routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import 'routine_group/GroupMainPage.dart';
import 'package:kakao_flutter_sdk_common/kakao_flutter_sdk_common.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // KakaoSdk.init(nativeAppKey: '90e5f5e8125f01adae4434fd72182a74'); //네이티브 앱 키

  await initializeDateFormatting();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RoutineAde1(),
    );
  }
}
