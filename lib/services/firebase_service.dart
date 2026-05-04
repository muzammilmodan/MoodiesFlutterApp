// lib/services/firebase_service.dart
//
// Replaces the old REST API (Retrofit + OkHttp).
// All data operations go through Firebase Auth + Cloud Firestore.

import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../utils/app_constants.dart';
import '../utils/app_enum.dart';
import '../utils/session_manager.dart';

class FirebaseService {
  // ── singletons ────────────────────────────────────────────────────────────
  static final FirebaseService _i = FirebaseService._();
  factory FirebaseService() => _i;
  FirebaseService._();

  final FirebaseAuth      _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db   = FirebaseFirestore.instance;

  // ── helpers ───────────────────────────────────────────────────────────────
  //String get _uid => _auth.currentUser?.uid ?? '';

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    return user.uid;
  }

  DocumentReference get _userDoc =>
      _db.collection(AppConstants.colUsers).doc(_uid);

  CollectionReference _sub(String col) => _userDoc.collection(col);

  /// Generate a 6-character alphanumeric child linking code
  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rng = Random.secure();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AUTH
  // ══════════════════════════════════════════════════════════════════════════

  /// Login — replaces POST /login
  Future<UserModel> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    final uid = cred.user?.uid;
    final snap = await _db.collection(AppConstants.colUsers).doc(uid).get();
    if (!snap.exists) throw Exception('User profile not found');
    final user = UserModel.fromMap(uid ?? "", snap.data()!);
    // cache role locally
    await SessionManager.setSelectRole(user.role);
    return user;
  }

  /// Register — replaces POST /register
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String parentEmail,
    required String role,
    required String age,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);

    await cred.user!.reload();
    await Future.delayed(const Duration(milliseconds: 300));

    final uid     = cred.user!.uid;
    final isChild = role == UserType.kides.name
        ? AppConstants.isChildKids
        : AppConstants.isChildParent;
    final code = _generateCode();

    final user = UserModel(
      uid:         uid,
      name:        name.trim(),
      email:       email.trim(),
      role:        role,
      isChild:     isChild,
      myCode:        code,
      parentEmail: parentEmail.trim(),
      age: age.trim(),
    );

    await _db.collection(AppConstants.colUsers).doc(uid).set(user.toMap());
    await SessionManager.setSelectRole(role);
    return user;
  }

  /// Forgot password — replaces POST /user/forgotPassword
  Future<void> forgotPassword(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Logout
  Future<void> logout() async {
    await _auth.signOut();
    await SessionManager.clearSession();
  }

  /// Currently signed-in Firebase user (null = not logged in)
  User? get currentUser => _auth.currentUser;

  // ══════════════════════════════════════════════════════════════════════════
  // USER PROFILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Get current user profile — replaces GET /user/me
  Future<UserModel> getUserProfile() async {
    final snap = await _userDoc.get();
    if (!snap.exists) throw Exception('Profile not found');
    return UserModel.fromMap(_uid, snap.data() as Map<String, dynamic>);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AVATAR
  // ══════════════════════════════════════════════════════════════════════════

  /// Save / update avatar — replaces POST /user/avatar/add
  Future<void> saveAvatar({
    required String gender,
    required String hairColor,
    required String skin,
  }) async {
    final avatar = AvatarModel(gender: gender, hairColor: hairColor, skin: skin);
    await _userDoc.collection(AppConstants.colAvatar).doc('data').set(avatar.toMap());
    // also cache locally
    await SessionManager.setUserGender(gender);
    await SessionManager.setUserHairColor(hairColor);
  }

  /// Get avatar — used on HomeKids init
  Future<AvatarModel?> getAvatar() async {
    final snap = await _userDoc.collection(AppConstants.colAvatar).doc('data').get();
    if (!snap.exists) return null;
    return AvatarModel.fromMap(snap.data()!);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MOODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Add mood — replaces POST /user/mood/add
  Future<void> addMood(String mood) async {
    await _sub(AppConstants.colMoods).add(MoodModel(
      id: '', mood: mood,
    ).toMap());
  }

  /// Get all moods — replaces GET /user/mood/get
  Future<List<MoodModel>> getMoods() async {
    final snap = await _sub(AppConstants.colMoods)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map((d) => MoodModel.fromDoc(d)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // EVENTS (Planner)
  // ══════════════════════════════════════════════════════════════════════════

  /// Add event — replaces POST /user/event/add
  Future<void> addEvent({
    required String title,
    required String type,
    required String eventDate,
    required String reminder,
    required String notes,
  }) async {
    await _sub(AppConstants.colEvents).add(EventModel(
      id: '', title: title, type: type,
      eventDate: eventDate, reminder: reminder, notes: notes,
    ).toMap());
  }

  /// Get events for a specific date — replaces POST /user/event/get
  Future<List<EventModel>> getEventsByDate(String date) async {
    final snap = await _sub(AppConstants.colEvents)
        .where('event_date', isEqualTo: date)
        .orderBy('created_at', descending: false)
        .get();
    return snap.docs.map((d) => EventModel.fromDoc(d)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REMINDERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Add reminder — replaces POST /user/reminder/add
  Future<void> addReminder(String reminder, String datetime) async {
    await _sub(AppConstants.colReminders).add(ReminderModel(
      id: '', reminder: reminder, reminderDatetime: datetime,
    ).toMap());
  }

  /// Get all reminders
  Future<List<ReminderModel>> getReminders() async {
    final snap = await _sub(AppConstants.colReminders)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map((d) => ReminderModel.fromDoc(d)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // THERAPY
  // ══════════════════════════════════════════════════════════════════════════

  /// Add therapy session — replaces POST /user/therapy/add
  Future<void> addTherapy(String therapist, String datetime) async {
    await _sub(AppConstants.colTherapy).add(TherapyModel(
      id: '', therapist: therapist, therapyDatetime: datetime,
    ).toMap());
  }

  /// Get all therapy sessions
  Future<List<TherapyModel>> getTherapySessions() async {
    final snap = await _sub(AppConstants.colTherapy)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map((d) => TherapyModel.fromDoc(d)).toList();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PARENT – Get child by linking code
  // ══════════════════════════════════════════════════════════════════════════

  /// Find child user by code — replaces POST /getChildByCode
  Future<UserModel?> getChildByCode(String code) async {
    final snap = await _db
        .collection(AppConstants.colUsers)
        .where('code', isEqualTo: code.toUpperCase().trim())
        .where('is_child', isEqualTo: AppConstants.isChildKids)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return UserModel.fromMap(doc.id, doc.data());
  }

  /// Save child UID on parent's profile after successful code match
  Future<void> linkChildToParent(String childUid) async {
    await _userDoc.update({'linked_child_uid': childUid});
  }

  /// Get linked child UID from parent's profile
  Future<String?> getLinkedChildUid() async {
    final snap = await _userDoc.get();
    if (!snap.exists) return null;
    return (snap.data() as Map<String, dynamic>)['linked_child_uid'] as String?;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PARENT – Read child profile                                    ← NEW
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetch the linked child's UserModel by their UID.
  /// Used by HomeParentScreen to display name, age on the dashboard card.
  Future<UserModel?> getChildProfile(String childUid) async {
    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .get();
    if (!snap.exists) return null;
    return UserModel.fromMap(childUid, snap.data() as Map<String, dynamic>);
  }



  // ══════════════════════════════════════════════════════════════════════════
  // PARENT – Upcoming planner events count                         ← NEW
  // ══════════════════════════════════════════════════════════════════════════

  /// Returns the number of parent-planner events between [startDate] and
  /// [endDate] (inclusive).  Dates must be in the same string format that
  /// [addEvent] uses when storing `event_date` (e.g. "yyyy-MM-dd").
  ///
  /// Firestore's range operators work correctly here because ISO-8601 date
  /// strings sort lexicographically identical to chronological order.
  ///
  /// Call from the dashboard like:
  ///   final count = await _svc.getUpcomingEventsCount(
  ///     startDate: _isoDate(DateTime.now()),
  ///     endDate:   _isoDate(DateTime.now().add(const Duration(days: 6))),
  ///   );
  Future<int> getUpcomingEventsCount({
    required String startDate,
    required String endDate,
  }) async {
    final snap = await _sub(AppConstants.colEvents)
        .where('event_date', isGreaterThanOrEqualTo: startDate)
        .where('event_date', isLessThanOrEqualTo: endDate)
        .get();
    return snap.docs.length;
  }


  // ══════════════════════════════════════════════════════════════════════════
  // PARENT – Read child's details
  // ══════════════════════════════════════════════════════════════════════════


  /// Get moods of a specific child by uid
  Future<List<MoodModel>> getChildMoods(String childUid) async {
    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .collection(AppConstants.colMoods)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map((d) => MoodModel.fromDoc(d)).toList();
  }

  Future<List<MoodModel>> getChildMoodsByDate(
      String childUid,
      DateTime selectedDate) async {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .collection(AppConstants.colMoods)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created_at', isLessThan: Timestamp.fromDate(end))
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => MoodModel.fromDoc(d)).toList();
  }

  /// Get Therapy Sessions of a specific child by uid
  Future<List<TherapyModel>> getChildTherapySessions(String childUid) async {
    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .collection(AppConstants.colTherapy)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map((d) => TherapyModel.fromDoc(d)).toList();
  }

  Future<List<TherapyModel>> getChildTherapySessionsByDate(
      String childUid,
      DateTime selectedDate) async {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .collection(AppConstants.colTherapy)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created_at', isLessThan: Timestamp.fromDate(end))
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => TherapyModel.fromDoc(d)).toList();
  }

  /// Get reminders of a specific child by uid
  Future<List<ReminderModel>> getChildReminders(String childUid) async {
    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .collection(AppConstants.colReminders)
        .orderBy('created_at', descending: true)
        .get();
    return snap.docs.map((d) => ReminderModel.fromDoc(d)).toList();
  }

  Future<List<TherapyModel>> getChildRemindersByDate(
      String childUid,
      DateTime selectedDate) async {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final end = start.add(const Duration(days: 1));

    final snap = await _db
        .collection(AppConstants.colUsers)
        .doc(childUid)
        .collection(AppConstants.colReminders)
        .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('created_at', isLessThan: Timestamp.fromDate(end))
        .orderBy('created_at', descending: true)
        .get();

    return snap.docs.map((d) => TherapyModel.fromDoc(d)).toList();
  }


  /// Add event — replaces POST /user/event/add
  Future<void> addWeeklyPrintReview({
    required String sunday,
    required String monday,
    required String tuesday,
    required String wednesday,
    required String thursday,
    required String friday,
    required String saturday,
  }) async {
    await _sub(AppConstants.colWeeklyPrint)
        .doc('weekly_review')
        .set(
      WeeklyPrintReviewModel(
        id: 'weekly_review',
        sunday: sunday,
        monday: monday,
        tuesday: tuesday,
        wednesday: wednesday,
        thursday: thursday,
        friday: friday,
        saturday: saturday,
      ).toMap(),
      SetOptions(merge: true),
    );
  }

  /// Get all therapy sessions
  Future<WeeklyPrintReviewModel?> getWeeklyPrintReview() async {
    final doc = await _sub(AppConstants.colWeeklyPrint)
        .doc('weekly_review')
        .get();

    if (!doc.exists) return null;

    return WeeklyPrintReviewModel.fromDoc(doc);
  }
}
