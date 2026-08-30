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
It shows: a search bar at the top with a language button, four action tiles
(Scan any QR code, Pay anyone, Bank transfer, Mobile recharge), a card with
the balance (Rs 42,750), a row of saved people, a large blue "Send money"
button, a businesses and bills section, and recent transactions.
Tapping "Send money" opens the transfer screen.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _topBar(),
                  _promoBanner(),
                  const SizedBox(height: 24),
                  _actionTiles(),
                  const SizedBox(height: 20),
                  _chipsRow(),
                  const SizedBox(height: 26),
                  Padding(
                    padding: AppSizes.screenPadding,
                    child: _balanceCard(),
                  ),
                  const SizedBox(height: 26),
                  _sectionLabel('People'),
                  const SizedBox(height: 14),
                  _peopleRow(),
                  const SizedBox(height: 22),
                  Padding(
                    padding: AppSizes.screenPadding,
                    child: _sendButton(),
                  ),
                  const SizedBox(height: 28),
                  _sectionLabel('Businesses & bills'),
                  const SizedBox(height: 14),
                  _businessGrid(),
                  const SizedBox(height: 28),
                  _sectionLabel(AppLocales.t('recent')),
                  const SizedBox(height: 10),
                  _txn('Ramesh Kumar', 'Yesterday · Sent', '1,200',
                      const Color(0xFF1A73E8), 'R'),
                  _txn('Electricity bill', '24 Aug · Paid', '840',
                      const Color(0xFFF9AB00), 'E'),
                  _txn('Pension credit', '01 Aug · Received', '18,000',
                      const Color(0xFF1E8E3E), 'P', positive: true),
                  const SizedBox(height: 150),
                ],
              ),
            ),
          ),
          _bottomNav(),
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

  // ---------------------------------------------------------------- top bar

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.line),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.inkMuted, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pay by name or phone number',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 15.5, color: AppColors.inkMuted),
                    ),
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
      offset: const Offset(0, 54),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (c) => setState(() => AppLocales.setLanguage(c)),
      itemBuilder: (_) => AppLocales.languages.entries
          .map((e) => PopupMenuItem<String>(
                value: e.key,
                height: 58,
                child: Row(
                  children: [
                    SizedBox(
                      width: 30,
                      child: AppLocales.current == e.key
                          ? const Icon(Icons.check,
                              size: 22, color: AppColors.blue)
                          : null,
                    ),
                    Text(
                      e.value,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink),
                    ),
                  ],
                ),
              ))
          .toList(),
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.blue,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.translate, size: 20, color: Colors.white),
            const SizedBox(width: 7),
            Text(
              AppLocales.languages[AppLocales.current] ?? 'English',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
            const Icon(Icons.arrow_drop_down, size: 22, color: Colors.white),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------- banner + illustration

  Widget _promoBanner() {
    return Container(
      margin: AppSizes.screenPadding,
      height: 168,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F0FE), Color(0xFFDCE9FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Drawn skyline / coins / phone — no image file needed.
            Positioned.fill(
              child: CustomPaint(painter: _BannerPainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Easy EMIs from\n₹2,000 per month',
                    style: TextStyle(
                      fontSize: 21,
                      height: 1.3,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const Text('Apply now',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blue)),
                      const SizedBox(width: 10),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: AppColors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward,
                            size: 17, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------------- tiles

  Widget _actionTiles() {
    const items = [
      [Icons.qr_code_scanner, 'Scan any\nQR code'],
      [Icons.arrow_upward_rounded, 'Pay\nanyone'],
      [Icons.account_balance, 'Bank\ntransfer'],
      [Icons.smartphone, 'Mobile\nrecharge'],
    ];
    return Padding(
      padding: AppSizes.screenPadding,
      child: Row(
        children: items.map((it) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 66,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.blue,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x331A73E8),
                        blurRadius: 12,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(it[0] as IconData,
                      size: 30, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  it[1] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      height: 1.25,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _chipsRow() {
    return SizedBox(
      height: 58,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: AppSizes.screenPadding,
        children: [
          _chip(Icons.contactless, 'Tap & Pay', 'Add card', AppColors.blue),
          const SizedBox(width: 12),
          _chip(Icons.rocket_launch, 'UPI Lite', 'Activate',
              const Color(0xFF7A4DD8)),
          const SizedBox(width: 12),
          _chip(Icons.emoji_events, 'Rewards', 'New', AppColors.yellow),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String title, String sub, Color tint) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink)),
              Text(sub,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blue)),
            ],
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- balance

  Widget _balanceCard() {
    return Container(
      key: _balanceKey,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blue, AppColors.blueDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x401A73E8),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocales.t('balance'),
              style: const TextStyle(fontSize: 15, color: Colors.white70)),
          const SizedBox(height: 6),
          const Text('₹42,750',
              style: TextStyle(
                  fontSize: 42,
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1)),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Savings ••4821',
                style: TextStyle(fontSize: 14, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- people

  Widget _sectionLabel(String text) {
    return Padding(
      padding: AppSizes.screenPadding,
      child: Text(text,
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.ink)),
    );
  }

  Widget _peopleRow() {
    const names = ['Meenakshy', 'Asok', 'Hitanshi', 'Sibu', 'Resmi'];
    const colors = [
      Color(0xFF4A6B8A),
      Color(0xFF8A6A5C),
      Color(0xFF1F7A6B),
      Color(0xFF7A5C8A),
      Color(0xFF4C7A3E),
    ];
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSizes.screenPadding,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 20),
        itemBuilder: (_, i) => SizedBox(
          width: 68,
          child: Column(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: colors[i],
                child: Text(names[i][0],
                    style: const TextStyle(
                        fontSize: 25,
                        color: Colors.white,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 8),
              Text(
                names[i],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 13.5, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendButton() {
    return SizedBox(
      key: _sendKey,
      height: 68,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: const Color(0x551A73E8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(34)),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TransferScreen()),
        ),
        icon: const Icon(Icons.arrow_upward_rounded, size: 26),
        label: Text(AppLocales.t('sendMoney'),
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ------------------------------------------------------------- bills etc

  Widget _businessGrid() {
    const items = [
      [Icons.smartphone, 'Mobile\nrecharge'],
      [Icons.bolt, 'Electricity'],
      [Icons.tv, 'DTH'],
      [Icons.local_fire_department, 'Gas'],
    ];
    return Padding(
      padding: AppSizes.screenPadding,
      child: Row(
        children: items.map((it) {
          return Expanded(
            child: Column(
              children: [
                Container(
                  height: 62,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Icon(it[0] as IconData,
                      size: 26, color: AppColors.blue),
                ),
                const SizedBox(height: 8),
                Text(
                  it[1] as String,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12.5,
                      height: 1.25,
                      color: AppColors.inkMuted),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _txn(String name, String sub, String amount, Color tint,
      String letter,
      {bool positive = false}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: tint,
            child: Text(letter,
                style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 13.5, color: AppColors.inkMuted)),
              ],
            ),
          ),
          Text(
            '${positive ? '+' : '−'} ₹$amount',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: positive ? AppColors.green : AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 18),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(Icons.home, 'Home', true),
            _navItem(Icons.currency_rupee, 'Money', false),
            _navItem(Icons.person, 'You', false),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 5),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFDCE9FB) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon,
              size: 24,
              color: active ? AppColors.blue : AppColors.inkMuted),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? AppColors.ink : AppColors.inkMuted)),
      ],
    );
  }
}

/// Draws the banner illustration — skyline, coins, phone.
/// Painted in code so there is no asset file to go missing.
class _BannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Soft hill
    final hill = Paint()..color = const Color(0xFFCFE0F8);
    final hillPath = Path()
      ..moveTo(0, h)
      ..lineTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.30, h * 0.60, w * 0.62, h * 0.74)
      ..quadraticBezierTo(w * 0.85, h * 0.84, w, h * 0.70)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(hillPath, hill);

    // Buildings
    final b1 = Paint()..color = const Color(0xFFB6CDEE);
    final b2 = Paint()..color = const Color(0xFFA3BFE6);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.60, h * 0.34, w * 0.10, h * 0.42), b1);
    canvas.drawRect(
        Rect.fromLTWH(w * 0.71, h * 0.46, w * 0.08, h * 0.30), b2);

    // House with roof
    final houseX = w * 0.62;
    final houseY = h * 0.10;
    final houseW = w * 0.12;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(houseX, houseY, houseW, houseW * 0.85),
        const Radius.circular(8),
      ),
      Paint()..color = const Color(0xFF9CC0F0),
    );
    final roof = Path()
      ..moveTo(houseX - 4, houseY + 6)
      ..lineTo(houseX + houseW / 2, houseY - 10)
      ..lineTo(houseX + houseW + 4, houseY + 6)
      ..close();
    canvas.drawPath(roof, Paint()..color = const Color(0xFFD93025));

    // Car block
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.20, w * 0.13, h * 0.24),
        const Radius.circular(10),
      ),
      Paint()..color = const Color(0xFFF2B33D),
    );

    // Coin stack
    final coin = Paint()..color = const Color(0xFFF2C14E);
    for (var i = 0; i < 3; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.66, h * 0.80 - i * 9, w * 0.13, 7),
          const Radius.circular(4),
        ),
        coin,
      );
    }
    canvas.drawCircle(
        Offset(w * 0.62, h * 0.62), h * 0.075, coin);

    // Phone with a note
    final phone = Rect.fromLTWH(w * 0.83, h * 0.30, w * 0.12, h * 0.55);
    canvas.drawRRect(
      RRect.fromRectAndRadius(phone, const Radius.circular(10)),
      Paint()..color = const Color(0xFFC3D4E8),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.845, h * 0.36, w * 0.09, h * 0.22),
        const Radius.circular(5),
      ),
      Paint()..color = const Color(0xFF34A853),
    );
  }

  @override
  bool shouldRepaint(covariant _BannerPainter oldDelegate) => false;
}