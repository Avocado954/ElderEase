class ApiConfig {
  // Get a free key at https://aistudio.google.com/apikey
  // Replace the text inside the quotes with your key.
  static const String geminiApiKey = 'PASTE_YOUR_GEMINI_API_KEY_HERE';

  static const String model = 'gemini-2.5-flash';

  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  static bool get hasKey =>
      geminiApiKey.isNotEmpty && !geminiApiKey.startsWith('PASTE_');
}