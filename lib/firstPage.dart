import 'package:flutter/material.dart';
import 'package:job_task/api_model.dart';
import 'package:job_task/api_screen.dart';
import 'package:job_task/quiz_page.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  late Future<List<QuizQuestion>> futureQuestions;

  @override
  void initState() {
    super.initState();
    // Start loading quiz questions in the background
    futureQuestions = fetchQuizQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF47134F),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 300,
            ),
            Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                image: const DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage('assets/quiz.png'),
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            // Use FutureBuilder to build the Start Quiz button when questions are loaded
            FutureBuilder<List<QuizQuestion>>(
              future: futureQuestions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Loading indicator while questions are being fetched
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // Handle error if fetching questions fails
                  return Text('Error: ${snapshot.error}');
                } else {
                  // Show the Start Quiz button when questions are loaded
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizPage(
                            questions: snapshot.data ?? [],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 53,
                      width: 158,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF8514E1),
                      ),
                      child: const Center(
                        child: Text(
                          'Start Quiz',
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
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
