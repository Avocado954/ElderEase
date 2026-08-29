import 'package:flutter/material.dart';

import '../services/tts_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_locales.dart';
import '../widgets/elderease_help_button.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen(
      {super.key, required this.recipient, required this.amount});

  final String recipient;
  final String amount;

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  final _summaryKey = GlobalKey();
  final _payKey = GlobalKey();

  String get _screenContext => '''
Screen: Confirm and pay.
It shows a summary: sending Rs ${widget.amount} to ${widget.recipient},
from Savings account 4821, fee Rs 0.
There is a blue "Confirm and pay" button at the bottom, and a back arrow at
the top left to go back and change the details.
No money moves until the blue button is tapped.
''';

  void _pay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.green.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.green, size: 52),
              ),
              const SizedBox(height: 20),
              Text(AppLocales.t('sent'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink)),
              const SizedBox(height: 8),
              Text('₹${widget.amount}',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink)),
              const SizedBox(height: 4),
              Text(widget.recipient,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, color: AppColors.inkMuted)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26)),
                  ),
                  onPressed: () => Navigator.of(context)
                      .popUntil((route) => route.isFirst),
                  child: Text(AppLocales.t('backHome'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    TtsService.speak(
        '${AppLocales.t('sent')}. ${widget.amount} — ${widget.recipient}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(AppLocales.t('checkDetails'),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Container(
                  key: _summaryKey,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(AppLocales.t('youAreSending'),
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.inkMuted)),
                      const SizedBox(height: 8),
                      Text('₹${widget.amount}',
                          style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink)),
                      const SizedBox(height: 22),
                      const Divider(color: AppColors.line, height: 1),
                      const SizedBox(height: 18),
                      _row(AppLocales.t('to'), widget.recipient),
                      _row(AppLocales.t('from'), 'Savings ••4821'),
                      _row(AppLocales.t('fee'), '₹0'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.lock_outline,
                        size: 16, color: AppColors.inkMuted),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                          'Nothing is sent until you tap the button below.',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.inkMuted)),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Container(
                  key: _payKey,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withOpacity(0.3),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(28),
                      onTap: _pay,
                      child: Center(
                        child: Text(AppLocales.t('confirmPay'),
                            style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 130),
              ],
            ),
          ),
          ElderEaseHelpButton(
            screenContext: _screenContext,
            walkthroughId: 'confirm',
            walkthrough: [
              WalkthroughStep(
                  targetKey: _summaryKey,
                  titleKey: 'w_chk_t',
                  bodyKey: 'w_chk_b'),
              WalkthroughStep(
                  targetKey: _payKey,
                  titleKey: 'w_pay_t',
                  bodyKey: 'w_pay_b'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 15, color: AppColors.inkMuted)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink)),
        ],
      ),
    );
  }
}