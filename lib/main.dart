import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'RoutineAdeIntro/RoutineAde1.dart';
import 'routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import 'routine_group/GroupMainPage.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyRoutinePage(),
    );
  }
}
