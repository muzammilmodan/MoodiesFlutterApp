import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/audio_manager.dart';
import 'count_withPhonics_screen.dart';


class MiddleScreen extends StatefulWidget {
  const MiddleScreen(
      {super.key,
      required this.audio,
      required this.text,
      required this.index});

  final audio;
  final String text;
  final int index;

  @override
  State<MiddleScreen> createState() {
    return _NewHomeScreenState();
  }
}

class _NewHomeScreenState extends State<MiddleScreen>
    with WidgetsBindingObserver {
  final AudioManager audioManager = AudioManager();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setState(() {
      _manageAudio();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    audioManager.resetVolume();
    super.dispose();
  }
  void _manageAudio() {
    setState(() {
      if (widget.audio== true) {
        audioManager.playAudio();
      }
          else {
          // audioManager.pauseAudio();
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
    final screenSize = MediaQuery.of(context).size;
    print("@@@@${screenSize.height * 0.70}");
    // player.setReleaseMode(ReleaseMode.loop);
    return Scaffold(
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/abcgames/images/new_button/back.png",
                height: screenSize.height * 0.11),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                "assets/abcgames/new_gif/main_home1.png",
              ),
              fit: BoxFit.fill),
        ),
        child: Column(
          children: [
            Container(
              height: screenSize.height * 0.09,
            ),
            Container(
              height: screenSize.height * 0.70,
              child: Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 15,
                  runSpacing: 10,
                  children: List.generate(10, (index) {
                    int start = index * 10 + 1;
                    int end = start + 9;

                    return Container(
                      width: screenSize.width * 0.45,
                      height: screenSize.height*0.12,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/abcgames/new_gif/second_board.png",),fit: BoxFit.fill
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return CountWithPhonicsScreen(
                                text: " ",
                                index: start,
                                audio: widget.audio,
                              );
                            },
                          ));
                        },
                        child: Center(
                          child: Stack(
                            children: <Widget>[
                              AutoSizeText(
                                maxLines: 1,
                                '$start to $end',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontName.SuezOneRegular,
                                  fontSize: screenSize.height * 0.05,
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.white,
                                ),
                              ),
                              AutoSizeText(
                                maxLines: 1,
                                '$start to $end',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: FontName.SuezOneRegular,
                                  fontSize: screenSize.height * 0.05,
                                  color: Color.fromARGB(255, 101, 54, 36),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
