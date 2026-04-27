import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

import 'package:path_provider/path_provider.dart';

import '../utils/app_theme.dart';
import '../utils/audio_manager.dart';

class CountWithPhonicsScreen extends StatefulWidget {
  const CountWithPhonicsScreen(
      {super.key,
      required this.audio,
      required this.text,
      required this.index});

  final audio;
  final String text;
  final int index;

  @override
  State<CountWithPhonicsScreen> createState() {
    return _countWithPhonicsScreen();
  }
}

class _countWithPhonicsScreen extends State<CountWithPhonicsScreen>
    with WidgetsBindingObserver {
  final List<List<String>> wordImageList = [];
  final Random _random = Random();

  final List<String> nameList = [];

  final player = AudioPlayer();
  int currentIndex = 0;
  late bool imageSlider = false;
  late bool isFadeInDownVisible = true;
  Key key = UniqueKey();
  int completionCount = 0;
  int currentImageIndex = 0;
  late bool buttonClick = true;
  final List<String> numberList = [
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
    "Twenty",
    "Twenty-one",
    "Twenty-two",
    "Twenty-three",
    "Twenty-four",
    "Twenty-five",
    "Twenty-six",
    "Twenty-seven",
    "Twenty-eight",
    "Twenty-nine",
    "Thirty",
    "Thirty-one",
    "Thirty-two",
    "Thirty-three",
    "Thirty-four",
    "Thirty-five",
    "Thirty-six",
    "Thirty-seven",
    "Thirty-eight",
    "Thirty-nine",
    "Forty",
    "Forty-one",
    "Forty-two",
    "Forty-three",
    "Forty-four",
    "Forty-five",
    "Forty-six",
    "Forty-seven",
    "Forty-eight",
    "Forty-nine",
    "Fifty",
    "Fifty-one",
    "Fifty-two",
    "Fifty-three",
    "Fifty-four",
    "Fifty-five",
    "Fifty-six",
    "Fifty-seven",
    "Fifty-eight",
    "Fifty-nine",
    "Sixty",
    "Sixty-one",
    "Sixty-two",
    "Sixty-three",
    "Sixty-four",
    "Sixty-five",
    "Sixty-six",
    "Sixty-seven",
    "Sixty-eight",
    "Sixty-nine",
    "Seventy",
    "Seventy-one",
    "Seventy-two",
    "Seventy-three",
    "Seventy-four",
    "Seventy-five",
    "Seventy-six",
    "Seventy-seven",
    "Seventy-eight",
    "Seventy-nine",
    "Eighty",
    "Eighty-one",
    "Eighty-two",
    "Eighty-three",
    "Eighty-four",
    "Eighty-five",
    "Eighty-six",
    "Eighty-seven",
    "Eighty-eight",
    "Eighty-nine",
    "Ninety",
    "Ninety-one",
    "Ninety-two",
    "Ninety-three",
    "Ninety-four",
    "Ninety-five",
    "Ninety-six",
    "Ninety-seven",
    "Ninety-eight",
    "Ninety-nine",
    "One hundred"
  ];
  final List<String> bgImage = [
    "assets/abcgames/new_gif/main_home1.png",
    "assets/abcgames/new_gif/main_home2.png",
    "assets/abcgames/new_gif/main_home3.png",
    "assets/abcgames/new_gif/main_home4.png",
  ];
  final AudioManager audioManager = AudioManager();
  late bool isSoundOn = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _manageAudio();
      // if (widget.audio == true) {
      //   if (!audioManager.isPlaying) {
      //     audioManager.playAudio(volume: 0.30);
      //   } else {
      //     audioManager.setVolume(0.30); // Adjust volume if already playing
      //   }
      // }
      // else {
      //   audioManager.pauseAudio();
      // }


      if (widget.text.isEmpty) {
        setState(() {
          _manageAudio();
        });
      } else {
        setState(() {
          _manageAudio();
        });
      }
      for (var i = 1; i <= num.parse("100"); i++) {
        nameList.add(i.toString());
      }
      if (currentIndex >= 10) {
        for (var i = 0; i < 10; i++) {
          bgImage.add("assets/abcgames/new_gif/main_home${i + 4}.png");
        }
      }
      getPaths();
      if (widget.index.toInt() == "") {
        print("First");
        playAudio(nameList[widget.index]);
      } else {
        currentIndex = widget.index - 1 % 100;
        print("firstIndex!!!!${currentIndex}");
        playAudio("${widget.index}");
      }
    });
  }

  // getPaths() async {
  //   setState(() {
  //     wordImageList.clear();
  //     for (var i = 0; i < nameList.length; i++) {
  //       String number = nameList[i];
  //       List<String> digitImagePaths = [];
  //
  //       // Split the number into its digits and collect their image paths
  //       for (var digit in number.split('')) {
  //         int colorVariation = _random.nextInt(5);
  //         digitImagePaths.add("assets/words/${digit}pink.png");
  //       }
  //
  //       // Add the list of image paths for the current number
  //       wordImageList.add(digitImagePaths);
  //     }
  //   });
  // }


  final List<String> prefixes = ['sky', 'red', 'green','brown','pink'];
  getPaths() async {
    setState(() {
      wordImageList.clear();
      for (var i = 0; i < nameList.length; i++) {
        String number = nameList[i];
        List<String> digitImagePaths = [];
        List<String> shuffledPrefixes = List.from(prefixes)..shuffle(_random);

        for (int j = 0; j < number.length; j++) {
          String digit = number[j];
          String selectedPrefix = shuffledPrefixes[j % shuffledPrefixes.length]; // Ensures unique prefix per digit
          String imagePath = "assets/abcgames/words/${selectedPrefix}_$digit.png";
          digitImagePaths.add(imagePath);
        }

        wordImageList.add(digitImagePaths);
      }
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioManager.resetVolume();
    player.stop();
    super.dispose();
  }

  backImg() {
    setState(() {
      isFadeInDownVisible = true;
      key = UniqueKey();
      currentIndex = (currentIndex - 1) % wordImageList.length;
      playAudio(nameList[currentIndex]);
      completionCount++;
      updateImage();
    });
  }

  Future<void> playAudio(String alphabet) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    var appDocPaths = appDocDir.path;
    if (widget.audio == true) {
      // player.play(UrlSource('https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3'));
      player.play(AssetSource('abcgames/audio/$alphabet.mp3'));

      // player.play(DeviceFileSource(
      //     File('$appDocPaths/my_doc/alphabet_image/audio/$alphabet.mp4').path));
      print("ALPHABET~~~~$alphabet");
    }
  }

  ///Application on Background that time call method
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // audioPlayer.setReleaseMode(ReleaseMode.loop);
      // audioPlayer.play(AssetSource('audio/low_bg.mp4'));
      setState(() {
      _manageAudio();
      isSoundOn==true;
      });
      print('\x1B[34m App in foreground\x1B[0m***********************');
    }

    else if (state == AppLifecycleState.paused) {
      audioManager.pauseAudio();
      // audioPlayer.stop();
      // audioPlayer.pause();
      print('\x1B[33m App in background\x1B[0m##################');
    }
  }

  Future<void> updateImage() async {
    if (completionCount % 10 == 0 && completionCount > 0) {
      // await Future.delayed(Duration(seconds: 2));

      setState(() {
        currentImageIndex = (currentImageIndex + 1) % bgImage.length;
      });
    }
  }

  forwardImage() {
    setState(() {
      currentIndex = (currentIndex + 1) % wordImageList.length;
      isFadeInDownVisible = true;
      key = UniqueKey();
      playAudio(nameList[currentIndex]);
      completionCount++;
      updateImage();
    });
  }


  void sound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final currentImage = bgImage[currentImageIndex];
    // audioPlayer.setReleaseMode(ReleaseMode.loop);
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/abcgames/images/new_button/back.png",
                height: screenSize.height * 0.10),
            onPressed: () {
              setState(() {
                player.stop();
                Navigator.pop(context);
              });
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
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "${currentImage}",
              ),
              fit: BoxFit.fill),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: screenSize.height * 0.15,
                    ),
                    alignment: Alignment.center,
                    child: Image.asset(
                      'assets/abcgames/new_gif/board.png',
                      height: screenSize.height * 0.43, // 40
                      width: screenSize.width * 0.78,
                      fit: BoxFit.fill,
                    ),
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          top: screenSize.height * 0.17,
                          left: screenSize.height * 0.09,
                          right: screenSize.height * 0.09),
                      child: Align(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Stack(
                            children: <Widget>[
                              AutoSizeText(
                                maxLines: 2,
                                '${numberList[currentIndex]}',
                                style: TextStyle(
                                  fontFamily: FontName.SuezOneRegular,
                                  fontSize: screenSize.height * 0.06,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 6
                                    ..color = Colors.white,
                                ),
                              ),
                              AutoSizeText(
                                maxLines: 2,
                                '${numberList[currentIndex]}',
                                style: TextStyle(
                                    fontFamily: FontName.SuezOneRegular,
                                    fontSize: screenSize.height * 0.06,
                                    color:
                                        Color.fromARGB(255, 101, 54, 36)),
                              ),
                            ],
                          ),
                        ),
                      )),
                  Container(
                    padding: EdgeInsets.only(top:currentIndex==99 ?screenSize.height * 0.38: screenSize.height * 0.34),
                    alignment: Alignment.center,
                    child: Align(
                      child: Container(
                        height:currentIndex==99 ? screenSize.height * 0.14: screenSize.height *0.21,
                        child: Swiper(
                          allowImplicitScrolling: buttonClick,
                          key: key = UniqueKey(),
                          loop: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          itemCount: nameList.length,
                          index: currentIndex,
                          itemBuilder: (BuildContext context, int index) {
                            return FadeInDown(
                              key: key,
                              animate: isFadeInDownVisible,
                              duration: const Duration(milliseconds: 900),
                              child: currentIndex < wordImageList.length
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: wordImageList[currentIndex]
                                          .map<Widget>((imagePath) {
                                        return Image(
                                          // fit: BoxFit.contain,
                                          image: AssetImage(imagePath),
                                        );
                                      }).toList(),
                                    )
                                  : Container(),
                            );
                          },
                          onIndexChanged: (int index) {
                            setState(() {
                              playAudio(nameList[index]);
                              currentIndex = index;
                              completionCount++;
                              updateImage();
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: screenSize.height * 0.24,
                child: Stack(
                  children: [
                    Swiper(
                      key: UniqueKey(),
                      loop: true,
                      itemCount: nameList.length,
                      index: currentIndex,
                      viewportFraction: 0.28,
                      onIndexChanged: (index) {
                        setState(() {
                          currentIndex = index;
                          completionCount++;
                          updateImage();
                          playAudio(nameList[index]);
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        String number = nameList[index];
                        List<Widget> digitImages =
                            number.split('').map((digit) {
                              String randomPrefix = prefixes[_random.nextInt(prefixes.length)];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                            ),
                            child: Image.asset(
                              "assets/abcgames/words/${randomPrefix}_${digit}.png",
                              height: screenSize.height *
                                  (index == currentIndex
                                      ? currentIndex == 99
                                          ? 0.06
                                          : 0.09
                                      : 0.04),
                            ),
                          );
                        }).toList();

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // Center images properly
                          children: digitImages,
                        );
                      },
                    ),
                    Positioned(
                      top: screenSize.height * 0.09,
                      left: 0,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (!imageSlider) {
                              backImg();
                            } else {
                              print("No Click..");
                            }
                          });
                        },
                        child: Image.asset(
                          "assets/abcgames/images/new_button/back.png",
                          height: screenSize.height * 0.07,
                        ),
                      ),
                    ),

                    // Custom next button
                    Positioned(
                      right: 0,
                      top: screenSize.height * 0.08,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            if (!imageSlider) {
                              forwardImage();
                            } else {
                              print("No Click..");
                            }
                          });
                        },
                        child: Image.asset(
                          "assets/abcgames/images/new_button/next_word.png",
                          height: screenSize.height * 0.07,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildText(String? text) => Container(
      color: Colors.lightBlue,
      width: MediaQuery.of(context).size.width * 0.4,
      child: FittedBox(
          child: Text(
        text.toString(),
        // ,style: TextStyle(fontSize: 64),
        maxLines: 2,
      )));
}
