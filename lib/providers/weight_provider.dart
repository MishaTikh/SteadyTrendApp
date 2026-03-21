import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';

class WeightProvider with ChangeNotifier {
  List<WeightEntry> _entries = [];
  List<WeightEntry> _demoEntries = [];
  bool _isLoading = true;
  bool _isDemoMode = false;

  WeightProvider() {
    _loadEntries();
  }

  List<WeightEntry> get entries => _isDemoMode
      ? ([..._demoEntries]..sort((a, b) => b.date.compareTo(a.date)))
      : ([..._entries]..sort((a, b) => b.date.compareTo(a.date)));
  bool get isLoading => _isLoading;
  bool get isDemoMode => _isDemoMode;

  void setDemoMode(bool isDemo) {
    if (_isDemoMode == isDemo) return;
    _isDemoMode = isDemo;
    if (_isDemoMode) {
      _generateDemoData();
    } else {
      _demoEntries.clear();
    }
    notifyListeners();
  }

  void _generateDemoData() {
    _demoEntries.clear();
    final random = Random(42); // Use a fixed seed for static generation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Generate data backwards from today to 365 days ago
    // Start weight 365 days ago: ~200 lbs
    // End weight today: ~178 lbs
    double currentTrendWeight = 178.0;

    for (int i = 0; i <= 365; i++) {
      final date = today.subtract(Duration(days: i));

      // We are going backwards in time, so trend weight increases backwards
      // Total drop = 22 lbs over 365 days (~0.0602 lbs/day)
      // Let's add some mini plateaus and seasonal fluctuations

      // Calculate progress (0 = today, 1 = year ago)
      double progress = i / 365.0;

      // Linear component (178 to 200)
      double linearWeight = 178.0 + (22.0 * progress);

      // Seasonal fluctuation (e.g., holidays, sine wave)
      // 1 year = 2 pi
      double seasonal = sin(progress * 2 * pi) * 2.5;

      // Mini plateaus (add a stepping effect)
      double plateauEffect = sin(progress * 10 * pi) * 1.5;

      currentTrendWeight = linearWeight + seasonal + plateauEffect;

      // Daily realistic random fluctuation (+/- 1.5 lbs)
      double dailyNoise = (random.nextDouble() * 3.0) - 1.5;

      double finalWeight = currentTrendWeight + dailyNoise;

      _demoEntries.add(WeightEntry(
        id: 'demo_$i',
        weight: finalWeight,
        date: date,
        unit: 'LBS',
      ));
    }
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entryStrings = prefs.getStringList('weight_entries');

    if (entryStrings != null) {
      _entries = entryStrings.map((str) => WeightEntry.fromJson(str)).toList();
    }

    // Migration to LBS (internal storage default)
    // If we have no flag, we assume existing weights were stored in KG.
    final bool hasMigratedToLbs = prefs.getBool('migrated_to_lbs') ?? false;
    if (!hasMigratedToLbs && _entries.isNotEmpty) {
      for (int i = 0; i < _entries.length; i++) {
        // Convert existing KG to LBS
        _entries[i] = WeightEntry(
          id: _entries[i].id,
          weight: _entries[i].weight * 2.20462,
          date: _entries[i].date,
          unit: 'LBS',
        );
      }
      await _saveEntries();
      await prefs.setBool('migrated_to_lbs', true);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> entryStrings = _entries.map((e) => e.toJson()).toList();
    await prefs.setStringList('weight_entries', entryStrings);
  }

  Future<void> addWeight(double weight, DateTime date, String unit) async {
    // Internal storage is LBS
    double storedWeight = weight;
    if (unit == 'KG') {
       storedWeight = weight * 2.20462;
    }

    final targetList = _isDemoMode ? _demoEntries : _entries;

    // Check if entry for this date already exists
    final dateOnly = DateTime(date.year, date.month, date.day);
    targetList.removeWhere((e) =>
        DateTime(e.date.year, e.date.month, e.date.day) == dateOnly);

    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: storedWeight,
      date: date,
      unit: 'LBS',
    );

    targetList.add(entry);
    if (!_isDemoMode) {
      await _saveEntries();
    }
    notifyListeners();
  }

  Future<void> updateWeight(String id, double weight, DateTime date, String unit) async {
    final targetList = _isDemoMode ? _demoEntries : _entries;
    final index = targetList.indexWhere((e) => e.id == id);
    if (index == -1) return;

    // Internal storage is LBS
    double storedWeight = weight;
    if (unit == 'KG') {
       storedWeight = weight * 2.20462;
    }

    // Check if updating the date causes a conflict with another entry
    final dateOnly = DateTime(date.year, date.month, date.day);
    targetList.removeWhere((e) =>
        e.id != id && DateTime(e.date.year, e.date.month, e.date.day) == dateOnly);

    targetList[index] = WeightEntry(
      id: id,
      weight: storedWeight,
      date: date,
      unit: 'LBS',
    );

    if (!_isDemoMode) {
      await _saveEntries();
    }
    notifyListeners();
  }

  // Gets rolling average for a specific number of days up to a given end date
  double? getRollingAverage(int days, {DateTime? endDate}) {
    final currentEntries = _isDemoMode ? _demoEntries : _entries;
    if (currentEntries.isEmpty) return null;

    final end = endDate ?? DateTime.now();
    final start = end.subtract(Duration(days: days));

    final relevantEntries = currentEntries.where((e) =>
      e.date.isAfter(start.subtract(const Duration(days: 1))) &&
      e.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();

    if (relevantEntries.isEmpty) return null;

    double sum = relevantEntries.fold(0, (prev, element) => prev + element.weight);
    return sum / relevantEntries.length;
  }

  // Checks if we have data spanning at least x days
  bool hasDataSpan(int days) {
    final currentEntries = _isDemoMode ? _demoEntries : _entries;
    if (currentEntries.length < 2) return false;
    final sorted = entries; // newest first
    final newest = sorted.first.date;
    final oldest = sorted.last.date;
    return newest.difference(oldest).inDays >= days;
  }

  Future<void> deleteWeight(String id) async {
    if (_isDemoMode) {
      _demoEntries.removeWhere((e) => e.id == id);
    } else {
      _entries.removeWhere((e) => e.id == id);
      await _saveEntries();
    }
    notifyListeners();
  }
}
