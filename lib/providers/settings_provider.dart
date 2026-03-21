import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  String _preferredUnit = 'LBS';
  double _goalWeight = 150.0;
  bool _showDailyData = true;
  bool _pushNotificationsEnabled = false;
  String _notificationTime = '07:00'; // HH:mm format
  bool _isLoading = true;

  SettingsProvider() {
    _loadSettings();
  }

  String get preferredUnit => _preferredUnit;
  double get goalWeight => _goalWeight;
  bool get showDailyData => _showDailyData;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  String get notificationTime => _notificationTime;
  bool get isLoading => _isLoading;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _preferredUnit = prefs.getString('preferred_unit') ?? 'LBS';
    _goalWeight = prefs.getDouble('goal_weight') ?? 150.0;
    _showDailyData = prefs.getBool('show_daily_data') ?? true;
    _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? false;
    _notificationTime = prefs.getString('notification_time') ?? '07:00';
    _isLoading = false;
    notifyListeners();
    _updateNotificationSchedule();
  }

  Future<void> updatePreferredUnit(String unit) async {
    _preferredUnit = unit;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_unit', unit);
    notifyListeners();
  }

  Future<void> updateGoalWeight(double weight) async {
    _goalWeight = weight;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal_weight', weight);
    notifyListeners();
  }

  Future<void> updateShowDailyData(bool show) async {
    _showDailyData = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_daily_data', show);
    notifyListeners();
  }

  Future<void> updatePushNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await NotificationService().requestPermissions();
      if (!granted) {
        // if user denied permissions, don't enable it
        return;
      }
    }

    _pushNotificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('push_notifications_enabled', enabled);
    notifyListeners();
    _updateNotificationSchedule();
  }

  Future<void> updateNotificationTime(String time) async {
    _notificationTime = time;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('notification_time', time);
    notifyListeners();
    _updateNotificationSchedule();
  }

  void _updateNotificationSchedule() {
    if (_pushNotificationsEnabled) {
      final parts = _notificationTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]) ?? 7;
        final minute = int.tryParse(parts[1]) ?? 0;
        NotificationService().scheduleDailyNotification(hour: hour, minute: minute);
      }
    } else {
      NotificationService().cancelAllNotifications();
    }
  }
}
