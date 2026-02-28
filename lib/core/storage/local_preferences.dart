import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/models/app_user.dart';
import '../../shared/models/membership.dart';
import '../../shared/models/space.dart';

class LocalPreferences {
  static const _userKey = 'mock_user';
  static const _spaceKey = 'mock_space';
  static const _membershipKey = 'mock_membership';
  static const _notificationEnabledKey = 'notification_enabled';

  Future<void> saveUser(AppUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<AppUser?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_userKey);
    if (value == null) {
      return null;
    }
    return AppUser.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> saveSpace(Space space) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spaceKey, jsonEncode(space.toJson()));
  }

  Future<Space?> loadSpace() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_spaceKey);
    if (value == null) {
      return null;
    }
    return Space.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> saveMembership(SpaceMembership membership) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_membershipKey, jsonEncode(membership.toJson()));
  }

  Future<SpaceMembership?> loadMembership() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_membershipKey);
    if (value == null) {
      return null;
    }
    return SpaceMembership.fromJson(jsonDecode(value) as Map<String, dynamic>);
  }

  Future<void> clearSessionState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_spaceKey);
    await prefs.remove(_membershipKey);
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, enabled);
  }

  Future<bool> loadNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationEnabledKey) ?? true;
  }
}
