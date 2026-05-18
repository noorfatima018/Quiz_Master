import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AITutorService {
  static const String _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';

  Future<String> getTutorResponse(List<Map<String, String>> chatHistory) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Groq API Key is missing.');
    }

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
              'content': 'You are "Quiz Master AI Tutor", a helpful, friendly, and knowledgeable academic tutor. Your goal is to help students understand complex topics, explain quiz concepts, and provide study tips. Keep your responses concise, encouraging, and clear.'
            },
            ...chatHistory
          ],
          'temperature': 0.7,
          'max_tokens': 1000,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception('Groq Error (${response.statusCode}): ${errorData['error']['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to get tutor response: $e');
    }
  }
}
