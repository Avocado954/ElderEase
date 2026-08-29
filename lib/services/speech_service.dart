import 'package:speech_to_text/speech_to_text.dart';

import '../utils/app_locales.dart';

class SpeechService {
  static final SpeechToText _speech = SpeechToText();
  static bool _ready = false;

  static bool get isListening => _speech.isListening;

  static Future<bool> init() async {
    if (_ready) return true;
    _ready = await _speech.initialize(
      onError: (e) {},
      onStatus: (s) {},
    );
    return _ready;
  }

  static Future<bool> listen({
    required void Function(String text) onFinal,
    void Function(String text)? onPartial,
  }) async {
    final ok = await init();
    if (!ok) return false;

    await _speech.listen(
      localeId: AppLocales.speechLocale[AppLocales.current] ?? 'en_IN',
      listenFor: const Duration(seconds: 15),
      pauseFor: const Duration(seconds: 3),
      onResult: (result) {
        if (result.finalResult) {
          onFinal(result.recognizedWords);
        } else {
          onPartial?.call(result.recognizedWords);
        }
      },
    );
    return true;
  }

  static Future<void> stop() async => _speech.stop();
}