// lib/utils/app_constants.dart

class AppConstants {
  static const int splashTimeout = 3000;

  // Hair colors
  static const String hairBlonde = 'blonde';
  static const String hairBrown  = 'brown';
  static const String hairRed    = 'red';
  static const String hairTan    = 'tan';

  // Skin colors
  static const String skinBlonde = 'blonde';
  static const String skinRed    = 'red';
  static const String skinBrown  = 'brown';
  static const String skinTan    = 'tan';

  static const String colAvatar    = 'colAvatar';

  // Gender
  static const int isMale   = 0;
  static const int isFemale = 1;

  // is_child values returned from Firestore
  static const int isChildParent = 0;
  static const int isChildKids   = 1;

  // Roles
  static const String roleParent = 'parent';
  static const String roleKids   = 'kides';

  // Moods list
  static const List<String> moods = [
    'Smart', 'Mad', 'Sad', 'Happy', 'Scared', 'Tired',
    'Comfortable', 'Safe', 'Excited', 'Worried', 'Confused', 'Loved',
  ];

  // App primary teal color
  static const int appBgColorValue = 0xFF4DB6AC;

  // Firestore top-level collection
  static const String colUsers     = 'users';
  // Sub-collections under users/{uid}/
  static const String colMoods     = 'moods';
  static const String colEvents    = 'events';
  static const String colReminders = 'reminders';
  static const String colTherapy   = 'therapy';
  static const String colWeeklyPrint   = 'weeklyprint';
}

class AppImages {
  static const String icnJumpKids='assets/images/icn_jump_kids.json';


  static const String icnGirlCharacter='assets/images/icn_female_avatar.png';
  static const String icnMaleCharacter='assets/images/icn_male_avatar.png';

  //Abc Games Images
  static const String icAbcBack =  "assets/abcgames/images/new_button/back.png";
  static const String icAbcClose =  "assets/abcgames/images/new_button/close.png";
  static const String icAbcHomeBG =   "assets/abcgames/new_gif/main_home1.png";
  static const String icAbcMenuBG=  "assets/abcgames/new_gif/setting.png";

  static const String icAbcMenuCountWithPhonic=  "assets/abcgames/images/setting_button/auto_play.png";
  static const String icAbcMenuDragMatchNumberBlocks=  "assets/abcgames/images/setting_button/drag.png";
  static const String icAbcMenuPopBubblesCount=  "assets/abcgames/images/setting_button/word.png";
  static const String icAbcMenuTrackLearnNo=  "assets/abcgames/images/setting_button/tracing.png";
  static const String icAbcMenuNumberCountPuzzle=  "assets/abcgames/images/setting_button/puzzle.png";

}