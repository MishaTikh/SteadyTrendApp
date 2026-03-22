import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:steadytrend/providers/weight_provider.dart';
import 'package:steadytrend/providers/settings_provider.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  test('WeightProvider generates demo data', () async {
    final wp = WeightProvider();
    await Future.delayed(Duration(milliseconds: 100)); // wait for load
    expect(wp.entries.length, 0);

    wp.setDemoMode(true);
    expect(wp.isDemoMode, true);
    expect(wp.entries.length, 366);

    // Test that the trend weight starts around 200 and ends around 178
    final oldest = wp.entries.last; // ~365 days ago
    final newest = wp.entries.first; // today

    expect(oldest.weight, closeTo(200.0, 5.0)); // Should be ~200 + seasonal/noise
    expect(newest.weight, closeTo(178.0, 5.0)); // Should be ~178 + seasonal/noise

    wp.setDemoMode(false);
    expect(wp.entries.length, 0); // Real entries should be empty
  });

  test('SettingsProvider toggles demo goal weight', () async {
    final sp = SettingsProvider();
    await Future.delayed(Duration(milliseconds: 100)); // wait for load
    expect(sp.goalWeight, 150.0); // Default real goal

    sp.setDemoMode(true);
    expect(sp.goalWeight, 170.0); // Default demo goal

    sp.setDemoMode(false);
    expect(sp.goalWeight, 150.0); // Back to real goal
  });
}
