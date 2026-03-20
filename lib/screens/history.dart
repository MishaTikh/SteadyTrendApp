import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // for AppColors
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/weight_provider.dart';
import '../providers/settings_provider.dart';
import '../models/weight_entry.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  Future<void> _exportCSV(List<WeightEntry> entries, String preferredUnit) async {
    if (entries.isEmpty) return;

    String csv = "Date,Time,Weight($preferredUnit)\n";
    for (var entry in entries) {
      double displayWeight = entry.weight;
      if (preferredUnit == 'KG') {
        displayWeight /= 2.20462;
      }
      csv += "${DateFormat('yyyy-MM-dd').format(entry.date)},${DateFormat('HH:mm').format(entry.date)},${displayWeight.toStringAsFixed(2)}\n";
    }

    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/weight_history.csv');
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(file.path)], text: 'My Weight History');
  }

  void _editEntry(BuildContext context, WeightEntry entry, WeightProvider provider, SettingsProvider settings) {
    double displayWeight = entry.weight;
    if (settings.preferredUnit == 'KG') {
      displayWeight /= 2.20462;
    }

    final TextEditingController controller = TextEditingController(text: displayWeight.toStringAsFixed(1));
    DateTime selectedDate = entry.date;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit Log Entry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Text('Date:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            // keep the time
                            setState(() {
                              selectedDate = DateTime(
                                picked.year, picked.month, picked.day,
                                selectedDate.hour, selectedDate.minute, selectedDate.second
                              );
                            });
                          }
                        },
                        child: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight (${settings.preferredUnit})',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          provider.deleteWeight(entry.id);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: const Text('Delete'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final parsed = double.tryParse(controller.text);
                          if (parsed != null) {
                            provider.updateWeight(entry.id, parsed, selectedDate, settings.preferredUnit);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _showBulkAddModal(BuildContext context, WeightProvider provider, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        DateTime currentDate = DateTime.now();
        final TextEditingController controller = TextEditingController();
        final FocusNode focusNode = FocusNode();

        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quick Backlog Entry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMMM d, yyyy').format(currentDate), style: const TextStyle(fontSize: 18)),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: currentDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now()
                          );
                          if (picked != null) {
                            setState(() {
                              currentDate = picked;
                            });
                          }
                        },
                        child: const Text('Change Date'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    focusNode: focusNode,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Weight (${settings.preferredUnit})',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.check, color: AppColors.primaryGreen),
                        onPressed: () {
                          final val = controller.text;
                          final parsed = double.tryParse(val);
                          if (parsed != null) {
                            provider.addWeight(parsed, currentDate, settings.preferredUnit);
                            setState(() {
                              currentDate = currentDate.subtract(const Duration(days: 1));
                              controller.clear();
                            });
                            focusNode.requestFocus();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (val) {
                      final parsed = double.tryParse(val);
                      if (parsed != null) {
                        provider.addWeight(parsed, currentDate, settings.preferredUnit);
                        setState(() {
                          currentDate = currentDate.subtract(const Duration(days: 1));
                          controller.clear();
                        });
                        focusNode.requestFocus();
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  const Text('Press Enter or tap Check to save and move to previous day.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
        if (provider.isLoading || settings.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = provider.entries;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.playlist_add, color: AppColors.primaryGreen),
                          onPressed: () => _showBulkAddModal(context, provider, settings),
                        ),
                        if (entries.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.download, color: AppColors.primaryGreen),
                            onPressed: () => _exportCSV(entries, settings.preferredUnit),
                          ),
                      ],
                    ),
                  ],
                ),
            const SizedBox(height: 4),
            const Text(
              'Recorded logs and 7-day average variance.',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 32),
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48.0),
                    child: Center(
                      child: Text(
                        'No weight records found.',
                        style: TextStyle(color: AppColors.textLight, fontSize: 16),
                      ),
                    ),
                  )
                else
                  ..._buildHistoryList(entries, provider, settings, context),
                const SizedBox(height: 48),
                if (entries.isNotEmpty)
                  const Center(
                    child: Text(
                      'END OF RECORDS',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1.5,
                        color: AppColors.textLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 80), // padding for FAB
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildHistoryList(List<WeightEntry> entries, WeightProvider provider, SettingsProvider settings, BuildContext context) {
    List<Widget> widgets = [];
    String currentMonthYear = '';

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final monthYear = DateFormat('MMMM yyyy').format(entry.date).toUpperCase();

      if (monthYear != currentMonthYear) {
        if (i > 0) widgets.add(const SizedBox(height: 24));
        widgets.add(_buildMonthSection(monthYear));
        currentMonthYear = monthYear;
      }

      final day = DateFormat('dd').format(entry.date);
      final month = DateFormat('MMM').format(entry.date).toUpperCase();
      final time = DateFormat('hh:mm a').format(entry.date);

      double displayWeight = entry.weight;
      if (settings.preferredUnit == 'KG') {
         displayWeight /= 2.20462;
      }
      final weightStr = displayWeight.toStringAsFixed(1);

      // Calculate variance from previous 7 days
      final avgLbs = provider.getRollingAverage(7, endDate: entry.date.subtract(const Duration(days: 1)));

      String varianceStr = '--';
      bool isNegativeVariance = true;

      if (avgLbs != null) {
        double avg = settings.preferredUnit == 'KG' ? avgLbs / 2.20462 : avgLbs;
        final variance = displayWeight - avg;
        isNegativeVariance = variance <= 0;
        varianceStr = '${variance > 0 ? '+' : ''}${variance.toStringAsFixed(1)}';
      }

      widgets.add(
        InkWell(
          onTap: () => _editEntry(context, entry, provider, settings),
          borderRadius: BorderRadius.circular(12),
          child: _buildLogEntry(day, month, time, weightStr, varianceStr, isNegativeVariance, settings.preferredUnit)
        )
      );
    }

    return widgets;
  }

  Widget _buildMonthSection(String monthText) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Text(
            monthText,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              height: 1,
              color: AppColors.dividerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(
      String day, String month, String time, String weight, String variance, bool isNegativeVariance, String unit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    month,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  Text(
                    day,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                  const Text(
                    'TIMESTAMP',
                    style: TextStyle(
                        fontSize: 10, letterSpacing: 1.0, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      weight,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textDark),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      unit,
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textLight),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isNegativeVariance ? Icons.trending_down : Icons.trending_up,
                      size: 14,
                      color: isNegativeVariance ? AppColors.positiveGreen : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      variance,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isNegativeVariance ? AppColors.positiveGreen : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'vs 7D AVG',
                      style: TextStyle(
                          fontSize: 10, color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
