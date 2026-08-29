import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_locales.dart';
import '../widgets/elderease_help_button.dart';
import 'transfer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _balanceKey = GlobalKey();
  final _sendKey = GlobalKey();
  final _helpKey = GlobalKey();

  static const _screenContext = '''
Screen: Home of a payments app.
It shows: a search bar at the top with a language button, a card with the
balance (Rs 42,750), a row of saved people to pay, a section of businesses
and bills, a large blue "Send money" button, and recent transactions.
Tapping "Send money" opens the transfer screen.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topBar(),
                  const SizedBox(height: 8),
                  Padding(
                    padding: AppSizes.screenPadding,
                    child: _balanceCard(),
                  ),
                  const SizedBox(height: 24),
                  _sectionLabel('People'),
                  _peopleRow(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: AppSizes.screenPadding,
                    child: _sendButton(),
                  ),
                  const SizedBox(height: 26),
                  _sectionLabel('Businesses & bills'),
                  const SizedBox(height: 12),
                  _businessGrid(),
                  const SizedBox(height: 26),
                  _sectionLabel(AppLocales.t('recent')),
                  const SizedBox(height: 6),
                  _txn('Ramesh Kumar', 'Yesterday · Sent', '1,200',
                      const Color(0xFF1A73E8), 'R'),
                  _txn('Electricity bill', '24 Aug · Paid', '840',
                      const Color(0xFFF9AB00), 'E'),
                  _txn('Pension credit', '01 Aug · Received', '18,000',
                      const Color(0xFF1E8E3E), 'P', positive: true),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
          ElderEaseHelpButton(
            buttonKey: _helpKey,
            screenContext: _screenContext,
            walkthroughId: 'home',
            autoStartWalkthrough: true,
            walkthrough: [
              WalkthroughStep(
                  targetKey: _balanceKey,
                  titleKey: 'w_bal_t',
                  bodyKey: 'w_bal_b'),
              WalkthroughStep(
                  targetKey: _sendKey,
                  titleKey: 'w_send_t',
                  bodyKey: 'w_send_b'),
              WalkthroughStep(
                  targetKey: _helpKey,
                  titleKey: 'w_help_t',
                  bodyKey: 'w_help_b'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.inkMuted, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text('Pay anyone',
                        style: TextStyle(
                            fontSize: 16, color: AppColors.inkMuted)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _languageButton(),
        ],
      ),
    );
  }

  Widget _languageButton() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      tooltip: 'Language',
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      onSelected: (c) => setState(() => AppLocales.setLanguage(c)),
      itemBuilder: (_) => AppLocales.languages.entries
          .map((e) => PopupMenuItem(
                value: e.key,
                height: 60,
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: AppLocales.current == e.key
                          ? const Icon(Icons.check,
                              size: 24, color: AppColors.blue)
                          : null,
                    ),
                    Text(e.value,
                        style: const TextStyle(
                            fontSize: 21, fontWeight: FontWeight.w600)),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.blue.withOpacity(0.10),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
              color: AppColors.blue.withOpacity(0.40), width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate_rounded,
                size: 22, color: AppColors.blue),
            const SizedBox(width: 7),
            Text(
              AppLocales.languages[AppLocales.current] ?? 'English',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue),
            ),
            const Icon(Icons.arrow_drop_down,
                size: 22, color: AppColors.blue),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
      key: _balanceKey,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.account_balance,
                color: AppColors.blue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocales.t('balance'),
                    style: const TextStyle(
                        fontSize: 14, color: AppColors.inkMuted)),
                const SizedBox(height: 2),
                const Text('₹42,750',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                const Text('Savings ••4821',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.inkMuted)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.inkMuted),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Text(text,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink)),
    );
  }

  Widget _peopleRow() {
    const names = ['Ramesh', 'Sunita', 'Anil', 'Meena', 'Vijay'];
    const colors = [
      Color(0xFF1A73E8), Color(0xFFD93025), Color(0xFF1E8E3E),
      Color(0xFF7B1FA2), Color(0xFFE8710A),
    ];
    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: names.length,
        itemBuilder: (_, i) => Container(
          width: 74,
          margin: const EdgeInsets.only(right: 6),
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration:
                    BoxDecoration(color: colors[i], shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(names[i][0],
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.w500)),
              ),
              const SizedBox(height: 8),
              Text(names[i],
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.ink)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendButton() {
    return Container(
      key: _sendKey,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.30),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TransferScreen())),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_upward, color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Text(AppLocales.t('sendMoney'),
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _businessGrid() {
    const items = [
      ['Mobile recharge', Icons.smartphone, Color(0xFF1A73E8)],
      ['Electricity', Icons.bolt, Color(0xFFF9AB00)],
      ['DTH', Icons.tv, Color(0xFF7B1FA2)],
      ['Gas', Icons.local_fire_department, Color(0xFFD93025)],
    ];
    return Padding(
      padding: AppSizes.screenPadding,
      child: Row(
        children: items.map((it) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (it[2] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(it[1] as IconData,
                      color: it[2] as Color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(it[0] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.inkMuted)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _txn(String name, String sub, String amount, Color c, String letter,
      {bool positive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(letter,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.inkMuted)),
              ],
            ),
          ),
          Text('${positive ? '+' : '−'}₹$amount',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: positive ? AppColors.green : AppColors.ink)),
        ],
      ),
    );
  }
}
