import 'package:flutter/material.dart';
import 'result_dialog.dart';

class ResultPage extends StatelessWidget {
  final int totalMarks;
  final int totalQuestions;
  final int correctAnswers;

  ResultPage({
    required this.totalMarks,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF47134F),
      body: Center(
        child: ResultDialog(
          totalMarks: totalMarks,
          totalQuestions: totalQuestions,
          correctAnswers: correctAnswers,
        ),
      ),
    );
  }
}
