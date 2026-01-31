import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyIntimacyMode = 'intimacy_mode';
  static const String _keyFigEndMode = 'fig_end_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyDailyReminderTime = 'daily_reminder_time';
  static const String _keyRitualNotifications = 'ritual_notifications';
  static const String _keyPartnerNotifications = 'partner_notifications';
  static const String _keyCodexNotifications = 'codex_notifications';

  bool _intimacyMode = false;
  bool _figEndMode = true;
  bool _notificationsEnabled = true;
  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 21, minute: 0);
  bool _ritualNotifications = true;
  bool _partnerNotifications = true;
  bool _codexNotifications = true;

  bool get intimacyMode => _intimacyMode;
  bool get figEndMode => _figEndMode;
  bool get notificationsEnabled => _notificationsEnabled;
  TimeOfDay get dailyReminderTime => _dailyReminderTime;
  bool get ritualNotifications => _ritualNotifications;
  bool get partnerNotifications => _partnerNotifications;
  bool get codexNotifications => _codexNotifications;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _intimacyMode = prefs.getBool(_keyIntimacyMode) ?? false;
    _figEndMode = prefs.getBool(_keyFigEndMode) ?? true;
    _notificationsEnabled = prefs.getBool(_keyNotificationsEnabled) ?? true;
    _ritualNotifications = prefs.getBool(_keyRitualNotifications) ?? true;
    _partnerNotifications = prefs.getBool(_keyPartnerNotifications) ?? true;
    _codexNotifications = prefs.getBool(_keyCodexNotifications) ?? true;

    final reminderHour = prefs.getInt('${_keyDailyReminderTime}_hour') ?? 21;
    final reminderMinute = prefs.getInt('${_keyDailyReminderTime}_minute') ?? 0;
    _dailyReminderTime = TimeOfDay(hour: reminderHour, minute: reminderMinute);

    notifyListeners();
  }

  Future<void> setIntimacyMode(bool value) async {
    _intimacyMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIntimacyMode, value);
    notifyListeners();
  }

  Future<void> setFigEndMode(bool value) async {
    _figEndMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFigEndMode, value);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotificationsEnabled, value);
    notifyListeners();
  }

  Future<void> setDailyReminderTime(TimeOfDay time) async {
    _dailyReminderTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('${_keyDailyReminderTime}_hour', time.hour);
    await prefs.setInt('${_keyDailyReminderTime}_minute', time.minute);
    notifyListeners();
  }

  Future<void> setRitualNotifications(bool value) async {
    _ritualNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRitualNotifications, value);
    notifyListeners();
  }

  Future<void> setPartnerNotifications(bool value) async {
    _partnerNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPartnerNotifications, value);
    notifyListeners();
  }

  Future<void> setCodexNotifications(bool value) async {
    _codexNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyCodexNotifications, value);
    notifyListeners();
  }
}
