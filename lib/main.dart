import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:routine_ade/routine_home/MyRoutinePage.dart';
import 'routine_group/GroupMainPage.dart';
import 'routine_group/OnClickGroupPage.dart';
import 'RoutineAdelntro/RoutineAde1.dart';

void main() async {
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
        debugShowCheckedModeBanner: false, home: MyRoutinePage());
  }
}
