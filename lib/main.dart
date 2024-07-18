import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'routine_home/MyRoutinePage.dart';
import 'package:http/http.dart' as http;
import 'routine_group/GroupMainPage.dart';

void main() async{
await initializeDateFormatting();
 runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyRoutinePage(),
    );
  }
}

