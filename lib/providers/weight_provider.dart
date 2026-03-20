import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weight_entry.dart';

class WeightProvider with ChangeNotifier {
  List<WeightEntry> _entries = [];
  bool _isLoading = true;

  WeightProvider() {
    _loadEntries();
  }

  List<WeightEntry> get entries => [..._entries]..sort((a, b) => b.date.compareTo(a.date));
  bool get isLoading => _isLoading;

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? entryStrings = prefs.getStringList('weight_entries');

    if (entryStrings != null) {
      _entries = entryStrings.map((str) => WeightEntry.fromJson(str)).toList();
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
    // If unit is lbs, we store it internally as kg for consistency
    double storedWeight = weight;
    if (unit == 'LBS') {
       // but wait, let's keep it simple: we store the value as it is and convert on UI, OR
       // standard is KG. 1 kg = 2.20462 lbs
       storedWeight = weight / 2.20462;
    }

    // Check if entry for this date already exists
    final dateOnly = DateTime(date.year, date.month, date.day);
    _entries.removeWhere((e) =>
        DateTime(e.date.year, e.date.month, e.date.day) == dateOnly);

    final entry = WeightEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      weight: storedWeight,
      date: date,
      unit: unit,
    );

    _entries.add(entry);
    await _saveEntries();
    notifyListeners();
  }

  // Gets rolling average for a specific number of days up to a given end date
  double? getRollingAverage(int days, {DateTime? endDate}) {
    if (_entries.isEmpty) return null;

    final end = endDate ?? DateTime.now();
    final start = end.subtract(Duration(days: days));

    final relevantEntries = _entries.where((e) =>
      e.date.isAfter(start.subtract(const Duration(days: 1))) &&
      e.date.isBefore(end.add(const Duration(days: 1)))
    ).toList();

    if (relevantEntries.isEmpty) return null;

    double sum = relevantEntries.fold(0, (prev, element) => prev + element.weight);
    return sum / relevantEntries.length;
  }

  // Checks if we have data spanning at least x days
  bool hasDataSpan(int days) {
    if (_entries.length < 2) return false;
    final sorted = entries; // newest first
    final newest = sorted.first.date;
    final oldest = sorted.last.date;
    return newest.difference(oldest).inDays >= days;
  }

  Future<void> deleteWeight(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveEntries();
    notifyListeners();
  }
}
