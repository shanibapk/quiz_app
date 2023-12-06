import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final int totalMarks;
  final int totalQuestions;
  final int correctAnswers;

  ResultDialog({
    required this.totalMarks,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate the percentage
    double percentage = (correctAnswers / totalQuestions) * 100;

    // Determine whether to show "TRY AGAIN" or "BACK" button
    Widget button;
    if (percentage < 60) {
      button = Container(
        height: 45,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.red,
        ),
        child: const Center(
          child: Text(
            'Try Again',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w900,
              height: 0.08,
            ),
          ),
        ),
      );
    } else {
      button = Container(
        height: 45,
        width: 150,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12), color: Colors.green),
        child: const Center(
          child: Text(
            'Back',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Kanit',
              fontWeight: FontWeight.w900,
              height: 0.08,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF47134F),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 140,
            ),
            AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              title: Column(
                children: [
                  Container(
                    height: 230,
                    width: 480,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      image: const DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/cong.jpg'),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    '$totalMarks% Score',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'Quiz Completed Successfully..!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Text(
                    'You attempted $totalQuestions Questions and \n'
                    'from that $correctAnswers answers are correct',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            button,
          ],
        ),
      ),
    );
  }
}
