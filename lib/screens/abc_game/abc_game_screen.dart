import 'dart:math';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:moodiesapp/screens/abc_game/utils/audio_manager.dart';
import 'package:moodiesapp/utils/app_constants.dart';
import '../../utils/navigation_service.dart';
import '../../widgets/CurvedMoodiesText.dart';
import 'menu_screen.dart';

class AbcGameScreen extends StatefulWidget {
  const AbcGameScreen({super.key});

  @override
  State<AbcGameScreen> createState() => _AbcGameScreenState();
}

class _AbcGameScreenState extends State<AbcGameScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ── existing state ────────────────────────────────────────────────────────
  late bool isSoundOn = true;
  Key key = UniqueKey();
  final AudioManager audioManager = AudioManager();

  // ── animation controllers ─────────────────────────────────────────────────
  late AnimationController _floatCtrl;   // slow sine float (logo + stars)
  late AnimationController _pulseCtrl;   // start button pulse
  late AnimationController _spinCtrl;    // decorative letter spin

  late Animation<double> _floatAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _spinAnim;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // float — logo bobs up-down
    _floatCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: -14)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // pulse — start button breathes
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    // spin — background letters drift
    _spinCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))
      ..repeat();
    _spinAnim = Tween<double>(begin: 0, end: 2 * pi).animate(_spinCtrl);

    _manageAudio();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    _spinCtrl.dispose();
    audioManager.resetVolume();
    super.dispose();
  }

  // ── audio ─────────────────────────────────────────────────────────────────
  void _toggleSound() {
    setState(() => isSoundOn = !isSoundOn);
    isSoundOn ? audioManager.playAudio() : audioManager.pauseAudio();
  }

  void _manageAudio() {
    isSoundOn ? audioManager.playAudio() : audioManager.pauseAudio();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _manageAudio();
    if (state == AppLifecycleState.paused)  audioManager.pauseAudio();
  }

  // ── ui helpers ────────────────────────────────────────────────────────────

  // Circular icon button used in the top bar
  Widget _topBarBtn({required Widget child, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.22),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.45), width: 1.5),
          ),
          child: Center(child: child),
        ),
      );

  // Colourful letter tile — used for the MOODIES logo
  Widget _logoTile(String letter, Color bg,
      {BorderRadius? radius}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: bg, borderRadius: radius),
        child: Text(
          letter,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: 'ChocoCooky',
            shadows: [Shadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2))],
          ),
        ),
      );

  // Ghost letters floating in the background
  Widget _ghostLetter(String l, double top, double? left, double? right,
      double size, double opacity, double delay) =>
      Positioned(
        top: top, left: left, right: right,
        child: AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _floatAnim.value * (delay % 2 == 0 ? 1 : -0.7)),
            child: Text(l,
                style: TextStyle(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withOpacity(opacity),
                  fontFamily: 'ChocoCooky',
                )),
          ),
        ),
      );

  // Twinkling star
  Widget _star(double top, double? left, double? right,
      double size, double animOffset) =>
      Positioned(
        top: top, left: left, right: right,
        child: AnimatedBuilder(
          animation: _floatCtrl,
          builder: (_, __) {
            final v = (sin(_floatCtrl.value * pi * 2 + animOffset) + 1) / 2;
            return Opacity(
              opacity: 0.3 + 0.7 * v,
              child: Transform.scale(
                scale: 0.6 + 0.4 * v,
                child: Text('★', style: TextStyle(fontSize: size, color: Colors.yellow.shade200)),
              ),
            );
          },
        ),
      );

  // ── build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final sh = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB57EDC), Color(0xFF8B5CF6), Color(0xFF7B5BFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [

            // ── background ghost letters ─────────────────────────────────
            _ghostLetter('A', sh * 0.14, 14, null, 52, 0.13, 0),
            _ghostLetter('B', sh * 0.24, null, 12, 48, 0.11, 1),
            _ghostLetter('C', sh * 0.55, 10, null, 44, 0.10, 0),
            _ghostLetter('Z', sh * 0.62, null, 8,  44, 0.10, 1),
            _ghostLetter('1', sh * 0.40, null, 30, 38, 0.08, 0),
            _ghostLetter('2', sh * 0.48, 28, null, 38, 0.08, 1),

            // ── twinkling stars ──────────────────────────────────────────
            _star(sh * 0.08,  20,   null, 20, 0.0),
            _star(sh * 0.13,  null, 28,   16, 1.5),
            _star(sh * 0.22,  36,   null, 14, 3.0),
            _star(sh * 0.70,  null, 20,   18, 0.8),
            _star(sh * 0.78,  18,   null, 14, 2.2),

            // ── floating cloud shapes ────────────────────────────────────
            Positioned(
              top: sh * 0.04, left: -20,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, child) => Transform.translate(
                    offset: Offset(_floatCtrl.value * 10, 0), child: child),
                child: Opacity(
                  opacity: 0.18,
                  child: _cloudShape(120, 50),
                ),
              ),
            ),
            Positioned(
              top: sh * 0.10, right: -16,
              child: AnimatedBuilder(
                animation: _floatCtrl,
                builder: (_, child) => Transform.translate(
                    offset: Offset(-_floatCtrl.value * 8, 0), child: child),
                child: Opacity(opacity: 0.12, child: _cloudShape(90, 38)),
              ),
            ),

            // ── main content ─────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [

                  // top bar (back + sound)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _topBarBtn(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                        _topBarBtn(
                          onTap: _toggleSound,
                          child: Image.asset(
                            isSoundOn
                                ? 'assets/abcgames/images/new_button/sound.png'
                                : 'assets/abcgames/images/new_button/sound_off.png',
                            width: 26,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        // "WELCOME TO" pill
                        FadeInDown(
                          duration: const Duration(milliseconds: 600),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.35),
                                  width: 1.5),
                            ),
                            child: Text('WELCOME TO',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 2.5,
                                )),
                          ),
                        ),
                        const SizedBox(height: 18),

                        // MOODIES colourful logo — floats up & down
                        AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (_, child) => Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: child),
                          child: ZoomIn(
                            key: key,
                            duration: const Duration(milliseconds: 900),
                            child: _moodiesLogo(),  // ← see below
                          ),
                        ),
                        const SizedBox(height: 10),

                        // subtitle
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Text(
                            'ABC Learning Adventure',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: sh * 0.06),

                        // bouncing mascot row
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: _mascotRow(),
                        ),
                        SizedBox(height: sh * 0.05),

                        // pulsing START button
                        AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (_, child) =>
                              Transform.scale(scale: _pulseAnim.value, child: child),
                          child: GestureDetector(
                            onTap: () => NavigationService()
                                .push(MenuScreen(audio: isSoundOn)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 52, vertical: 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFE066), Color(0xFFFFC107)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(40),
                                border: const Border(
                                    bottom: BorderSide(
                                        color: Color(0xFFE65100), width: 5)),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x55000000),
                                    blurRadius: 24,
                                    offset: Offset(0, 8),
                                  )
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.play_arrow_rounded,
                                      color: Color(0xFF7B3F00), size: 30),
                                  SizedBox(width: 8),
                                  Text(
                                    'START',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF7B3F00),
                                      fontFamily: 'ChocoCooky',
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── grass strip at bottom ────────────────────────────────────
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: CustomPaint(
                size: Size(sw, 56),
                painter: _GrassPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MOODIES logo ──────────────────────────────────────────────────────────
  Widget _moodiesLogo() {
    const r16 = Radius.circular(16);
    const r4  = Radius.circular(4);
    final tiles = [
      ('M',  const Color(0xFFFF6B6B),
      const BorderRadius.only(topLeft: r16, bottomLeft: r16, topRight: r4, bottomRight: r4)),
      ('O',  const Color(0xFFFFB347), BorderRadius.all(r4)),
      ('O',  const Color(0xFF4FC3F7), BorderRadius.all(r4)),
      ('D',  const Color(0xFF81C784), BorderRadius.all(r4)),
      ('I',  const Color(0xFFCE93D8), BorderRadius.all(r4)),
      ('ES', const Color(0xFFFF8A65),
      const BorderRadius.only(topRight: r16, bottomRight: r16, topLeft: r4, bottomLeft: r4)),
    ];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: tiles
          .map((t) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: _logoTile(t.$1, t.$2, radius: t.$3),
      ))
          .toList(),
    );
  }

  // ── mascot row ────────────────────────────────────────────────────────────
  Widget _mascotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _mascotBubble('😺', 60, delay: 0),
        const SizedBox(width: 10),
        _mascotBubble('⭐', 74, delay: 200, big: true),
        const SizedBox(width: 10),
        _mascotBubble('🐸', 60, delay: 400),
      ],
    );
  }

  Widget _mascotBubble(String emoji, double size,
      {int delay = 0, bool big = false}) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _floatAnim.value * (big ? 1.0 : 0.65)),
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(big ? 0.28 : 0.20),
            shape: BoxShape.circle,
            border: Border.all(
                color: Colors.white.withOpacity(big ? 0.7 : 0.5),
                width: 2.5),
          ),
          child: Center(
            child: Text(emoji,
                style: TextStyle(fontSize: big ? 36 : 28)),
          ),
        ),
      ),
    );
  }

  // ── cloud shape painter ───────────────────────────────────────────────────
  Widget _cloudShape(double w, double h) => CustomPaint(
    size: Size(w, h),
    painter: _CloudPainter(),
  );
}

// ── Cloud CustomPainter ───────────────────────────────────────────────────────
class _CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white;
    final w = size.width;
    final h = size.height;
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.5, h * 0.7), width: w * 0.96, height: h * 0.6), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.3, h * 0.52), width: w * 0.44, height: h * 0.55), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.68, h * 0.48), width: w * 0.36, height: h * 0.48), p);
  }
  @override bool shouldRepaint(_) => false;
}

// ── Grass CustomPainter ───────────────────────────────────────────────────────
class _GrassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final back = Paint()..color = const Color(0xFF5D9C59).withOpacity(0.85);
    final front = Paint()..color = const Color(0xFF4CAF50).withOpacity(0.92);

    final backPath = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.05, h * 0.15, w * 0.10, h * 0.50)
      ..quadraticBezierTo(w * 0.15, h * 0.90, w * 0.20, h * 0.40)
      ..quadraticBezierTo(w * 0.25, h * 0.00, w * 0.30, h * 0.46)
      ..quadraticBezierTo(w * 0.35, h * 0.88, w * 0.40, h * 0.35)
      ..quadraticBezierTo(w * 0.45, h * 0.00, w * 0.50, h * 0.50)
      ..quadraticBezierTo(w * 0.55, h * 0.90, w * 0.60, h * 0.36)
      ..quadraticBezierTo(w * 0.65, h * 0.00, w * 0.70, h * 0.48)
      ..quadraticBezierTo(w * 0.75, h * 0.88, w * 0.80, h * 0.38)
      ..quadraticBezierTo(w * 0.85, h * 0.00, w * 0.90, h * 0.50)
      ..quadraticBezierTo(w * 0.95, h * 0.88, w * 1.0, h * 0.42)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final frontPath = Path()
      ..moveTo(0, h * 0.70)
      ..quadraticBezierTo(w * 0.07, h * 0.28, w * 0.14, h * 0.68)
      ..quadraticBezierTo(w * 0.22, h * 1.0,  w * 0.30, h * 0.58)
      ..quadraticBezierTo(w * 0.38, h * 0.20, w * 0.45, h * 0.62)
      ..quadraticBezierTo(w * 0.53, h * 1.0,  w * 0.60, h * 0.56)
      ..quadraticBezierTo(w * 0.68, h * 0.16, w * 0.75, h * 0.62)
      ..quadraticBezierTo(w * 0.83, h * 1.0,  w * 0.90, h * 0.60)
      ..quadraticBezierTo(w * 0.96, h * 0.24, w * 1.0,  h * 0.62)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(backPath, back);
    canvas.drawPath(frontPath, front);
  }

  @override bool shouldRepaint(_) => false;
}

/*
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:moodiesapp/screens/abc_game/utils/audio_manager.dart';
import 'package:moodiesapp/utils/app_constants.dart';

import '../../utils/navigation_service.dart';
import '../../widgets/CurvedMoodiesText.dart';
import 'menu_screen.dart';

class AbcGameScreen extends StatefulWidget{
  const AbcGameScreen({super.key});

  @override
  State<AbcGameScreen> createState() => _AbcGameScreenState();
}

class _AbcGameScreenState extends State<AbcGameScreen> with WidgetsBindingObserver {
  late bool isSoundOn = true;
  Key key = UniqueKey();
  final AudioManager audioManager = AudioManager();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _manageAudio();
  }

  Future<void> _navigate() async {
    await Future.delayed(
        const Duration(milliseconds: AppConstants.splashTimeout));
    if (!mounted) return;

    NavigationService().push(MenuScreen(audio: isSoundOn));

  }



  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioManager.resetVolume();
    super.dispose();
  }

  void sound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }
  void _manageAudio() {
    setState(() {
      if (isSoundOn== true) {
        audioManager.playAudio();
      }
      else {
        audioManager.pauseAudio();
      }
    });
  }
  ///Application on Background that time call method
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _manageAudio();
      print('\x1B[34m App in foreground\x1B[0m***********************');
    }

    else if (state == AppLifecycleState.paused) {
      audioManager.pauseAudio();
      print('\x1B[33m App in background\x1B[0m##################');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidthSize = MediaQuery.of(context).size.width;
    final screenHeightSize = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB57EDC),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          FloatingActionButton(
            heroTag: "btn2",
            elevation: 0,
            backgroundColor: Colors.transparent,
            onPressed: () {
              setState(() {
                sound();
                if(isSoundOn==false){
                  audioManager.pauseAudio();
                  // player.pause();
                }
                else if(isSoundOn==true){
                  audioManager.playAudio();
                  // player.play(AssetSource('audio/bg_.mp4'));
                }
              });
            },
            child: isSoundOn
                ? Image.asset(
              "assets/abcgames/images/new_button/sound.png",
            )
                : Image.asset("assets/abcgames/images/new_button/sound_off.png"),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB57EDC), // light purple (top)
              Color(0xFF7B5BFF), // deeper purple (bottom)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenHeightSize * 0.1),
                      Padding(
                        padding: EdgeInsets.only(
                            left: constraints.maxWidth * 0.11,
                            right: constraints.maxWidth * 0.11
                        ),
                        child: ZoomIn(
                          key: key,
                          animate: true,
                          duration: const Duration(milliseconds: 2000),
                          child: const CurvedMoodiesText(),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.width * 0.09,
                      ),
                      InkWell(
                        onTap: () {
                          NavigationService().push(MenuScreen(audio: isSoundOn));
                          // Navigator.push(context, MaterialPageRoute(
                          //   builder: (context) {
                          //     return MenuScreen(
                          //       audio: isSoundOn,
                          //     );
                          //   },
                          // ));
                        },
                        child: Image.asset(
                          "assets/abcgames/images/new_button/start_button.png",
                          width: screenWidthSize * 0.4,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
