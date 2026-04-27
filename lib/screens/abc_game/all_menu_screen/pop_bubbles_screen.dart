import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

import '../utils/app_theme.dart';
import '../utils/appcolor.dart';
import '../utils/audio_manager.dart';


class PopBubblesScreen extends StatefulWidget {
  PopBubblesScreen({
    required this.letterName,
    required this.audio,
    required this.index,
  });

  final audio;
  final letterName;
  int index;

  @override
  State<PopBubblesScreen> createState() {
    return _popBubblesScreenState();
  }
}

class _popBubblesScreenState extends State<PopBubblesScreen>{
  final player = AudioPlayer();
  late ConfettiController _confettiController;
  bool isClicked = false;
  Map<int, bool> containerClicked = {};
  bool confettiDisplayed = false;
  int? clickedIndex;
  Key key = UniqueKey();
  final List<String> wordImageList = [];

  final List<String> bigList = [];
  late List<int> counter = [];
  bool isAnyContainerClicked = false;
  List<String> shuffledBigList = [];
  final Map<int, String> numberToWord  = {
    1: 'One', 2: 'Two', 3: 'Three', 4: 'Four', 5: 'Five',
    6: 'Six', 7: 'Seven', 8: 'Eight', 9: 'Nine', 10: 'Ten',
    11: 'Eleven', 12: 'Twelve', 13: 'Thirteen', 14: 'Fourteen', 15: 'Fifteen',
    16: 'Sixteen', 17: 'Seventeen', 18: 'Eighteen', 19: 'Nineteen', 20: 'Twenty',
    21:"Twenty-One",22:"Twenty-Two",23:"Twenty-Three",24:"Twenty-Four",25:"Twenty-Five",26:"Twenty-Six",
    27:"Twenty-Seven",28:"Twenty-Eight",29:"Twenty-Nine",30:"Thirty",
    31:"Thirty-One",32:"Thirty-Two",33:"Thirty-Three",34:"Thirty-Four",35:"Thirty-Five",
    36:"Thirty-Six",37:"Thirty-Seven",38:"Thirty-Eight",39:"Thirty-Nine",40:"Fourteen",
    41:"Forty-One",42:"Forty-Two",43:"Forty-Three",45:"Forty-Five",
    46:"Forty-Six",47:"Forty-Seven",48:"Forty-Eight",49:"Forty-Nine",50:"Fifty",
    51:"Fifty-One",52:"Fifty-Two",53:"Fifty-Three",54:"Fifty-Four",55:"Fifty-Five"
    ,56:"Fifty-Six",57:"Fifty-Seven",58:"Fifty-Eight",59:"Fifty-nine",60:"Sixty",
    61:"Sixty-One",62:"Sixty-Two",63:"Sixty-Three",64:"Sixty-Four",65:"Sixty-Five"
    ,66:"Sixty-Six",67:"Sixty-Seven",68:"Sixty-Eight",69:"Sixty-Nine",70:"Seventy",
    71:"Seventy-One",72:"Seventy-Two",73:"Seventy-Three",74:"Seventy-Four",75:"Seventy-Five",
    76:"Seventy-Six",77:"Seventy-Seven",78:"Seventy-Eight",79:"Seventy-Nine",80:"Eighty",
    81:"Eighty-One",82:"Eighty-Two",83:"Eighty-Three",84:"Eighty-Four",85:"Eighty-Five",
    86:"Eighty-Six",87:"Eighty-Seven",88:"Eighty-Eight",89:"Eighty-Nine",90:"Ninety",
    91:"Ninety-One",92:"Ninety-Two",93:"Ninety-Three",94:"Ninety-Four",95:"Ninety-Five",
    96:"Ninety-Six",97:"Ninety-Seven",98:"Ninety-Eight",99:"Ninety-Nine",100:"Hundred"
  };
  late Map<String, int> wordToNumber ;
  final AudioManager audioManager = AudioManager();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      audioManager.pauseAudio();
      // wordToNumbers= numberToWord.map((k, v) => MapEntry(v, k));
      _confettiController =
          ConfettiController(duration: const Duration(seconds: 1));
      _confettiController.stop();
      wordToNumber = numberToWord.map((k, v) => MapEntry(v, k));
      // for (int i = 1; i <= num.parse("100"); i++) {
      for (int i = 1; i <= 100; i++) {
        // bigList.add(i.toString());
        shuffledBigList.add(i.toString());
      }
      // shuffledBigList = List.from(bigList)..shuffle();
      shuffledBigList.shuffle();
    });
  }

  void handleItemClick(int index) {
    if (!isAnyContainerClicked && !containerClicked[index]!) {
      setState(() {
        isAnyContainerClicked = true;
        counter.add(1);
        clickedIndex = index;
        confettiDisplayed = true;
      });
      _confettiController.play();
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          confettiDisplayed = false;
          clickedIndex = null;
          _confettiController.stop();
          isAnyContainerClicked = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    audioManager.resetVolume();
    player.stop();
    super.dispose();
  }

  void playAudio(String value) {
    String audioPath;
    if (int.tryParse(value) != null) {
      // It's a digit
      audioPath = 'abcgames/audio/$value.mp3';
    } else if (wordToNumber.containsKey(value)) {
      // It's a word
      audioPath = 'abcgames/audio/${wordToNumber[value]}.mp3';
    } else {
      // Handle error case where word is not in the mapping
      print("Error: No matching audio file for value $value");
      return;
    }

    // Now play the audio using the constructed audioPath
    print("AUDIO!!!!$audioPath");
    // Add the actual audio playing logic here, for example:
    // AudioPlayer().play(audioPath as Source);
    player.play(AssetSource("$audioPath"));
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
  // ///Application on Background that time call method
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     _manageAudio();
  //     print('\x1B[34m App in foreground\x1B[0m***********************');
  //   }
  //
  //   else if (state == AppLifecycleState.paused) {
  //     audioManager.pauseAudio();
  //     print('\x1B[33m App in background\x1B[0m##################');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final mediumSize = MediaQuery.of(context).size.width * 0.3;
    final smallSize = MediaQuery.of(context).size.width * 0.2;
    final bigSize = MediaQuery.of(context).size.width * 0.5;
    print("mediumSize${screenSize.height * 0.01}");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            elevation: 0,
            backgroundColor: Colors.transparent,
            // backgroundColor: Colors.transparent,
            child: Image.asset("assets/abcgames/images/new_button/word_home.png",
                height: 90),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FloatingActionButton(
                heroTag: "btn2",
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Image.asset(
                  "assets/abcgames/images/new_button/word_back.png",
                ),
                onPressed: () {
                  setState(() {
                    int index = (widget.index - 1) % 26;
                    wordImageList.addAll(List.generate(
                      26,
                      (index) => '${String.fromCharCode(97 + index)}',
                    ));
                    print("NEWINDEX~~${index}");
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PopBubblesScreen(
                            audio: widget.audio,
                            index: index,
                            letterName: wordImageList[index],
                          );
                        },
                      ),
                    );
                  });
                },
              ),
              FloatingActionButton(
                heroTag: "btn3",
                elevation: 0,
                backgroundColor: Colors.transparent,
                child: Image.asset("assets/abcgames/images/new_button/word_next.png",
                    height: 90),
                onPressed: () {
                  setState(() {
                    int index = (widget.index + 1) % 26;
                    wordImageList.addAll(List.generate(
                      26,
                      (index) => '${String.fromCharCode(97 + index)}',
                    ));
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PopBubblesScreen(
                            audio: widget.audio,
                            index: index,
                            letterName: wordImageList[index],
                          );
                        },
                      ),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage(
              "assets/abcgames/new_gif/word_bg.png",
            ),
            // fit: BoxFit.fill,
          ),
        ),
        child: Swiper(
          allowImplicitScrolling: true,
          loop: true,
          itemCount: 10,
          index: widget.index,
          itemBuilder: (BuildContext context, int index) {
            List<String?> displayList = [];
            if (index < 5) {
              displayList = shuffledBigList.sublist(0, 10);
              print("displayList!!${displayList}");
             } else if (index < 5) {
               displayList = shuffledBigList.sublist(10, 20).map((e) => numberToWord[int.parse(e)]).toList();
            }
           else {
              displayList = shuffledBigList.sublist(20, 30).map((e) => numberToWord[int.parse(e)]).toList();
              // print("displayList##${shuffledBigList.sublist(10,20)}");
              if (numberToWord.keys.contains(index)) {
                print("INTVALUE${index}");
              }
            }

            // List<String?> displayList = [];
            // if (index < 5) {
            //   displayList = shuffledBigList.sublist(0, 10);
            // } else if (index < 10) {
            //   displayList = shuffledBigList.sublist(10, 15).map((e) => numberToWord[int.parse(e)]).toList();
            // } else if (index < 15) {
            //   displayList = shuffledBigList.sublist(15, 20).map((e) => numberToWord[int.parse(e)]).toList();
            // } else {
            //   displayList = shuffledBigList.sublist(20, 25).map((e) => numberToWord[int.parse(e)]).toList();
            // }
            return ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenSize.height * 0.04,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(width: screenSize.height * 0.02),
                          container(
                            // texts: shuffledBigList[1],
                            texts: displayList[0].toString(),
                            // padding: EdgeInsets.all(screenSize.height * 0),
                            // padding: EdgeInsets.only(left:screenSize.width * 0.03,),
                            width: mediumSize,
                            height: mediumSize,
                            i: index * 0 + 1,
                            onItemClick: () {
                              print("AUDIO!!!!${displayList[0].toString()}");
                              playAudio(displayList[0].toString());
                              handleItemClick(index * 0 + 1);
                              confettiDisplayed = true;
                            },
                          ),
                          SizedBox(
                            width: screenSize.height * 0.02,
                          ),
                          Column(
                            children: [
                              container(
                                // texts: shuffledBigList[2],
                                texts: displayList[1].toString(),
                                // padding: EdgeInsets.all(screenSize.height * 0),
                                width: smallSize,
                                height: smallSize,
                                i: index * 0 + 2,
                                onItemClick: () {
                                  print("2");
                                  playAudio(displayList[1].toString());
                                  handleItemClick(index * 0 + 2);
                                  confettiDisplayed = true;
                                },
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: screenSize.height * 0.05,
                                      right: screenSize.height * 0.05),
                                  child: Container(
                                    width: screenSize.width * 0.06,
                                    height: screenSize.width * 0.06,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          width: 4,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Colors.white),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/abcgames/images/word_img/gradient_img.png"),
                                        repeat: ImageRepeat.repeat,
                                      ),
                                    ),
                                  )
                              )
                            ],
                          ),
                          Padding(
                            padding:
                                EdgeInsets.only(top: screenSize.height * 0.08),
                            child: container(
                              // texts: shuffledBigList[3],
                              texts: displayList[2].toString(),
                              // padding: EdgeInsets.all(screenSize.width * 0.03),
                              width: mediumSize,
                              height: mediumSize,
                              i: index * 0 + 3,
                              onItemClick: () {
                                print(""
                                    "3");
                                playAudio(displayList[2].toString());
                                handleItemClick(index * 0 + 3);
                                confettiDisplayed = true;
                                _confettiController.play();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Image.asset(
                              "assets/abcgames/images/word_img/1.png",
                              height: screenSize.height * 0.10,
                              // width: screenSize.width * 0.10,
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(
                                    top: screenSize.height * 0.11,
                                  ),
                                  child: Container(
                                    width: screenSize.width * 0.04,
                                    height: screenSize.width * 0.04,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          width: 4,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Colors.white),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/abcgames/images/word_img/gradient_img.png"),
                                        repeat: ImageRepeat.repeat,
                                      ),
                                    ),
                                  )),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: screenSize.height * 0.07),
                                child: container(
                                  // texts: shuffledBigList[4],
                                  texts: displayList[3].toString(),
                                  // padding: EdgeInsets.only(left:screenSize.width * 0.04,right: screenSize.width*0.04),
                                  width: bigSize,
                                  height: bigSize,
                                  i: index * 0 + 4,
                                  // isClickable: !isAnyItemClicked,
                                  onItemClick: () {
                                    print("4");
                                    playAudio(displayList[3].toString());
                                    handleItemClick(index * 0 + 4);
                                    confettiDisplayed = true;
                                    _confettiController.play();
                                  },
                                ),
                              ),
                              Padding(
                                  padding: EdgeInsets.only(
                                      top: screenSize.height * 0.02,
                                      left: screenSize.height * 0.04),
                                  child: Container(
                                    width: screenSize.width * 0.07,
                                    height: screenSize.width * 0.07,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          width: 4,
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: Colors.white),
                                      image: DecorationImage(
                                        image: AssetImage(
                                            "assets/abcgames/images/word_img/gradient_img.png"),
                                        repeat: ImageRepeat.repeat,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                              alignment: Alignment.topLeft,
                              child: Image.asset(
                                "assets/abcgames/images/word_img/1.png",
                                height: screenSize.height * 0.12,
                              )),
                          Padding(
                            padding:
                                EdgeInsets.only(top: screenSize.height * 0.05),
                            child: container(
                              // texts: shuffledBigList[5],
                              texts: displayList[4].toString(),
                              // padding: EdgeInsets.all(screenSize.width * 0),
                              width: smallSize,
                              height: smallSize,
                              i: index * 0 + 5,
                              onItemClick: () {
                                print("5");
                                playAudio(displayList[4].toString());
                                handleItemClick(index * 0 + 5);
                                _confettiController.play();
                                confettiDisplayed = true;
                              },
                            ),
                          ),
                          container(
                            texts: displayList[5].toString(),
                            // padding: EdgeInsets.all(screenSize.height * 0),
                            width: smallSize,
                            height: smallSize,
                            i: index * 0 + 6,
                            // isClickable: !isAnyItemClicked,
                            onItemClick: () {
                              playAudio(displayList[5].toString());
                              handleItemClick(index * 0 + 6);
                              _confettiController.play();
                              confettiDisplayed = true;
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          container(
                            // texts: shuffledBigList[7],
                            texts: displayList[6].toString(),
                            // padding: EdgeInsets.all(screenSize.height * 0),
                            width: smallSize,
                            height: smallSize,
                            i: index * 0 + 7,
                            onItemClick: () {
                              playAudio(displayList[6].toString());
                              handleItemClick(index * 0 + 7);
                              _confettiController.play();
                              confettiDisplayed = true;
                            },
                          ),
                          container(
                            texts: displayList[7].toString(),
                            // padding: EdgeInsets.all(screenSize.width * 0),
                            width: mediumSize,
                            height: mediumSize,
                            i: index * 0 + 8,
                            onItemClick: () {
                              playAudio(displayList[7].toString());
                              handleItemClick(index * 0 + 8);
                              _confettiController.play();
                              confettiDisplayed = true;
                            },
                          ),
                        ],
                      ),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            container(
                              texts: displayList[8].toString(),
                              // padding: EdgeInsets.all(screenSize.height * 0),
                              width: smallSize,
                              height: smallSize,
                              i: index * 0 + 9,
                              onItemClick: () {
                                playAudio(displayList[8].toString());
                                handleItemClick(index * 0 + 9);
                                _confettiController.play();
                                confettiDisplayed = true;
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenSize.height * 0.02),
                              child: container(
                                  texts: displayList[9].toString(),
                                  // padding:
                                  //     EdgeInsets.all(screenSize.width * 0),
                                  width: mediumSize,
                                  height: mediumSize,
                                  i: index * 0 + 10,
                                  onItemClick: () {
                                    playAudio(displayList[9].toString());
                                    handleItemClick(index * 0 + 10);
                                    _confettiController.play();
                                  }),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Image.asset(
                                "assets/abcgames/images/word_img/5.png",
                                height: screenSize.height * 0.12,
                              ),
                            ),
                          ]),
                    ],
                  );
                });
          },
          onIndexChanged: (int index) {
            counter.clear();
            wordImageList.addAll(List.generate(
              26,
              (index) => '${String.fromCharCode(97 + index)}',
            ));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return PopBubblesScreen(
                    audio: widget.audio,
                    index: index,
                    letterName: wordImageList[index],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  GestureDetector container({
    required String texts,
    required int i,
    required VoidCallback onItemClick,
    // required EdgeInsets padding,
    required double width,
    required double height,
  }) {
    final screenSize = MediaQuery.of(context).size;
    print("font${screenSize.height * 0.04}");
    if (!containerClicked.containsKey(i)) {
      containerClicked[i] = false;
    }

    return GestureDetector(
      onTap: !isAnyContainerClicked && !containerClicked[i]!
          ? () {
              print("");
              print("counter!!~~~~${counter.length == 9}");
              if (counter.length == 9) {
                int index = (widget.index + 1) % 26;
                print("NEWINDEX~~${index}");
                wordImageList.addAll(List.generate(
                  26,
                  (index) => '${String.fromCharCode(97 + index)}',
                ));
                Future.delayed(Duration(seconds: 1), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return PopBubblesScreen(
                          audio: widget.audio,
                          index: index,
                          letterName: wordImageList[index],
                        );
                      },
                    ),
                  );
                });

                counter.clear();
              }
              if (clickedIndex == null || clickedIndex == i) {
                onItemClick();
              }
              setState(() {
                containerClicked[i] = true;
              });
              if (!isClicked) {
                isClicked = true;
                onItemClick();
                _confettiController.play();
                print("CLICKINDEX~~~~${i}");
              }
            }
          : null,
      // onTap: isClickable ? onItemClick : null,
      child: Stack(
        children: [
          ZoomOut(
            animate: containerClicked[i]!,
            duration: const Duration(milliseconds: 1500), //1500
            child: Container(
                // padding: padding,
                width: width,
                height: height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                      width: 6,
                      strokeAlign: BorderSide.strokeAlignOutside,
                      color: Colors.white),
                  image: DecorationImage(
                    image:
                        AssetImage("assets/abcgames/images/word_img/gradient_img.png"),
                    repeat: ImageRepeat.repeat,
                  ),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(screenSize.width*0.03),
                        child: AutoSizeText(
                          wrapWords: true,
                          maxLines: 2,
                          "$texts",
                          style: TextStyle(
                            fontFamily: FontName.Chiki,
                            fontSize: screenSize.height * 0.06,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 1
                              ..color = Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(screenSize.width*0.03),
                        child: AutoSizeText(
                          wrapWords: true,
                          maxLines: 2,
                          "$texts",
                          style: TextStyle(
                            color: AppColor.wordText,
                            fontFamily: FontName.Chiki,
                            fontSize: screenSize.height * 0.06,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          if (confettiDisplayed && clickedIndex == i /*containerClicked[i]!*/)
            Positioned.fill(
              child: Align(
                child: ConfettiWidget(
                  confettiController: _confettiController,
                  blastDirectionality: BlastDirectionality.explosive,
                  shouldLoop: false,
                  colors: const [
                    Colors.blueAccent,
                    Colors.green,
                    Colors.amberAccent,
                    Colors.pink,
                  ],
                  blastDirection: -pi / 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 8,
                  gravity: 0.03,
                  createParticlePath: (size) {
                    final path = Path();
                    path.addOval(
                        Rect.fromCircle(center: Offset.zero, radius: 10));
                    return path;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
