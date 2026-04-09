// lib/utils/app_constants.dart

class AppConstants {
  static const int splashTimeout = 3000;

  // Hair colors
  static const String hairBlonde = 'blonde';
  static const String hairBrown  = 'brown';
  static const String hairRed    = 'read';
  static const String hairTan    = 'tan';

  // Skin colors
  static const String skinBlonde = 'blonde';
  static const String skinRed    = 'read';
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
}
