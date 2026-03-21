import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  String _preferredUnit = 'LBS';
  double _goalWeight = 150.0;
  bool _showDailyData = true;
  bool _isLoading = true;

  bool _isDemoMode = false;
  double _demoGoalWeight = 170.0;

  SettingsProvider() {
    _loadSettings();
  }

  String get preferredUnit => _preferredUnit;
  double get goalWeight => _isDemoMode ? _demoGoalWeight : _goalWeight;
  bool get showDailyData => _showDailyData;
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;

  void setDemoMode(bool isDemo) {
    _isDemoMode = isDemo;
    if (_isDemoMode) {
      // Set the demo goal weight to 170.0 in LBS, or convert if the preferred unit is KG
      _demoGoalWeight = _preferredUnit == 'KG' ? 170.0 / 2.20462 : 170.0;
    }
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _preferredUnit = prefs.getString('preferred_unit') ?? 'LBS';
    _goalWeight = prefs.getDouble('goal_weight') ?? 150.0;
    _showDailyData = prefs.getBool('show_daily_data') ?? true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePreferredUnit(String unit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferred_unit', unit);
    _preferredUnit = unit;
    if (_isDemoMode) {
      _demoGoalWeight = unit == 'KG' ? 170.0 / 2.20462 : 170.0;
    }
    notifyListeners();
  }

  Future<void> updateGoalWeight(double weight) async {
    if (_isDemoMode) {
      _demoGoalWeight = weight;
    } else {
      _goalWeight = weight;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('goal_weight', weight);
    }
    notifyListeners();
  }

  Future<void> updateShowDailyData(bool show) async {
    _showDailyData = show;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_daily_data', show);
    notifyListeners();
  }
}
