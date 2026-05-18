import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import '../models/question_model.dart';

class GroqAIService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<List<QuestionModel>> generateQuestions({
    required String source,
    required int count,
    bool isFile = false,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Groq API Key is missing. Please add GROQ_API_KEY to your .env file.');
    }

    // Truncate source if it's too long to prevent context overflow (approx 4k characters is safe for a prompt)
    String truncatedSource = source;
    if (source.length > 6000) {
      truncatedSource = source.substring(0, 6000) + "... [content truncated]";
    }

    final prompt = """
      Generate $count high-quality multiple-choice questions based on the following ${isFile ? 'content' : 'topic'}:
      
      --- CONTENT ---
      $truncatedSource
      --- END CONTENT ---
      
      You MUST return a JSON object with a "questions" key. Each element in the "questions" array must be an object with:
      - "text": The question string
      - "options": An array of exactly 4 strings
      - "correctOptionIndex": An integer from 0 to 3
      - "explanation": A brief explanation of the correct answer
      
      JSON Structure:
      {
        "questions": [
          {
            "text": "...",
            "options": ["...", "...", "...", "..."],
            "correctOptionIndex": 0,
            "explanation": "..."
          }
        ]
      }
    """;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an academic expert that generates quiz questions. You always respond with a valid JSON object containing a "questions" array. No preamble, no markdown.'
            },
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.6,
          'max_tokens': 4000,
          'response_format': {'type': 'json_object'}
        }),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String content = data['choices'][0]['message']['content'];

        final Map<String, dynamic> decodedContent = jsonDecode(content);
        final List<dynamic> jsonList = decodedContent['questions'] ?? [];

        if (jsonList.isEmpty) {
          throw Exception('AI returned an empty questions list.');
        }

        return jsonList.asMap().entries.map((entry) {
          return QuestionModel.fromMap(entry.value, 'groq_${DateTime.now().millisecondsSinceEpoch}_${entry.key}');
        }).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Groq Error (${response.statusCode}): ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      debugPrint('Groq Service Error: $e');
      throw Exception('Failed to generate quiz: $e');
    }
  }
}
