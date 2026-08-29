import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_locales.dart';
import '../widgets/elderease_help_button.dart';
import 'confirm_screen.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _peopleKey = GlobalKey();
  final _amountKey = GlobalKey();
  final _continueKey = GlobalKey();

  final _amount = TextEditingController();
  String? _selected;

  static const _people = ['Ramesh Kumar', 'Sunita Devi', 'Anil Sharma'];
  static const _subs = ['9876543210', 'sunita@okbank', '9123456780'];
  static const _colors = [
    Color(0xFF1A73E8),
    Color(0xFFD93025),
    Color(0xFF1E8E3E),
  ];

  static const _screenContext = '''
Screen: Send money.
It shows a list of three saved people, a box to type the amount in rupees,
quick amount buttons, and a blue "Continue" button at the bottom.
The person must tap a name, type an amount, then tap Continue.
The back arrow at the top left cancels and returns home.
''';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  bool get _ready =>
      _selected != null && (double.tryParse(_amount.text) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(AppLocales.t('sendMoney'),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w500)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(AppLocales.t('to'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.inkMuted)),
                ),
                Column(
                  key: _peopleKey,
                  children: List.generate(
                      _people.length, (i) => _personTile(i)),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(AppLocales.t('amount'),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkMuted)),
                      const SizedBox(height: 10),
                      Container(
                        key: _amountKey,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: TextField(
                          controller: _amount,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink),
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            prefixText: '₹ ',
                            prefixStyle: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink),
                            hintText: '0',
                            hintStyle: TextStyle(
                                fontSize: 38, color: AppColors.line),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [500, 1000, 2000].map((v) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.blue,
                                  side: const BorderSide(
                                      color: AppColors.line),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(24)),
                                ),
                                onPressed: () => setState(
                                    () => _amount.text = v.toString()),
                                child: Text('₹$v',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        key: _continueKey,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _ready
                              ? AppColors.blue
                              : AppColors.line,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: _ready
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.blue.withOpacity(0.3),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  )
                                ]
                              : null,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(28),
                            onTap: _ready
                                ? () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ConfirmScreen(
                                          recipient: _selected!,
                                          amount: _amount.text,
                                        ),
                                      ),
                                    )
                                : null,
                            child: Center(
                              child: Text(
                                AppLocales.t('continueLabel'),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: _ready
                                      ? Colors.white
                                      : AppColors.inkMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 130),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ElderEaseHelpButton(
            screenContext: _screenContext,
            walkthroughId: 'transfer',
            autoStartWalkthrough: true,
            walkthrough: [
              WalkthroughStep(
                  targetKey: _peopleKey,
                  titleKey: 'w_pick_t',
                  bodyKey: 'w_pick_b'),
              WalkthroughStep(
                  targetKey: _amountKey,
                  titleKey: 'w_amt_t',
                  bodyKey: 'w_amt_b'),
              WalkthroughStep(
                  targetKey: _continueKey,
                  titleKey: 'w_cont_t',
                  bodyKey: 'w_cont_b'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _personTile(int i) {
    final name = _people[i];
    final selected = _selected == name;
    return Material(
      color: selected
          ? AppColors.blue.withOpacity(0.08)
          : Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _selected = name),
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                    color: _colors[i], shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(name[0],
                    style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.ink)),
                    Text(_subs[i],
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.inkMuted)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    color: AppColors.blue, size: 26),
            ],
          ),
        ),
      ),
    );
  }
}