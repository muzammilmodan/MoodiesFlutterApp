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
