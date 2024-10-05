import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'RoutineAdeIntro/RoutineAde1.dart';
import 'routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import 'routine_group/GroupMainPage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Firebase 초기화
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
