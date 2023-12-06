import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:job_task/api_screen.dart';
import 'package:job_task/api_model.dart';
import 'result_page.dart';

class QuizState extends ChangeNotifier {
  int selectedOptionIndex = -1;
  bool isOptionSelected = false;
  bool stopTimer = false;
  int currentQuestionIndex = 0;
  bool isLoading = false;
  int totalMarks = 0;
  late List<QuizQuestion> questions;

  Future<void> onOptionSelected(
      int index, bool isCorrect, BuildContext context) async {
    if (!isLoading && !isOptionSelected) {
      selectedOptionIndex = index;
      isOptionSelected = true;
      stopTimer = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('selectedOptionIndex', selectedOptionIndex);

      Future.delayed(Duration(seconds: 2), () {
        selectedOptionIndex = -1;
        notifyListeners();
      });

      Future.delayed(Duration(seconds: 1), () {
        selectedOptionIndex = index;
        notifyListeners();
      });

      if (!isCorrect) {
        Future.delayed(Duration(seconds: 2), () {
          selectedOptionIndex = index;
          notifyListeners();
        });
      }

      if (isCorrect) {
        totalMarks += 20;
      }
      notifyListeners();

      // Print stored data after the user has made a selection
      await printStoredData();
    }
  }

  Future<void> onNextButtonPressed(BuildContext context) async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(Duration(milliseconds: 100));

      BuildContext quizContext = context;

      questions = await fetchQuizQuestions();

      isLoading = false;
      notifyListeners();

      isOptionSelected = false;
      stopTimer = false;
      selectedOptionIndex = -1;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setInt('totalMarks', totalMarks);

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        resetTimer();
      } else {
        Navigator.of(quizContext).push(
          MaterialPageRoute(
            builder: (context) => ResultPage(
              totalMarks: totalMarks,
              totalQuestions: questions.length,
              correctAnswers: totalMarks ~/ 20,
            ),
          ),
        );
      }

      // Print stored data after the quiz has ended
      await printStoredData();
    } catch (error) {
      print('Error: $error');
      isLoading = false;
      notifyListeners();
    }
  }

  void resetTimer() {
    notifyListeners();
  }

  // function to print stored data
  Future<void> printStoredData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int storedSelectedOptionIndex = prefs.getInt('selectedOptionIndex') ?? -1;
    int storedTotalMarks = prefs.getInt('totalMarks') ?? 0;

    print('Stored Selected Option Index: $storedSelectedOptionIndex');
    print('Stored Total Marks: $storedTotalMarks');
  }
}

class QuizPage extends StatefulWidget {
  final List<QuizQuestion> questions;

  const QuizPage({Key? key, required this.questions}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Future<List<QuizQuestion>> futureQuestions;
  int totalTime = 20;
  late int currentTime;

  @override
  void initState() {
    super.initState();
    futureQuestions = fetchQuizQuestions();
    currentTime = totalTime;
    startTimer();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      if (currentTime > 0 &&
          !(Provider.of<QuizState>(context, listen: false).stopTimer)) {
        setState(() {
          currentTime--;
        });
      } else {
        timer.cancel();
        if (!(Provider.of<QuizState>(context, listen: false).stopTimer)) {
          handleQuizEnd();
        }
      }
    });
  }

  void handleQuizEnd() {
    Navigator.of(context).pop();
    print('Quiz has ended!');
  }

  void resetTimer() {
    setState(() {
      currentTime = totalTime;
    });
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF47134F),
      body: Consumer<QuizState>(
        builder: (context, quizState, child) {
          return FutureBuilder<List<QuizQuestion>>(
            future: futureQuestions,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text('No quiz questions available.'),
                );
              } else {
                QuizQuestion quizQuestion =
                    snapshot.data![quizState.currentQuestionIndex];
                Color progressBarColor = currentTime > 8
                    ? const Color.fromARGB(255, 110, 66, 186)
                    : Colors.red;

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 400,
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: LinearProgressIndicator(
                                  value: currentTime / totalTime,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    progressBarColor,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                '${currentTime}s',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 75),
                      Text(
                        quizQuestion.question,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontFamily: 'Kanit',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 45),
                      for (int i = 0; i < quizQuestion.options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: GestureDetector(
                            onTap: () => quizState.onOptionSelected(
                              i,
                              quizQuestion.options[i].isCorrect,
                              context,
                            ),
                            child: Container(
                              height: 65,
                              width: 400,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: _getOptionColor(
                                  quizState,
                                  i,
                                  quizQuestion.options[i].isCorrect,
                                ),
                                border:
                                    Border.all(width: 1.5, color: Colors.white),
                              ),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, top: 15),
                                child: Text(
                                  quizQuestion.options[i].text,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 23,
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 20),
                      Container(
                        height: 40,
                        width: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: GestureDetector(
                          onTap: quizState.isLoading
                              ? null
                              : () async {
                                  await quizState.onNextButtonPressed(context);
                                  resetTimer();
                                },
                          child: Center(
                            child: quizState.isLoading
                                ? CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      const Color(0xFF8514E1),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      'NEXT',
                                      style: TextStyle(
                                        color: const Color(0xFF8514E1),
                                        fontSize: 24,
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w900,
                                        height: 0.08,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }

  Color _getOptionColor(QuizState quizState, int index, bool isCorrect) {
    if (quizState.isOptionSelected &&
        (index == quizState.selectedOptionIndex || isCorrect)) {
      return isCorrect ? Colors.green : Colors.red;
    } else {
      return Colors.transparent;
    }
  }
}
