import 'package:flutter/material.dart';
import 'package:job_task/quiz_page.dart';
import 'package:provider/provider.dart';
import 'firstPage.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => QuizState(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}
