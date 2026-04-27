import 'dart:async';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/audio_manager.dart';

class DragMatchNumberBlockScreen extends StatefulWidget {
  DragMatchNumberBlockScreen({
    super.key,
    required this.letterName,
    required this.audio,
    required this.index,
  });

  final audio;
  late final letterName;
  int index;

  @override
  _dragMatchNumberBlockScreen createState() => _dragMatchNumberBlockScreen();
}

class _dragMatchNumberBlockScreen extends State<DragMatchNumberBlockScreen>
    with WidgetsBindingObserver  ,SingleTickerProviderStateMixin {
  final List<String> nameList =
      // List.generate(25, (index) => (index + 1).toString());
      List.generate(16, (index) => (index + 1).toString());
  late ConfettiController _confettiController;
  late ConfettiController _confettiController2;
  Map<String, bool> score = {};
  List<String> letterImageLists = [];
  int currentIndex = 0;
  final player = AudioPlayer();
  final AudioManager audioManager = AudioManager();
  bool handIcon = true;
  final List<String> fruit = [
    'assets/abcgames/words/chocolate.png',
    'assets/abcgames/words/pizzaa.png',
    'assets/abcgames/words/candy.png',
    'assets/abcgames/words/cupcake.png',
    'assets/abcgames/words/doughnut.png',
    'assets/abcgames/words/ice-cream.png',
    'assets/abcgames/words/burgerr.png',
    'assets/abcgames/words/muffin.png',
    'assets/abcgames/words/soft-drink.png',

    'assets/abcgames/words/burger.png',
    'assets/abcgames/words/burrito.png',
    'assets/abcgames/words/cake.png',
    'assets/abcgames/words/pizza.png',
  ];
  late  AnimationController _controller;
  late Animation<Offset> _offsetAnimation = AlwaysStoppedAnimation(Offset.zero);

  late bool isSoundOn = true;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _manageAudio();
      randomSet();
      getPaths();
      _confettiController =
          ConfettiController(duration: const Duration(microseconds: 1));
      _confettiController2 =
          ConfettiController(duration: const Duration(microseconds: 1));

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
    // Get the screen size
    Size screenSize = MediaQuery.of(context).size;

    // Determine if the layout direction is RTL or LTR
    bool isRTL = Directionality.of(context) == TextDirection.rtl;

    // Calculate proportional offsets based on screen width and height
    double startX = isRTL ? 0.0 : -0.05 * screenSize.width / screenSize.height;
    double startY = 0.40 * screenSize.height / screenSize.width;
    double endX = isRTL ? -0.8 : -1.3;//-0.98
    double endY = -0.99;
    _offsetAnimation = Tween<Offset>(
      begin: Offset(startX, startY),
      end: Offset(endX, endY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    setState(() {}); // Trigger rebuild to apply updated offset
  }

  void checkCompletion() {
    bool isComplete = true;
    for (int i = 0; i < 2; i++) {
      int index = (currentIndex + i) % nameList.length;
      print("index~~${index}");
      if (score[nameList[index]] != true) {
        isComplete = false;
        break;
      }
    }
    if (isComplete) {
      setState(() {
        handIcon = false;
        Future.delayed(Duration(microseconds: 8), () {
          Alert(context);
        });
        Future.delayed(Duration(seconds: 2), () {
          currentIndex = (currentIndex + 2) % nameList.length;
          score.clear();
          randomSet();
        });
      });
    }
  }

  void randomSet() {
    setState(() {
      nameList.shuffle();
      currentIndex = 0;
      score.clear();
    });
  }

  void playAudio(String value) {
    String audioPath;

    audioPath = 'abcgames/audio/${value}.mp3';

    print("AUDIO!!!!$audioPath");
    player.play(AssetSource("$audioPath"));
  }

  getPaths() async {
    setState(() {
      letterImageLists = [
        "assets/abcgames/1.png",
        "assets/abcgames/2.png",
        "assets/abcgames/3.png",
      ];
    });
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
            // Navigator.of(context).pop();// Cancel the timer when countdown reaches 0
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
        ? Colors.black.withOpacity(0.4)
        : Colors.black.withOpacity(0.4);
    showDialog(
      context: context,
      barrierColor: barrierColor,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(Duration(seconds: 2), () {
          Navigator.of(context).pop();
          // Navigator.pop(context);
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
                        fontFamily: FontName.SuezOneRegular,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                // content: Text("Excellent"),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
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
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: FontName.SuezOneRegular,
                              fontWeight: FontWeight.bold,
                              fontSize: 39.0),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  void _playSingleConfetti(ConfettiController controllerToPlay) {
    setState(() {
    controllerToPlay.play();
    });
  }

  void _manageAudio() {
    setState(() {
      if (widget.audio == true) {
        if (!audioManager.isPlaying) {
          audioManager.playAudio(volume: 0.10);
        } else {
          audioManager.setVolume(0.10);
        }
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
      setState(() {
        isSoundOn==true;
      });
      print('\x1B[34m App in foreground\x1B[0m***********************');
    }

    else if (state == AppLifecycleState.paused) {
      audioManager.pauseAudio();
      print('\x1B[33m App in background\x1B[0m##################');
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    audioManager.resetVolume();
    player.stop();
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  void sound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isPortrait = screenHeight > screenWidth;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: "1",
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/abcgames/images/new_button/back.png",),
            onPressed: () {
              Navigator.pop(context);
            },

          ),
          Flexible(
            child: AutoSizeText(
              maxLines: 2,
              minFontSize: 18,
              "Drag and Drop",
              style: TextStyle(
                color: isDarkMode
                    ? Color.fromARGB(255, 255, 255, 255)
                    : Color.fromARGB(255, 255, 255, 255),
                fontSize: screenSize.width * 0.09,
                fontFamily: FontName.Chiki,
              ),
            ),
          ),
          Row(
            children: [
              FloatingActionButton(
                heroTag: "4",
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Image.asset("assets/abcgames/images/new_button/next_word.png",
                    fit: BoxFit.fill),
                onPressed: () {
                  setState(() {
                    handIcon = false;
                  });
                  randomSet();
                },
              ),
              FloatingActionButton(
                heroTag: "btn3",
                elevation: 0,
                backgroundColor: Colors.transparent,
                // backgroundColor: Colors.transparent,
                child: isSoundOn
                    ? Image.asset(
                  "assets/abcgames/images/new_button/bc_on.png",
                )
                    : Image.asset("assets/abcgames/images/new_button/bc_off.png",),
                onPressed: () {
                  setState(() {
                    sound();
                    if(widget.audio == true) {
                      if (isSoundOn == false) {
                        audioManager.pauseAudio();
                      }
                      else if (isSoundOn == true) {
                        // audioManager.playAudio();
                        _manageAudio();
                      }
                    }
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/abcgames/new_gif/drage_drop_bg.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: screenSize.height * 0.13,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: isPortrait
                              ? MediaQuery.of(context).size.width * 0.46
                              : MediaQuery.of(context).size.width * 0.24,
                          height: isPortrait
                              ? MediaQuery.of(context).size.height * 0.29
                              : MediaQuery.of(context).size.height * 0.23,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/abcgames/images/new_button/Group.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Center(
                            child: _buildTarget(context, nameList[currentIndex],
                                nameList[currentIndex]),
                          ),
                        ),
                        ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          blastDirection: pi,
                          particleDrag: 0.05,
                          emissionFrequency: 0.2,
                          numberOfParticles: 45,
                          createParticlePath: (size) {
                            final path = Path();
                            path.addOval(Rect.fromCircle(center: Offset.zero, radius: 10));
                            return path;
                          },
                          colors: const [
                            Colors.blue,
                            Colors.orange,
                            Colors.green,
                            Colors.amberAccent,
                            Colors.pink,
                          ],
                        ),
                        Container(
                          child: _buildDoneDrag(context, nameList[currentIndex],
                              nameList[currentIndex], _confettiController),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ConfettiWidget(
                          confettiController: _confettiController2,
                          blastDirectionality: BlastDirectionality.explosive,
                          shouldLoop: false,
                          blastDirection: pi,
                          particleDrag: 0.05,
                          emissionFrequency: 0.2,
                          numberOfParticles: 45,
                          createParticlePath: (size) {
                            final path = Path();
                            path.addOval(Rect.fromCircle(center: Offset.zero, radius: 10));
                            return path;
                          },
                          colors: const [
                            Colors.blue,
                            Colors.orange,
                            Colors.green,
                            Colors.amberAccent,
                            Colors.pink,
                          ],
                        ),
                        Container(
                          child: _buildDoneDrag(context, nameList[currentIndex + 1],
                              nameList[currentIndex], _confettiController2),
                        ),
                        Container(
                          width: isPortrait
                              ? MediaQuery.of(context).size.width * 0.46
                              : MediaQuery.of(context).size.width * 0.24,
                          height: isPortrait
                              ? MediaQuery.of(context).size.height * 0.29
                              : MediaQuery.of(context).size.height * 0.23,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage("assets/abcgames/images/new_button/Group.png"),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Center(
                            child: _buildTarget(context, nameList[currentIndex + 1],
                                nameList[currentIndex + 1]),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(height: screenSize.height * 0.03),
                    Divider(height: 3, color: isDarkMode ? Colors.grey : Colors.grey),
                  ],
                ),
              ),
              Stack(
                children: [
                  Container(
                    // decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2)),border: Border.all(color: Colors.pink,width: 5)),
                    color: Color.fromARGB(255, 24, 9, 0),
                    height: screenSize.height*0.28,
                    child: Stack(
                      // alignment: Alignment.topLeft,
                      children: [
                        Divider(height: 3, color: isDarkMode ? Colors.grey : Colors.grey),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildDraggable(context, nameList[currentIndex], 0),
                              if (currentIndex + 1 < nameList.length)
                                _buildDraggable(context, nameList[currentIndex + 1], 1),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: handIcon,
                          child: Container(
                            padding: EdgeInsets.only(right:screenSize.width*0.09),
                            alignment: Alignment.topRight,
                            height: screenSize.height * 0.15,
                            child: SlideTransition(position: _offsetAnimation,
                              child: Image.asset('assets/abcgames/new_gif/Hand Image.png'
                                ,
                                // color: Color.fromARGB(255, 255, 206, 191)
                                color: Color.fromARGB(255, 242, 176, 155)
                                ,),
                            ),
                          ),
                        )
                        // Positioned(
                        //   bottom: screenSize.height * 0.13,
                        //   left: screenSize.width * 0.06,
                        //   child: Visibility(
                        //     visible: handIcon,
                        //     child: Container(
                        //       decoration: BoxDecoration(border: Border.all(color: Colors.pink,width: 5)),
                        //       alignment: Alignment.topLeft,
                        //       height: screenSize.height * 0.15,
                        //       child: Image.asset(
                        //         'assets/new_gif/words1.gif',
                        //         fit: BoxFit.fill,
                        //         color: isDarkMode ? Colors.white : Colors.white,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildTarget(BuildContext context, String text, String img) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isPortrait = screenHeight > screenWidth;
    int count = int.tryParse(text) ?? 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: _buildAppleImages(count, img),
        ),
      ],
    );
  }

  Widget _buildAppleImages(int count, String image) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: screenWidth * 0.02,
      runSpacing: 3,
      children: List.generate(count, (index) {
        String fruitImage;
        if (image == "1") {
          fruitImage = fruit[2];
        } else if (image == "2") {
          fruitImage = fruit[1];
        } else if (image == "3") {
          fruitImage = fruit[0];
        } else if (image == "4") {
          fruitImage = fruit[3];
        } else if (image == "5") {
          fruitImage = fruit[4];
        } else if (image == "13") {
          fruitImage = fruit[5];
        } else if (image == "8" || image == "10") {
          fruitImage = fruit[6];
        } else if (image == "6" || image == "9") {
          fruitImage = fruit[7];
        } else if (image == "14") {
          fruitImage = fruit[8];
        }

        else if (image == "11") {
          fruitImage = fruit[9];
        } else if (image == "12") {
          fruitImage = fruit[10];
        }else if (image == "7") {
          fruitImage = fruit[11];
        }else if (image == "15") {
          fruitImage = fruit[12];
        }

        else if (image == "16") {
          fruitImage = fruit[2];
        } else {
          fruitImage = fruit[Random().nextInt(fruit.length)];
        }
        return Image.asset(
          '${fruitImage}',
          fit: BoxFit.fill,
          width: screenWidth * 0.09,
          height: screenHeight * 0.04,
        );
      }),
    );
  }

  Widget _buildDraggable(BuildContext context, String text, int index) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isPortrait = screenHeight > screenWidth;

    return Draggable<String>(
      data: text,
      feedback: Container(
        width: isPortrait
            ? MediaQuery.of(context).size.width * 0.35
            : MediaQuery.of(context).size.width * 0.24,
        height: isPortrait
            ? MediaQuery.of(context).size.height * 0.16
            : MediaQuery.of(context).size.height * 0.23,
        child: Center(
          child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        AssetImage("assets/abcgames/images/new_button/number_bg.png")),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    AutoSizeText(
                      maxLines: 1,
                      minFontSize: 8,
                      text,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.13,
                        decoration: TextDecoration.none,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 8
                          ..color = Color.fromARGB(255, 239, 206, 179),
                      ),
                    ),
                    AutoSizeText(
                      maxLines: 1,
                      minFontSize: 8,
                      text,
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: MediaQuery.of(context).size.height * 0.13,
                        color: const Color.fromARGB(255, 100, 62, 31),
                      ),
                    ),
                  ],
                ),
              )),
        ),
      ),
      childWhenDragging: Container(
        width: isPortrait
            ? MediaQuery.of(context).size.width * 0.35
            : MediaQuery.of(context).size.width * 0.23,
        height: isPortrait
            ? MediaQuery.of(context).size.height * 0.16
            : MediaQuery.of(context).size.height * 0.23,
      ),
      child: score[text] == true
          ? Container()
          : Container(
              width: isPortrait
                  ? MediaQuery.of(context).size.width * 0.35
                  : MediaQuery.of(context).size.width * 0.24,
              height: isPortrait
                  ? MediaQuery.of(context).size.height * 0.16
                  : MediaQuery.of(context).size.height * 0.23,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image:
                        AssetImage("assets/abcgames/images/new_button/number_bg.png")),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Stack(
                  children: <Widget>[
                    AutoSizeText(
                      maxLines: 1,
                      minFontSize: 8,
                      text,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.13,
                        // fontFamily: FontName.SuezOneRegular,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 8
                          ..color = Color.fromARGB(255, 241, 214, 193),
                      ),
                    ),
                    AutoSizeText(
                      maxLines: 1,
                      minFontSize: 8,
                      text,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height * 0.13,
                        // fontFamily: FontName.SuezOneRegular,
                        color: const Color.fromARGB(255, 100, 62, 31),
                      ),
                    ),
                  ],
                ),
              )
      ),
    );
  }

  Widget _buildDoneDrag(BuildContext context, String text, String img,ConfettiController confettiController,) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isPortrait = screenHeight > screenWidth;

    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          print("data~~${data}");
          if (data == text) {
            score[text] = true;
            checkCompletion();
            _playSingleConfetti(confettiController);
            // _confettiController.play();
            playAudio(data);
          }
        });
      },
      builder: (context, candidateData, rejectedData) {
        int count = int.tryParse(text) ?? 1;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image:/* score[text] == true?*/
                      // AssetImage("assets/abcgames/images/new_button/number_bg.png"):
                      AssetImage("assets/abcgames/images/new_button/icon_bg.png"),
                    ),
                  ),
                  width: isPortrait
                      ? MediaQuery.of(context).size.width * 0.35
                      : MediaQuery.of(context).size.width * 0.24,
                  height: isPortrait
                      ? MediaQuery.of(context).size.height * 0.16
                      : MediaQuery.of(context).size.height * 0.23,
                  child: Center(
                    child: Stack(
                      children: <Widget>[
                        AutoSizeText(
                          maxLines: 1,
                          minFontSize: 8,
                          score[text] == true ? text : "?",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.15,
                            fontFamily: FontName.SuravaramRegular,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 8
                              ..color = Colors.white,
                          ),
                        ),
                        AutoSizeText(
                          maxLines: 1,
                          minFontSize: 8,
                          score[text] == true ? text : "?",
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.15,
                            fontFamily: FontName.SuravaramRegular,
                            color: const Color.fromARGB(255, 101, 54, 36),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}
