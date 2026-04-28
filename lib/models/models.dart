// lib/models/models.dart
// Plain Dart models — no JSON parsing needed (Firestore returns Map<String,dynamic>)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ── User profile stored in Firestore users/{uid} ─────────────────────────────
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;       // 'parent' | 'kides'
  final int    isChild;    // 0=parent, 1=kids
  final String myCode;       // unique child linking code
  final String parentEmail;
  final String age;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.isChild,
    required this.myCode,
    required this.parentEmail,
    required this.age,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> m) => UserModel(
    uid:         uid,
    name:        m['name']         ?? '',
    email:       m['email']        ?? '',
    role:        m['role']         ?? '',
    isChild:     m['is_child']     ?? 0,
    myCode:        m['code']         ?? '',
    parentEmail: m['parent_email'] ?? '',
    age: m['age'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'name':         name,
    'email':        email,
    'role':         role,
    'is_child':     isChild,
    'code':         myCode,
    'parent_email': parentEmail,
    'age': age,
    'created_at':   FieldValue.serverTimestamp(),
  };
}

// ── Avatar stored in users/{uid}/avatar (single doc) ─────────────────────────
class AvatarModel {
  final String gender;
  final String hairColor;
  final String skin;

  AvatarModel({required this.gender, required this.hairColor, required this.skin});

  factory AvatarModel.fromMap(Map<String, dynamic> m) => AvatarModel(
    gender:    m['gender']     ?? '',
    hairColor: m['hair_color'] ?? '',
    skin:      m['skin']       ?? '',
  );

  Map<String, dynamic> toMap() => {
    'gender':     gender,
    'hair_color': hairColor,
    'skin':       skin,
    'updated_at': FieldValue.serverTimestamp(),
  };
}

// ── Mood stored in users/{uid}/moods ─────────────────────────────────────────
class MoodModel {
  final String id;
  final String mood;
  final DateTime? createdAt;

  MoodModel({required this.id, required this.mood, this.createdAt});

  factory MoodModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return MoodModel(
      id:        doc.id,
      mood:      m['mood'] ?? '',
      createdAt: (m['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'mood':       mood,
    'created_at': FieldValue.serverTimestamp(),
  };

  String get formattedDate =>
      createdAt == null ? '' :
      '${createdAt?.year}-${_p(createdAt?.month ?? 0)}-${_p(createdAt?.day ?? 0)}';

  String _p(int n) => n.toString().padLeft(2, '0');

  String get formattedDateTime {
    if (createdAt == null) return '';
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt!);
  }
}

// ── Event stored in users/{uid}/events ───────────────────────────────────────
class EventModel {
  final String id;
  final String title;
  final String type;
  final String eventDate;
  final String reminder;
  final String notes;

  EventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.eventDate,
    required this.reminder,
    required this.notes,
  });

  factory EventModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return EventModel(
      id:        doc.id,
      title:     m['title']      ?? '',
      type:      m['type']       ?? '',
      eventDate: m['event_date'] ?? '',
      reminder:  m['reminder']   ?? '',
      notes:     m['notes']      ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'title':      title,
    'type':       type,
    'event_date': eventDate,
    'reminder':   reminder,
    'notes':      notes,
    'created_at': FieldValue.serverTimestamp(),
  };
}

// ── Reminder stored in users/{uid}/reminders ─────────────────────────────────
class ReminderModel {
  final String id;
  final String reminder;
  final String reminderDatetime;

  ReminderModel({required this.id, required this.reminder, required this.reminderDatetime});

  factory ReminderModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id:                doc.id,
      reminder:          m['reminder']           ?? '',
      reminderDatetime:  m['reminder_datetime']  ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'reminder':           reminder,
    'reminder_datetime':  reminderDatetime,
    'created_at':         FieldValue.serverTimestamp(),
  };
}

// ── Therapy stored in users/{uid}/therapy ────────────────────────────────────
class TherapyModel {
  final String id;
  final String therapist;
  final String therapyDatetime;

  TherapyModel({required this.id, required this.therapist, required this.therapyDatetime});

  factory TherapyModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return TherapyModel(
      id:               doc.id,
      therapist:        m['therapist']        ?? '',
      therapyDatetime:  m['therapy_datetime'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'therapist':        therapist,
    'therapy_datetime': therapyDatetime,
    'created_at':       FieldValue.serverTimestamp(),
  };
}


// ── WeeklyPrintReviewModel stored in users/{uid}/WeeklyPrintReview ───────────────────────────────────────
class WeeklyPrintReviewModel {
  final String id;
  final String sunday;
  final String monday;
  final String tuesday;
  final String wednesday;
  final String thursday;
  final String friday;
  final String saturday;

  WeeklyPrintReviewModel({
    required this.id,
    required this.sunday,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
  });

  factory WeeklyPrintReviewModel.fromDoc(DocumentSnapshot doc) {
    final m = doc.data() as Map<String, dynamic>;
    return WeeklyPrintReviewModel(
      id:        doc.id,
      sunday:      m['sunday']      ?? '',
      monday:      m['monday']       ?? '',
      tuesday:     m['tuesday'] ?? '',
      wednesday:   m['wednesday']   ?? '',
      thursday:    m['thursday']      ?? '',
      friday:      m['friday']      ?? '',
      saturday:    m['saturday']      ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'sunday':      sunday,
    'monday':      monday,
    'tuesday':     tuesday,
    'wednesday':   wednesday,
    'thursday':    thursday,
    'friday':      friday,
    'saturday':    saturday,
    'created_at': FieldValue.serverTimestamp(),
  };
}
