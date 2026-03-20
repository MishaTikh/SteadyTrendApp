import 'dart:convert';

class WeightEntry {
  final String id;
  final double weight; // stored internally as LBS for consistency
  final DateTime date;
  final String unit; // usually 'LBS' now, but retained for model compatibility

  WeightEntry({
    required this.id,
    required this.weight,
    required this.date,
    required this.unit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'date': date.toIso8601String(),
      'unit': unit,
    };
  }

  factory WeightEntry.fromMap(Map<String, dynamic> map) {
    return WeightEntry(
      id: map['id'] ?? '',
      weight: map['weight']?.toDouble() ?? 0.0,
      date: DateTime.parse(map['date']),
      unit: map['unit'] ?? 'kg',
    );
  }

  String toJson() => json.encode(toMap());

  factory WeightEntry.fromJson(String source) => WeightEntry.fromMap(json.decode(source));
}
