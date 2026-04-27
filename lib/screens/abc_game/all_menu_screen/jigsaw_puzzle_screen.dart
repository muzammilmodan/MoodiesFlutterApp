import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/audio_manager.dart';

class JigsawPuzzleScreen extends StatefulWidget {
  const JigsawPuzzleScreen({
    Key? key,
    required this.audio,
  });

  final audio;

  @override
  _jigsawPuzzleScreenState createState() => _jigsawPuzzleScreenState();
}

GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

class _jigsawPuzzleScreenState extends State<JigsawPuzzleScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  bool _isFirst = false;
  bool _isSecond = false;
  bool _isThird = false;
  bool _isFourth = false;

  late ConfettiController _confettiController;
  int _currentIndex = 0;

  // final List<String> _letters =
  // List.generate(20, (i) => String.fromCharCode(65 + i)); // A....z
  final List<String> _letters =
      List.generate(20, (index) => (index + 1).toString());

  String get currentLetter => _letters[_currentIndex];

  String get blueImage => 'assets/abcgames/game/${currentLetter.toLowerCase()}_1.png';

  String get redImage => 'assets/abcgames/game/${currentLetter.toLowerCase()}_2.png';

  String get yellowImage => 'assets/abcgames/game/${currentLetter.toLowerCase()}_3.png';

  String get greenImage => 'assets/abcgames/game/${currentLetter.toLowerCase()}_4.png';

  final player = AudioPlayer();
  final AudioManager audioManager = AudioManager();

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation = AlwaysStoppedAnimation(Offset.zero);

  late bool isSoundOn = true;
  final Random _random = Random();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _manageAudio();
      _confettiController =
          ConfettiController(duration: const Duration(milliseconds: 1));

      _controller = AnimationController(
        duration: const Duration(seconds: 1),
        vsync: this,
      )..repeat(reverse: true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _setAnimationOffsets();
      });
    });
  }

  void _setAnimationOffsets() {
    Size screenSize = MediaQuery.of(context).size;
    bool isRTL = Directionality.of(context) == TextDirection.rtl;
    double startX = isRTL ? 0.0 : -0.05 * screenSize.width / screenSize.height;
    double startY = 0.40 * screenSize.height / screenSize.width;
    double endX = isRTL ? -0.8 : -1.3; //-0.98
    double endY = -0.99;
    _offsetAnimation = Tween<Offset>(
      begin: Offset(startX, startY),
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioManager.resetVolume();
    player.stop();
    _controller.dispose();
    super.dispose();
  }

  void _checkCompletion() {
    if (_isFirst && _isSecond && _isThird && _isFourth) {
      setState(() {
        setState(() {
          _confettiController.play();
          playAudio(currentLetter.toLowerCase());
          Alert(context);
          Future.delayed(Duration(seconds: 3), () {
            setState(() {
              _currentIndex = (_currentIndex + 1) % _letters.length;
              _isFirst = false;
              _isSecond = false;
              _isThird = false;
              _isFourth = false;
              print("_currentIndex~~${_currentIndex}");
            });
          });
        });
      });
    }
  }

  Future<void> playAudio(String alphabet) async {
    if (widget.audio == true) {
      player.play(AssetSource('abcgames/audio/$alphabet.mp3'));
      print("ALPHABET~~~~$alphabet");
    }
  }

  void Alert(BuildContext context) {
    int _Count = 2;
    double _percent = 1.0;
    late Stream<int> _timerStream;
    late Key key = UniqueKey();

    _timerStream =
        Stream<int>.periodic(Duration(seconds: 1), (x) => _Count - x - 1)
            .take(_Count)
            .asBroadcastStream();

    void _startTimer() {
      const oneSecond = Duration(seconds: 1);
      Timer.periodic(oneSecond, (Timer timer) {
        setState(() {
          if (_Count == 1) {
            timer.cancel();
          } else {
            setState(() {
              _Count--;
              key = UniqueKey();
              _percent = _Count / 2;
              print("_tickCount!!!!${_Count}");
            });
            // anim=true;
          }
        });
      });
    }

    _startTimer();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final Color barrierColor = isDarkMode
        ? Colors.black.withOpacity(0.2)
        : Colors.black.withOpacity(0.2);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: barrierColor,
      builder: (context) {
        Future.delayed(Duration(seconds: 3), () {
          Navigator.of(context).pop();
        });
        return StreamBuilder<int>(
            stream: _timerStream,
            builder: (BuildContext context, setState) {
              return CupertinoAlertDialog(
                insetAnimationCurve: Curves.fastOutSlowIn,
                title: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Center(
                    child: Text(
                      "Correct!!" + "🎉😊",
                      style: TextStyle(
                        fontSize: 29,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                // content: Text("Excellent"),
                content: Center(
                  child: Container(
                    height: 67,
                    width: 67,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 139, 213, 0),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        strokeAlign: BorderSide.strokeAlignInside,
                        width: 3,
                        color: Color.fromARGB(255, 40, 114, 12),
                      ),
                    ),
                    child: ZoomIn(
                      key: key,
                      duration: Duration(milliseconds: 200),
                      animate: true,
                      child: AutoSizeText(
                        wrapWords: true,
                        "$_Count",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 39.0),
                      ),
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  void _manageAudio() {
    setState(() {
      if (widget.audio == true) {
        if (!audioManager.isPlaying) {
          audioManager.playAudio(volume: 0.10);
        } else {
          audioManager.setVolume(0.10);
        }
      } else {
        audioManager.pauseAudio();
      }
    });
  }

  ///Application on Background that time call method
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _manageAudio();
      setState(() {
        isSoundOn==true;
      });
      print('\x1B[34m App in foreground\x1B[0m***********************');
    } else if (state == AppLifecycleState.paused) {
      audioManager.pauseAudio();
      print('\x1B[33m App in background\x1B[0m##################');
    }
  }

  void sound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    List<Widget> staticPieces = <Widget>[
      _buildDraggablePiece(_isSecond, 'red', redImage),
      _buildDraggablePiece(_isThird, 'yellow', yellowImage),
      _buildDraggablePiece(_isFirst, 'blue', blueImage),
      _buildDraggablePiece(_isFourth, 'green', greenImage),
    ];

    List<Widget> draggablePieces = List.from(staticPieces);
    if (_currentIndex != 0) {
      draggablePieces.shuffle(_random);
    }
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "1",
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/abcgames/images/new_button/back.png",
                fit: BoxFit.fill),
            onPressed: () {
              player.stop();
              Navigator.pop(context);
            },
          ),
          FloatingActionButton(
            heroTag: "btn3",
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: isSoundOn
                ? Image.asset(
                    "assets/abcgames/images/new_button/bc_on.png",
                  )
                : Image.asset("assets/abcgames/images/new_button/bc_off.png",
                    height: 90),
            onPressed: () {
              setState(() {
                sound();
                if (widget.audio == true) {
                  if (isSoundOn == false) {
                    audioManager.pauseAudio();
                  } else if (isSoundOn == true) {
                    // audioManager.playAudio();
                    _manageAudio();
                  }
                }
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/abcgames/new_gif/puzzle.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Center(
                child: ConfettiWidget(
                  blastDirectionality: BlastDirectionality.explosive,
                  // shouldLoop: true,
                  blastDirection: pi,
                  particleDrag: 0.01,
                  //0.02 Reducing drag makes particles move faster
                  emissionFrequency: 0.4,
                  //0.1 Increase frequency to emit more particles
                  numberOfParticles: 250,
                  //50 Increase the number of particles per burst
                  gravity: 0.3,
                  //0.7 Gravity makes particles fall faster
                  createParticlePath: (size) {
                    final path = Path();
                    path.addOval(
                        Rect.fromCircle(center: Offset.zero, radius: 10));
                    return path;
                  },
                  colors: const [
                    Colors.blue,
                    Colors.green,
                    Colors.amberAccent,
                    Colors.pink,
                    Colors.teal,
                  ],
                  confettiController: _confettiController,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: screenSize.height * 0.11,
                    right: screenSize.width * 0.09,
                    left: screenSize.width * 0.09),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/abcgames/game/bg_top.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                  child: GridView.count(
                    crossAxisCount: 2,
                    padding: EdgeInsets.all(screenSize.width * 0.03),
                    mainAxisSpacing: _isFirst ? 0 : 6,
                    crossAxisSpacing: _isFirst ? 0 : 6,
                    shrinkWrap: true,
                    controller: ScrollController(keepScrollOffset: false),
                    children: [
                      _buildPuzzlePiece(_isFirst, 'blue', blueImage),
                      _buildPuzzlePiece(_isSecond, 'red', redImage),
                      _buildPuzzlePiece(_isThird, 'yellow', yellowImage),
                      _buildPuzzlePiece(_isFourth, 'green', greenImage),
                    ],
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.topCenter,
                fit: StackFit.passthrough,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        top: screenSize.height * 0.02,
                        right: screenSize.width * 0.09,
                        left: screenSize.width * 0.09),
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/abcgames/game/bg_bottom.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        child: Center(
                          child: GridView.count(
                            crossAxisCount: 2,
                            padding: EdgeInsets.all(screenSize.width * 0.10),
                            mainAxisSpacing: 13,
                            crossAxisSpacing: 13,
                            shrinkWrap: true,
                            controller:
                                ScrollController(keepScrollOffset: false),
                            children:
                              // _buildDraggablePiece(_isSecond, 'red', redImage),
                              // _buildDraggablePiece(
                              //     _isThird, 'yellow', yellowImage),
                              // _buildDraggablePiece(_isFirst, 'blue', blueImage),
                              // _buildDraggablePiece(
                              //     _isFourth, 'green', greenImage),
                              _currentIndex == 0 ? staticPieces : draggablePieces,

                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_currentIndex == 0)
                    Container(
                      padding: EdgeInsets.only(right: screenSize.width * 0.09),
                      alignment: Alignment.topRight,
                      height: screenSize.height * 0.15,
                      child: SlideTransition(
                        position: _offsetAnimation,
                        child: Image.asset(
                          'assets/abcgames/new_gif/Hand Image.png',
                            color: Color.fromARGB(255, 242, 176, 155)
                        ),
                      ),
                    )
                  // Positioned(
                  //   bottom: screenSize.height * 0.29,
                  //   child: Container(
                  //       // color: Colors.pink,
                  //       height: screenSize.height * 0.17,
                  //       child: Image.asset('assets/new_gif/word.gif',
                  //           fit: BoxFit.contain, color: Colors.white)),
                  // ),
                ],
              ),
              SizedBox(
                height: screenSize.height * 0.03,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () {
                        setState(() {
                          _isFirst = false;
                          _isSecond = false;
                          _isThird = false;
                          _isFourth = false;
                          _currentIndex = (_currentIndex - 1) % _letters.length;
                        });
                      },
                      child: Image(
                          image:
                              AssetImage("assets/abcgames/images/new_button/prev.png"),
                          height: screenSize.height * 0.07)),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isFirst = false;
                        _isSecond = false;
                        _isThird = false;
                        _isFourth = false;
                        _currentIndex = (_currentIndex + 1) % _letters.length;
                      });
                    },
                    child: Image(
                      image: AssetImage("assets/abcgames/images/new_button/next.png"),
                      height: screenSize.height * 0.07,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: screenSize.height * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPuzzlePiece(bool isDropped, String color, String imagePath) {
    return DragTarget<String>(
      builder: (BuildContext context, List<dynamic> accepted,
          List<dynamic> rejected) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              colorFilter: isDropped
                  ? null
                  : ColorFilter.mode(Colors.white, BlendMode.color),
              image: AssetImage(imagePath),
              fit: BoxFit.fill,
              opacity: isDropped ? 1 : 0.5,
              // colorFilter: isDropped?null :ColorFilter.mode(Colors.grey.withOpacity(0.9), BlendMode.saturation)
              // colorFilter: isDropped
              //     ? null
              //     : ColorFilter.mode(Colors.grey, BlendMode.saturation)
            ),
          ),
        );
      },
      onWillAccept: (data) {
        return data == color;
      },
      onAccept: (data) {
        setState(() {
          if (data == color) {
            if (color == 'blue') _isFirst = true;
            if (color == 'red') _isSecond = true;
            if (color == 'yellow') _isThird = true;
            if (color == 'green') _isFourth = true;
            setState(() {
              _checkCompletion();
            });
          } else {
            setState(() {
              // _showWrongMatchAlert(context,);
            });
          }
        });
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust duration as needed
      ),
    );
  }

  Widget _buildDraggablePiece(bool isDropped, String color, String imagePath) {
    final screenSize = MediaQuery.of(context).size;
    return Visibility(
      visible: !isDropped,
      child: Draggable<String>(
        data: color,
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: screenSize.width * 0.4,
        ),
        feedback: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          width: screenSize.width * 0.37,
        ),
        childWhenDragging: Center(),
      ),
    );
  }
}
