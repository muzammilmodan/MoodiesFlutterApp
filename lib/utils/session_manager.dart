// lib/utils/session_manager.dart
// Stores only non-auth session data locally.
// Firebase Auth handles token / login state automatically.

import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  // ── keys ──────────────────────────────────────────────
  static const _keyRole        = 'select_role';
  static const _keyIsCodeDone  = 'is_kides_code';
  static const _keyGender      = 'is_boys_female';
  static const _keyHairColor   = 'is_gender_hair_color';
  static const _keySkinColor   = 'is_gender_skin_color';
  static const _keyAvatarTitle = 'avatar_title';
  static const _keyUserGender  = 'user_gender_api';
  static const _keyUserHair    = 'user_hair_api';

  // ── role ──────────────────────────────────────────────
  static Future<void> setSelectRole(String role) async =>
      (await SharedPreferences.getInstance()).setString(_keyRole, role);

  static Future<String> getSelectRole() async =>
      (await SharedPreferences.getInstance()).getString(_keyRole) ?? '';

  // ── kids code verified by parent ──────────────────────
  static Future<void> setIsSelectCode(bool v) async =>
      (await SharedPreferences.getInstance()).setBool(_keyIsCodeDone, v);

  static Future<bool> getIsSelectCode() async =>
      (await SharedPreferences.getInstance()).getBool(_keyIsCodeDone) ?? false;

  // ── avatar creation (local preview) ──────────────────
  static Future<void> setIsGender(int g) async =>
      (await SharedPreferences.getInstance()).setInt(_keyGender, g);

  static Future<int> getIsGender() async =>
      (await SharedPreferences.getInstance()).getInt(_keyGender) ?? 0;

  static Future<void> setHairColor(String c) async =>
      (await SharedPreferences.getInstance()).setString(_keyHairColor, c);

  static Future<String> getHairColor() async =>
      (await SharedPreferences.getInstance()).getString(_keyHairColor) ?? '';

  static Future<void> setSkinColor(String c) async =>
      (await SharedPreferences.getInstance()).setString(_keySkinColor, c);

  static Future<String> getSkinColor() async =>
      (await SharedPreferences.getInstance()).getString(_keySkinColor) ?? '';

  // ── mood title selected for today ────────────────────
  static Future<void> setAvatarTitle(String t) async =>
      (await SharedPreferences.getInstance()).setString(_keyAvatarTitle, t);

  static Future<String> getAvatarTitle() async =>
      (await SharedPreferences.getInstance()).getString(_keyAvatarTitle) ?? '';

  // ── avatar data synced from Firestore ────────────────
  static Future<void> setUserGender(String g) async =>
      (await SharedPreferences.getInstance()).setString(_keyUserGender, g);

  static Future<String> getUserGender() async =>
      (await SharedPreferences.getInstance()).getString(_keyUserGender) ?? '';

  static Future<void> setUserHairColor(String c) async =>
      (await SharedPreferences.getInstance()).setString(_keyUserHair, c);

  static Future<String> getUserHairColor() async =>
      (await SharedPreferences.getInstance()).getString(_keyUserHair) ?? '';

  // ── clear everything on logout ────────────────────────
  static Future<void> clearSession() async =>
      (await SharedPreferences.getInstance()).clear();
}
