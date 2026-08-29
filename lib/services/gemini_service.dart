import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/app_locales.dart';
import 'api_config.dart';

class GeminiService {
  static const String _systemPrompt = '''
You are ElderEase, a patient in-app helper for a payments app used by senior citizens.
Rules:
- Answer in at most 2 short sentences. No lists, no markdown, no emoji.
- Use everyday words. Never use banking jargon or technical terms.
- Tell the person exactly what to tap, in order, using the button names given to you.
- If the question is not about this app, say kindly that you can only help with this app.
- Your answer will be read aloud, so write it the way you would say it.
''';

  static Future<String> ask({
    required String question,
    required String screenContext,
  }) async {
    if (question.trim().isEmpty) return 'Please ask your question again.';
    if (!ApiConfig.hasKey) return _fallback(question);

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/${ApiConfig.model}:generateContent?key=${ApiConfig.geminiApiKey}',
    );

    // Whatever language is selected — Hindi, Tamil, Telugu, Bengali,
    // Kannada, Malayalam or English.
    final language = AppLocales.englishName[AppLocales.current] ?? 'English';

    final body = {
      'system_instruction': {
        'parts': [
          {
            'text': '$_systemPrompt\n'
                'The person is using the app in $language. '
                'You MUST write your entire answer in $language, '
                'using that language\'s own script. '
                'Do not use English words unless there is no common '
                '$language word for them.'
          }
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': 'Screen the person is looking at:\n$screenContext\n\n'
                  'Their question: "$question"\n\n'
                  'Answer in $language.'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.3,
        'maxOutputTokens': 400,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    };

    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) return _fallback(question);

      final data = jsonDecode(utf8.decode(res.bodyBytes));
      final parts = data['candidates']?[0]?['content']?['parts'];
      if (parts is List && parts.isNotEmpty) {
        final text = parts
            .map((p) => p['text'] ?? '')
            .join(' ')
            .toString()
            .replaceAll('*', '')
            .trim();
        if (text.isNotEmpty) return text;
      }
      return _fallback(question);
    } catch (_) {
      return _fallback(question);
    }
  }

  /// Offline safety net — answers in the selected language.
  static String _fallback(String question) {
    final q = question.toLowerCase();
    String key;
    if (q.contains('balance') || q.contains('बैलेंस')) {
      key = 'w_bal_b';
    } else if (q.contains('send') ||
        q.contains('transfer') ||
        q.contains('pay') ||
        q.contains('भेज')) {
      key = 'w_send_b';
    } else {
      key = 'w_help_b';
    }
    return AppLocales.t(key);
  }
}