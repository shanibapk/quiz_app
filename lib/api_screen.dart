import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:job_task/api_model.dart';

Future<List<QuizQuestion>> fetchQuizQuestions() async {
  String apiUrl = 'https://nice-lime-hippo-wear.cyclic.app/api/v1/quiz';

  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => QuizQuestion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load quiz questions');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}
