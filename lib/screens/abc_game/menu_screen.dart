import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moodiesapp/screens/abc_game/utils/audio_manager.dart';

import '../../utils/navigation_service.dart';
import '../childs/home_kids_screen.dart';
import 'all_menu_screen/drag_match_number_block_screen.dart';
import 'all_menu_screen/jigsaw_puzzle_screen.dart';
import 'all_menu_screen/middle_screen.dart';
import 'all_menu_screen/pop_bubbles_screen.dart';
import 'all_menu_screen/trace_learn_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key,  required this.audio,});
  final audio;
  @override
  State<MenuScreen> createState() {
    return _menuScreen();
  }
}

class _menuScreen extends State<MenuScreen>with WidgetsBindingObserver {
  Key key = UniqueKey();
  String value="";
  late bool downloadFileLoader = false;
  String downloadTime = "";
  String extractionTime = "";
  final AudioManager audioManager = AudioManager();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      WidgetsBinding.instance.addObserver(this);
      key = UniqueKey();
    });
  }
  void _manageAudio() {
    setState(() {
      if (widget.audio== true) {
        audioManager.playAudio();
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
    super.dispose();
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
    final screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterTop,
      floatingActionButton: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FloatingActionButton(
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Image.asset("assets/abcgames/images/new_button/back.png"
                ,fit: BoxFit.fill),
            onPressed: () {
              setState(() {
//                Navigator.pop(context);

                NavigationService().pushAndRemoveAll(const HomeKidsScreen());
                // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                //   return MySplashPage();
                // },), (route) => false);
              });
            },
          ),

          FloatingActionButton(
            elevation: 0,
            heroTag: "1",
            backgroundColor: Colors.transparent,
            child: Image.asset(
              "assets/abcgames/images/new_button/close.png",
              height: MediaQuery.of(context).size.height * 0.06,
            ),
            onPressed: () {
              showQuiteDialog(context);
            },
          )

          // FloatingActionButton(
          //   elevation: 0,
          //   heroTag: "1",
          //   backgroundColor: Colors.transparent,
          //   child: Image.asset("assets/abcgames/images/new_button/close.png",
          //     height: MediaQuery.of(context).size.height*0.06,),
          //   onPressed: () {
          //     setState(() {
          //       SystemNavigator.pop();
          //     });
          //   },
          // ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              "assets/abcgames/new_gif/main_home1.png",
            ),
            fit: BoxFit.fill,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: screenHeight*0.17,bottom: screenHeight*0.08),
            child: Container(
              decoration: const BoxDecoration(image:
              DecorationImage(image: AssetImage("assets/abcgames/new_gif/setting.png"),fit: BoxFit.fill)),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth*0.20,vertical: screenHeight*0.07),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight*0.05,),
                      InkWell(
                        child: Image.asset(
                          "assets/abcgames/images/setting_button/auto_play.png",
                        ),
                        onTap: () {
                          // player.pause();
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return MiddleScreen(
                              text: "",
                              index: 0,
                              audio: widget.audio,
                            );
                          },));
                        },
                      ),InkWell(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return DragMatchNumberBlockScreen(letterName: "a",audio: widget.audio,index: 1);
                          },));
                        },
                        child: Image.asset(
                          "assets/abcgames/images/setting_button/drag.png",
                        ),
                      ),
                      InkWell(
                        onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return PopBubblesScreen(index: 0,
                                audio: widget.audio,
                                letterName: "a",);
                            },));
                        },
                        child: Image.asset(
                          "assets/abcgames/images/setting_button/word.png",
                        ),
                      ),
                      InkWell(
                        onTap: () {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) {
                              return TraceLearnScreen(audio: widget.audio,);
                            },));
                          },
                        child: Image.asset(
                          "assets/abcgames/images/setting_button/tracing.png",
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) {
                            return JigsawPuzzleScreen(audio: widget.audio,);
                            // return MyHomePage();
                          },));
                        },
                        child: Image.asset(
                          "assets/abcgames/images/setting_button/puzzle.png",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> showQuiteDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon bubble
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD5D0F8), Color(0xFFB0A8F0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('👋', style: TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              const Text(
                'Do you want to Quit?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3D2FA0),
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              const Text(
                'Are you sure you want to quit this?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),

              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async{
                    Navigator.pop(context);
                    await Future.delayed(const Duration(milliseconds: 100));
                    NavigationService().pushAndRemoveAll(const HomeKidsScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ).copyWith(
                    backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7B6EF6), Color(0xFF9B8FF8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Text(
                        'Yes',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Cancel button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: const StadiumBorder(),
                    backgroundColor: const Color(0xFFF3F1FF),
                    shadowColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7B6EF6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
