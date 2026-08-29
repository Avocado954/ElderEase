import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/gemini_service.dart';
import '../services/speech_service.dart';
import '../services/tts_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_locales.dart';

class WalkthroughStep {
  final GlobalKey targetKey;
  final String titleKey;
  final String bodyKey;

  const WalkthroughStep({
    required this.targetKey,
    required this.titleKey,
    required this.bodyKey,
  });

  String get title => AppLocales.t(titleKey);
  String get body => AppLocales.t(bodyKey);
}

class ElderEaseHelpButton extends StatefulWidget {
  const ElderEaseHelpButton({
    super.key,
    required this.screenContext,
    this.walkthrough = const [],
    this.buttonKey,
    this.autoStartWalkthrough = false,
    this.walkthroughId = 'default',
  });

  final String screenContext;
  final List<WalkthroughStep> walkthrough;
  final GlobalKey? buttonKey;
  final bool autoStartWalkthrough;
  final String walkthroughId;

  @override
  State<ElderEaseHelpButton> createState() => _ElderEaseHelpButtonState();
}

class _ElderEaseHelpButtonState extends State<ElderEaseHelpButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breathe;

  @override
  void initState() {
    super.initState();
    _breathe = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    if (widget.autoStartWalkthrough && widget.walkthrough.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoStart());
    }
  }

  @override
  void dispose() {
    _breathe.dispose();
    super.dispose();
  }

  Future<void> _maybeAutoStart() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'walkthrough_seen_${widget.walkthroughId}';
    if (prefs.getBool(key) == true) return;
    await prefs.setBool(key, true);
    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    startWalkthrough();
  }

  void startWalkthrough() {
    if (widget.walkthrough.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, __, ___) =>
            _WalkthroughOverlay(steps: widget.walkthrough),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _openHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: EaseColors.scrim,
      builder: (_) => _HelpSheet(
        screenContext: widget.screenContext,
        onStartWalkthrough:
            widget.walkthrough.isEmpty ? null : startWalkthrough,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 26,
      child: AnimatedBuilder(
        animation: _breathe,
        builder: (_, child) {
          final t = _breathe.value;
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: EaseColors.amber.withOpacity(0.34 + 0.26 * t),
                  blurRadius: 26 + 18 * t,
                  spreadRadius: 2 + 6 * t,
                ),
              ],
            ),
            child: child,
          );
        },
        child: GestureDetector(
          key: widget.buttonKey,
          onTap: _openHelpSheet,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [EaseColors.amber, EaseColors.amberDeep],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Padding(
                      padding: const EdgeInsets.all(9),
                      child: Image.asset(
                        'assets/images/logo.png',
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.support_agent_rounded,
                          size: 34,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    AppLocales.t('help'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HelpSheet extends StatefulWidget {
  const _HelpSheet({required this.screenContext, this.onStartWalkthrough});

  final String screenContext;
  final VoidCallback? onStartWalkthrough;

  @override
  State<_HelpSheet> createState() => _HelpSheetState();
}

enum _HelpState { idle, listening, thinking, answered }

class _HelpSheetState extends State<_HelpSheet> {
  _HelpState _state = _HelpState.idle;
  String _question = '';
  String _answer = '';
  final TextEditingController _typed = TextEditingController();

  @override
  void dispose() {
    _typed.dispose();
    SpeechService.stop();
    TtsService.stop();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _state = _HelpState.listening;
      _question = '';
      _answer = '';
    });
    final ok = await SpeechService.listen(
      onPartial: (t) => setState(() => _question = t),
      onFinal: (t) {
        setState(() => _question = t);
        _askGemini(t);
      },
    );
    if (!ok && mounted) {
      setState(() {
        _state = _HelpState.answered;
        _answer =
            'I could not use the microphone. Please allow microphone access, or type your question below.';
      });
    }
  }

  Future<void> _askGemini(String question) async {
    if (question.trim().isEmpty) {
      setState(() => _state = _HelpState.idle);
      return;
    }
    setState(() => _state = _HelpState.thinking);
    final answer = await GeminiService.ask(
      question: question,
      screenContext: widget.screenContext,
    );
    if (!mounted) return;
    setState(() {
      _answer = answer;
      _state = _HelpState.answered;
    });
    TtsService.speak(answer);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: EaseColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
          border: Border(
            top: BorderSide(color: EaseColors.amber, width: 5),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: EaseColors.inkMuted.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: EaseColors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('ElderEase',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: EaseColors.ink)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 30, color: EaseColors.inkMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                AppLocales.t('askAnything'),
                style: const TextStyle(
                  fontSize: EaseSizes.title,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: EaseColors.ink,
                ),
              ),
              const SizedBox(height: 18),
              _micButton(),
              const SizedBox(height: 14),
              if (_question.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: EaseColors.inkMuted.withOpacity(0.2), width: 2),
                  ),
                  child: Text(
                    _question,
                    style: const TextStyle(
                      fontSize: EaseSizes.body,
                      color: EaseColors.inkMuted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              if (_state == _HelpState.thinking) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: EaseColors.amberDeep),
                    ),
                    const SizedBox(width: 12),
                    Text(AppLocales.t('thinking'),
                        style: const TextStyle(
                            fontSize: EaseSizes.body,
                            fontWeight: FontWeight.w600,
                            color: EaseColors.inkMuted)),
                  ],
                ),
              ],
              if (_answer.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: EaseColors.amber, width: 3),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _answer,
                        style: const TextStyle(
                          fontSize: EaseSizes.body,
                          height: 1.5,
                          fontWeight: FontWeight.w500,
                          color: EaseColors.ink,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          style: TextButton.styleFrom(
                              foregroundColor: EaseColors.amberDeep),
                          onPressed: () => TtsService.speak(_answer),
                          icon: const Icon(Icons.volume_up_rounded, size: 28),
                          label: Text(AppLocales.t('readAgain'),
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _speedControl(),
              const SizedBox(height: 16),
              TextField(
                controller: _typed,
                style: const TextStyle(
                    fontSize: EaseSizes.body, color: EaseColors.ink),
                decoration: InputDecoration(
                  hintText: AppLocales.t('typeInstead'),
                  hintStyle: const TextStyle(
                      fontSize: 18, color: EaseColors.inkMuted),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                        color: EaseColors.inkMuted, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                        color: EaseColors.inkMuted.withOpacity(0.35),
                        width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: const BorderSide(
                        color: EaseColors.amber, width: 3),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        size: 30, color: EaseColors.amberDeep),
                    onPressed: () {
                      final q = _typed.text;
                      _typed.clear();
                      setState(() => _question = q);
                      _askGemini(q);
                    },
                  ),
                ),
                onSubmitted: (q) {
                  _typed.clear();
                  setState(() => _question = q);
                  _askGemini(q);
                },
              ),
              if (widget.onStartWalkthrough != null) ...[
                const SizedBox(height: 14),
                SizedBox(
                  height: 66,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: EaseColors.teal,
                      side: const BorderSide(
                          color: EaseColors.teal, width: 3),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onStartWalkthrough!();
                    },
                    icon: const Icon(Icons.explore_rounded, size: 30),
                    label: Text(
                      AppLocales.t('showMeAround'),
                      style: const TextStyle(
                          fontSize: EaseSizes.body,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _speedControl() {
    return ValueListenableBuilder<int>(
      valueListenable: TtsService.speed,
      builder: (_, value, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded,
                  size: 26, color: EaseColors.inkMuted),
              const SizedBox(width: 8),
              Text(AppLocales.t('speed'),
                  style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: EaseColors.inkMuted)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (i) {
              final on = value == i;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    TtsService.setSpeed(i);
                    if (_answer.isNotEmpty) TtsService.speak(_answer);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on ? EaseColors.teal : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: on
                            ? EaseColors.teal
                            : EaseColors.inkMuted.withOpacity(0.3),
                        width: 3,
                      ),
                    ),
                    child: Text(
                      AppLocales.t(TtsService.speedKeys[i]),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: on ? Colors.white : EaseColors.inkMuted,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _micButton() {
    final listening = _state == _HelpState.listening;
    return GestureDetector(
      onTap: listening ? SpeechService.stop : _startListening,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: listening
                ? [const Color(0xFFE05252), const Color(0xFFB3261E)]
                : [EaseColors.amber, EaseColors.amberDeep],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: (listening
                      ? const Color(0xFFB3261E)
                      : EaseColors.amberDeep)
                  .withOpacity(0.42),
              blurRadius: 22,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.26),
                shape: BoxShape.circle,
              ),
              child: Icon(
                  listening ? Icons.stop_rounded : Icons.mic_rounded,
                  size: 38,
                  color: Colors.white),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                listening
                    ? AppLocales.t('listening')
                    : AppLocales.t('tapToSpeak'),
                style: const TextStyle(
                  fontSize: EaseSizes.title,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkthroughOverlay extends StatefulWidget {
  const _WalkthroughOverlay({required this.steps});

  final List<WalkthroughStep> steps;

  @override
  State<_WalkthroughOverlay> createState() => _WalkthroughOverlayState();
}

class _WalkthroughOverlayState extends State<_WalkthroughOverlay>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _speak());
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _speak() {
    final s = widget.steps[_index];
    TtsService.speak('${s.title}. ${s.body}');
  }

  void _next() {
    if (_index >= widget.steps.length - 1) {
      _finish();
      return;
    }
    setState(() => _index++);
    _speak();
  }

  void _finish() {
    TtsService.stop();
    Navigator.of(context).pop();
  }

  Rect? _rectFor(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_index];
    final screen = MediaQuery.of(context).size;
    final rect = _rectFor(step.targetKey);
    final target = rect ??
        Rect.fromCenter(
          center: Offset(screen.width / 2, screen.height / 3),
          width: 0,
          height: 0,
        );

    final below = screen.height - target.bottom > 300;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(color: EaseColors.scrim),
            ),
          ),
          if (rect != null)
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) {
                final t = _pulse.value;
                return Positioned(
                  left: target.left - 12 - (8 * t),
                  top: target.top - 12 - (8 * t),
                  width: target.width + 24 + (16 * t),
                  height: target.height + 24 + (16 * t),
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: EaseColors.amber.withOpacity(1 - t * 0.2),
                          width: 7,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: EaseColors.amber.withOpacity(0.7 * (1 - t)),
                            blurRadius: 46 + 30 * t,
                            spreadRadius: 4 + 12 * t,
                          ),
                          BoxShadow(
                            color: Colors.white.withOpacity(0.4 * (1 - t)),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          if (rect != null)
            Positioned(
              left: (target.center.dx - 15).clamp(28.0, screen.width - 58),
              top: below ? target.bottom + 10 : target.top - 28,
              child: IgnorePointer(
                child: CustomPaint(
                  size: const Size(30, 20),
                  painter: _ArrowPainter(pointsUp: below),
                ),
              ),
            ),
          Positioned(
            left: 14,
            right: 14,
            top: below ? target.bottom + 28 : null,
            bottom: below ? null : screen.height - target.top + 28,
            child: _card(step),
          ),
        ],
      ),
    );
  }

  Widget _card(WalkthroughStep step) {
    final isLast = _index == widget.steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
      decoration: BoxDecoration(
        color: EaseColors.cream,
        borderRadius: BorderRadius.circular(EaseSizes.radius),
        border: Border.all(color: EaseColors.amber, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: EaseColors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.support_agent_rounded,
                    size: 20, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Text('ElderEase',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: EaseColors.inkMuted)),
              const Spacer(),
              Row(
                children: List.generate(
                  widget.steps.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == _index ? 28 : 10,
                    height: 10,
                    margin: const EdgeInsets.only(left: 6),
                    decoration: BoxDecoration(
                      color: i == _index
                          ? EaseColors.amber
                          : EaseColors.inkMuted.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(step.title,
              style: const TextStyle(
                  fontSize: EaseSizes.huge,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: EaseColors.ink)),
          const SizedBox(height: 10),
          Text(step.body,
              style: const TextStyle(
                  fontSize: EaseSizes.body,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                  color: EaseColors.ink)),
          const SizedBox(height: 18),
          Row(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: EaseColors.inkMuted,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onPressed: _finish,
                child: Text(AppLocales.t('skip'),
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              SizedBox(
                height: 62,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EaseColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    padding: const EdgeInsets.symmetric(horizontal: 26),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                  ),
                  onPressed: _next,
                  icon: Icon(
                      isLast
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      size: 26),
                  label: Text(
                      isLast ? AppLocales.t('done') : AppLocales.t('next'),
                      style: const TextStyle(
                          fontSize: 21, fontWeight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  _ArrowPainter({required this.pointsUp});

  final bool pointsUp;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..color = EaseColors.amber;
    final path = Path();
    if (pointsUp) {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    } else {
      path.moveTo(size.width / 2, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    }
    path.close();
    canvas.drawPath(path, fill);
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter old) => old.pointsUp != pointsUp;
}