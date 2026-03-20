import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';

class WeightProvider with ChangeNotifier {
  static const String _storageKey = 'weight_entries';

  List<WeightEntry> _entries = [];
  bool _isLoading = true;

  List<WeightEntry> get entries => _entries;
  bool get isLoading => _isLoading;

  WeightProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? dataString = prefs.getString(_storageKey);

      if (dataString != null) {
        final List<dynamic> jsonList = jsonDecode(dataString);
        _entries = jsonList.map((json) => WeightEntry.fromJson(json)).toList();

        // Sort entries by date (newest first)
        _entries.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      debugPrint('Error loading weight data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = _entries.map((e) => e.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving weight data: $e');
    }
  }

  Future<void> addEntry(DateTime date, double weight) async {
    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: date,
      weight: weight,
    );

    _entries.add(entry);
    _entries.sort((a, b) => b.date.compareTo(a.date));

    notifyListeners();
    await _saveData();
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((entry) => entry.id == id);
    notifyListeners();
    await _saveData();
  }

  // Helper method to get entries within a date range
  List<WeightEntry> _getEntriesInRange(DateTime end, int daysAgo) {
    final start = end.subtract(Duration(days: daysAgo));
    return _entries.where((e) => e.date.isAfter(start) && e.date.isBefore(end.add(const Duration(days: 1)))).toList();
  }

  // Calculate average weight for a list of entries
  double? _calculateAverage(List<WeightEntry> rangeEntries) {
    if (rangeEntries.isEmpty) return null;
    final total = rangeEntries.fold(0.0, (sum, item) => sum + item.weight);
    return total / rangeEntries.length;
  }

  // Get current 7-day average
  double? get current7DayAverage {
    if (_entries.isEmpty) return null;
    return _calculateAverage(_getEntriesInRange(DateTime.now(), 7));
  }

  // Get previous 7-day average (from 7 to 14 days ago)
  double? get previous7DayAverage {
    if (_entries.isEmpty) return null;
    final endOfLastWeek = DateTime.now().subtract(const Duration(days: 7));
    return _calculateAverage(_getEntriesInRange(endOfLastWeek, 7));
  }

  // Get 1 week average change
  double? get oneWeekChange {
     final current = current7DayAverage;
     final previous = previous7DayAverage;
     if (current == null || previous == null) return null;
     return current - previous;
  }

  // Get current 2-week average
  double? get current14DayAverage {
    if (_entries.isEmpty) return null;
    return _calculateAverage(_getEntriesInRange(DateTime.now(), 14));
  }

  // Get previous 2-week average
  double? get previous14DayAverage {
    if (_entries.isEmpty) return null;
    final endOfLastPeriod = DateTime.now().subtract(const Duration(days: 14));
    return _calculateAverage(_getEntriesInRange(endOfLastPeriod, 14));
  }

  double? get twoWeekChange {
     final current = current14DayAverage;
     final previous = previous14DayAverage;
     if (current == null || previous == null) return null;
     return current - previous;
  }

  // Get current 30-day average
  double? get current30DayAverage {
    if (_entries.isEmpty) return null;
    return _calculateAverage(_getEntriesInRange(DateTime.now(), 30));
  }

  // Get previous 30-day average
  double? get previous30DayAverage {
    if (_entries.isEmpty) return null;
    final endOfLastPeriod = DateTime.now().subtract(const Duration(days: 30));
    return _calculateAverage(_getEntriesInRange(endOfLastPeriod, 30));
  }

  double? get oneMonthChange {
     final current = current30DayAverage;
     final previous = previous30DayAverage;
     if (current == null || previous == null) return null;
     return current - previous;
  }

  // Average monthly delta overall
  double? get averageMonthlyDelta {
    if (_entries.isEmpty) return null;
    if (_entries.length < 2) return null;

    // Sort to be sure oldest is last
    final sorted = List<WeightEntry>.from(_entries)..sort((a, b) => b.date.compareTo(a.date));

    final newest = sorted.first;
    final oldest = sorted.last;

    final differenceInDays = newest.date.difference(oldest.date).inDays;

    if (differenceInDays < 30) {
      // Not enough data for a real monthly delta, return a projected one based on current rate?
      // Or just return null if we want to be strict. Let's return a scaled delta if there is some data.
      if (differenceInDays == 0) return null;
      final dailyDelta = (newest.weight - oldest.weight) / differenceInDays;
      return dailyDelta * 30;
    }

    final months = differenceInDays / 30.0;
    return (newest.weight - oldest.weight) / months;
  }

  // Get variance for a specific entry vs 7-day average ending on that day
  double? getVarianceForEntry(WeightEntry entry) {
    // 7-day avg leading up to and including this entry's date
    final start = entry.date.subtract(const Duration(days: 7));
    final relevantEntries = _entries.where((e) => e.date.isAfter(start) && e.date.isBefore(entry.date.add(const Duration(days: 1)))).toList();
    final avg = _calculateAverage(relevantEntries);

    if (avg == null) return null;
    return entry.weight - avg;
  }
}
