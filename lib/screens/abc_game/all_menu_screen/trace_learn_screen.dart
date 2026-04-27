import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

import '../utils/app_theme.dart';
import '../utils/audio_manager.dart';


class TraceLearnScreen extends StatefulWidget {
  const TraceLearnScreen({required this.audio});

  final audio;

  @override
  State<TraceLearnScreen> createState() => _traceLearnScreenState();
}

class _traceLearnScreenState extends State<TraceLearnScreen> with WidgetsBindingObserver {
  final DrawingController _drawingController = DrawingController();
  final TransformationController _transformationController =
      TransformationController();
  final List<String> nameList =
      List.generate(100, (index) => (index + 1).toString());
  int _currentIndex = 0;
  double _penThickness = 11.25;
  Color _penColor = Colors.red;
  Offset? currentTouch;
  //List<List<ui.Picture>> wordImageList = [];
  GlobalKey _containerKey = GlobalKey();
  GlobalKey _rowKey = GlobalKey();
  GlobalKey _sizeBoxKey = GlobalKey();
  late double fistConSize = 0;
  final player = AudioPlayer();
  final AudioManager audioManager = AudioManager();
  late bool isSoundOn = true;




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _manageAudio();
     // _loadSvg();
      playAudio(nameList[_currentIndex]);
      Future.delayed(Duration(microseconds: 1), () {
        _getContainerHeight();
      });
    });
  }

  void _getContainerHeight() {
    final RenderBox? renderBoxs =
        _rowKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? renderBo =
        _sizeBoxKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? renderBox =
        _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      setState(() {
        fistConSize = renderBox.size.height;
        print("fistConSize~~${fistConSize}");
      });
    }
  }

  // Future<void> _loadSvg() async {
  //   wordImageList.clear();
  //   for (var number in nameList) {
  //     List<ui.Picture> digitPictures = [];
  //
  //     for (var digit in number.split('')) {
  //       final String svgPath = "assets/draw_img/$digit.svg";
  //       final String svgString = await rootBundle.loadString(svgPath);
  //     //  final DrawableRoot svgRoot = await svg.fromSvgString(svgString, "");
  //      // final DrawableRoot svgRoot = await svgParser.parse(svgString, warningsAsErrors: false);
  //
  //       //ui.Picture digitPicture = svgRoot.toPicture();
  //
  //     //  digitPictures.add(digitPicture);
  //     }
  //
  //     wordImageList.add(digitPictures);
  //   }
  // }

  Future<void> playAudio(String letter) async {
    if (widget.audio == true) {
      player.play(AssetSource('abcgames/audio/$letter.mp3'));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _drawingController.dispose();
    audioManager.resetVolume();
    player.stop();
    super.dispose();
  }

  void _onShare(BuildContext context, Uint8List drawData) async {
    try {
      final box = context.findRenderObject() as RenderBox?;

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/drawing.png';

      final file = await File(filePath).writeAsBytes(drawData);

      await Share.shareXFiles(
        [
          XFile(filePath, name: 'drawing.png', mimeType: 'image/png'),
        ],
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    } catch (e) {
      debugPrint('Error sharing the image: $e');
    }
  }

  Future<void> _getImageData() async {
    final Uint8List? data =
        (await _drawingController.getImageData())?.buffer.asUint8List();
    if (data == null) {
      debugPrint('Failed to get image data');
      return;
    }

    if (mounted) {
      showModalBottomSheet<void>(
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        useSafeArea: true,
        context: context,
        builder: (BuildContext c) {
          return BottomSheet(
            onClosing: () {},
            builder: (BuildContext context) {
              return Container(
                height: MediaQuery.of(context).size.height,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                                "assets/abcgames/images/new_button/draw_board.png"),
                            fit: BoxFit.fill),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Image(
                              image: AssetImage(
                                  "assets/abcgames/images/new_button/back.png"),
                              fit: BoxFit.fill,
                              height: MediaQuery.of(context).size.height * 0.07,
                            ),
                          ),
                          Text(
                            "MY TRACING",
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.04,
                              color: Color.fromARGB(255, 206, 171, 54),
                              fontFamily: FontName.grobold,
                            ),
                          ),
                          InkWell(
                              onTap: () {
                                _onShare(context, data);
                              },
                              child: Image(
                                image: AssetImage(
                                    "assets/abcgames/images/new_button/share.png"),
                                height:
                                    MediaQuery.of(context).size.height * 0.07,
                              ))
                        ],
                      ),
                    ),
                    Center(
                      child: InkWell(
                          onTap: () => Navigator.pop(c),
                          child: Image.memory(data)),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }
  }

  void _changePenColor(Color color) {
    setState(() {
      _penColor = color;
      _updateDrawingStyle();
    });
  }

  void _updateDrawingStyle() {
    _drawingController.setStyle(color: _penColor, strokeWidth: _penThickness);
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
  void sound() {
    setState(() {
      isSoundOn = !isSoundOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print("size**${screenSize.height * 0.51}");
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
            top: screenSize.height * 0.0, left: 8.0, right: 8.0),
        child: Row(
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
            Flexible(
              child: AutoSizeText(
                "Tracing ",
              minFontSize: 18,
              maxLines: 2,
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.09,
                  color: isDarkMode
                      ? Color.fromARGB(255, 255, 255, 255)
                      : Color.fromARGB(255, 166, 63, 30),
                  fontFamily: FontName.Chiki,
                ),
              ),
            ),
            Row(
              children: [
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
                FloatingActionButton(
                  heroTag: "4",
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  onPressed: _getImageData,
                  child: Image.asset("assets/abcgames/images/new_button/right.png",
                      fit: BoxFit.fill, height: screenSize.height * 0.07),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        decoration: isDarkMode
            ? const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      "assets/abcgames/new_gif/tracing_bg.png",
                    ),
                    fit: BoxFit.contain))
            : null,
        child: Column(
          children: [
            Container(
              height: screenSize.height * 0.12,
            ),
            Column(
              children: [
                Padding(
                  key: _rowKey,
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      InkWell(
                          onTap: () {
                            _drawingController.undo();
                          },
                          child: Image(
                            image:
                                AssetImage("assets/abcgames/images/new_button/undo.png"),
                            height: screenSize.height * 0.06,
                          )),
                      InkWell(
                          onTap: () {
                            _drawingController.redo();
                          },
                          child: Image(
                            image:
                                AssetImage("assets/abcgames/images/new_button/redo.png"),
                            height: screenSize.height * 0.06,
                          )),
                    ],
                  ),
                ),
                SizedBox(
                  height: screenSize.height * 0.5,
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: LayoutBuilder(
                          key: UniqueKey(),
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            return Listener(
                              onPointerDown: (event) {
                                setState(() {
                                  currentTouch = event.localPosition;
                                });
                              },
                              onPointerMove: (event) {
                                setState(() {
                                  currentTouch = event.localPosition;
                                });
                              },
                              onPointerUp: (_) {
                                setState(() {
                                  currentTouch = null;
                                });
                              },
                              child: Stack(
                                children: [
                                  DrawingBoard(
                                    boardBoundaryMargin: EdgeInsets.all(0),
                                    key: UniqueKey(),
                                    transformationController:
                                        _transformationController,
                                    controller: _drawingController,
                                    background: Container(
                                      width: screenSize.width * 0.98,
                                      height: screenSize.height * 0.5,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/abcgames/draw_img/${(_currentIndex + 1).toString()[0]}.svg",
                                              height:_currentIndex==99 ? screenSize.height*0.18: screenSize.height * 0.2,
                                            ),
                                            if ((_currentIndex + 1)
                                                    .toString()
                                                    .length >
                                                1)
                                              SvgPicture.asset(
                                                "assets/abcgames/draw_img/${(_currentIndex + 1).toString()[1]}.svg",
                                                height:_currentIndex==99 ? screenSize.height*0.18: screenSize.height * 0.2,
                                              ),
                                            if ((_currentIndex + 1)
                                                .toString()
                                                .length >
                                                2)
                                              SvgPicture.asset(
                                                "assets/abcgames/draw_img/${(_currentIndex + 1).toString()[2]}.svg",
                                                height:_currentIndex==99 ? screenSize.height*0.18: screenSize.height * 0.2,
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    showDefaultActions: false,
                                    showDefaultTools: false,
                                  ),
                                  if (currentTouch != null)
                                    Positioned(
                                      left: currentTouch!.dx -
                                          screenSize.height * 0.02,
                                      top: currentTouch!.dy -
                                          screenSize.height * 0.08,
                                      child: Icon(
                                        Icons.star,
                                        size: screenSize.height * 0.07,
                                        color: Colors.yellow,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.all(8),
              padding: EdgeInsets.only(left: 9, right: 9),
              height: screenSize.height * 0.10,
              child: Stack(
                children: [
                  Swiper(
                    key: UniqueKey(),
                    loop: true,
                    itemCount: nameList.length,
                    index: _currentIndex,
                    viewportFraction: 0.28,
                    // viewportFraction: 1 / 4,
                    onIndexChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                        _drawingController.clear();
                        playAudio(nameList[index]);
                      });
                    },
                    itemBuilder: (BuildContext context, int index) {
                      String number = nameList[index];
                      double fontSize = index == _currentIndex
                          ?_currentIndex==99 ?screenSize.height*0.06: screenSize.height * 0.09
                          : screenSize.height * 0.04;
                      BoxDecoration boxDec() {
                        return BoxDecoration(
                          color: Color.fromARGB(255, 255, 225, 209),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              width: 1,
                              color: Color.fromARGB(255, 159, 96, 56)),
                        );
                      }

                      Color color = Color.fromARGB(255, 255, 200, 33);
                      // Color colorS = Color.fromARGB(255, 204, 122, 41);
                      Color colorS = Color.fromARGB(255, 255, 200, 33);
                      return Container(
                        decoration: index == _currentIndex ? boxDec() : null,
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              AutoSizeText(
                                maxLines: 1,
                                minFontSize: 6,
                                number,
                                style: TextStyle(
                                  fontFamily: FontName.grobold,
                                  fontSize: fontSize,
                                  decoration: TextDecoration.none,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 7
                                    ..color = index == _currentIndex
                                        ? Color.fromARGB(255, 204, 122, 41)
                                        : Color.fromARGB(255, 218, 120, 38),
                                ),
                              ),
                              AutoSizeText(
                                maxLines: 1,
                                minFontSize: 6,
                                number,
                                style: TextStyle(
                                  fontFamily: FontName.grobold,
                                  decoration: TextDecoration.none,
                                  fontSize: fontSize,
                                  color:
                                      index == _currentIndex ? colorS : color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: screenSize.height * 0.01,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _drawingController.clear();
                          _currentIndex = (_currentIndex - 1) % nameList.length;
                          playAudio(nameList[_currentIndex]);
                        });
                      },
                      child: Image.asset(
                        "assets/abcgames/images/new_button/draw_prev.png",
                        height: screenSize.height * 0.06,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: screenSize.height * 0.01,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _drawingController.clear();
                          _currentIndex = (_currentIndex + 1) % nameList.length;
                          playAudio(nameList[_currentIndex]);
                        });
                      },
                      child: Image.asset(
                        "assets/abcgames/images/new_button/draw_next.png",
                        height: screenSize.height * 0.06,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenSize.height * 0.03),
              child: Container(
                height: screenSize.height * 0.10,
                // width: screenSize.height * 0.61,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                          "assets/abcgames/new_gif/first_boards.png",
                        ),
                        fit: BoxFit.fill)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () async {
                          Color? selectedColor = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Select Color'),
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    pickerColor: _penColor,
                                    onColorChanged: (color) {
                                      Navigator.pop(context, color);
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                          if (selectedColor != null) {
                            _changePenColor(selectedColor);
                          }
                        },
                        child: Image(
                          image:
                              AssetImage("assets/abcgames/images/new_button/paint.png"),
                          width: screenSize.height * 0.06,
                          height: screenSize.height * 0.06,
                        )),
                    Slider(
                      min: 1.0,
                      max: 28.0,
                      overlayColor: MaterialStatePropertyAll(Colors.white60),
                      inactiveColor: Colors.white,
                      activeColor: Color.fromARGB(255, 240, 166, 119),
                      value: _penThickness,
                      label: _penThickness.toString(),
                      onChanged: (value) {
                        setState(() {
                          _penThickness = value;
                          _updateDrawingStyle();
                        });
                      },
                    ),
                    InkWell(
                        onTap: () {
                          _drawingController.clear();
                        },
                        child: Image(
                          image:
                              AssetImage("assets/abcgames/images/new_button/close.png"),
                          width: screenSize.height * 0.06,
                          height: screenSize.height * 0.06,
                        )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
