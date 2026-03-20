import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _preferredUnit = 'LBS';
  double _goalWeight = 150.0;
  bool _showDailyData = true;
  bool _isLoading = true;

  SettingsProvider() {
    _loadSettings();
  }

  String get preferredUnit => _preferredUnit;
  double get goalWeight => _goalWeight;
  bool get showDailyData => _showDailyData;
  bool get isLoading => _isLoading;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _preferredUnit = prefs.getString('preferred_unit') ?? 'LBS';
    _goalWeight = prefs.getDouble('goal_weight') ?? 150.0;
    _showDailyData = prefs.getBool('show_daily_data') ?? true;
    _isLoading = false;
    notifyListeners();
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
}
