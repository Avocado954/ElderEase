import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_locales.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static String? _lang;
  static double? _appliedRate;

  /// 0 = slow, 1 = normal, 2 = fast
  static final ValueNotifier<int> speed = ValueNotifier(1);
  static const List<double> _rates = [0.28, 0.42, 0.58];
  static const List<String> speedKeys = ['slow', 'normal', 'fast'];

  static double get _rate => _rates[speed.value];

  static void setSpeed(int i) {
    if (i >= 0 && i < _rates.length) speed.value = i;
  }

  static Future<void> _configure() async {
    final want = AppLocales.ttsLocale[AppLocales.current] ?? 'en-IN';
    if (_lang != want) {
      await _tts.setLanguage(want);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      _lang = want;
    }
    if (_appliedRate != _rate) {
      await _tts.setSpeechRate(_rate);
      _appliedRate = _rate;
    }
  }

  static Future<void> speak(String text) async {
    if (text.trim().isEmpty) return;
    await _configure();
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async => _tts.stop();
}