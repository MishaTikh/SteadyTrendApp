import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';
import '../models/weight_entry.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final entries = provider.entries;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'History',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
            const SizedBox(height: 4),
            const Text(
              'Recorded logs and 7-day average variance.',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
                Row(
                  children: [
                    _buildFilterPill('All Weight', true),
                    const SizedBox(width: 8),
                    _buildFilterPill('Metric Variations', false),
                  ],
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
                  ..._buildHistoryList(entries, provider),
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

  List<Widget> _buildHistoryList(List<WeightEntry> entries, WeightProvider provider) {
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
      final weightStr = entry.weight.toStringAsFixed(1);

      // Calculate variance from previous 7 days
      final avg = provider.getRollingAverage(7, endDate: entry.date.subtract(const Duration(days: 1)));

      String varianceStr = '--';
      bool isNegativeVariance = true;

      if (avg != null) {
        final variance = entry.weight - avg;
        isNegativeVariance = variance <= 0;
        varianceStr = '${variance > 0 ? '+' : ''}${variance.toStringAsFixed(1)}';
      }

      widgets.add(_buildLogEntry(day, month, time, weightStr, varianceStr, isNegativeVariance));
    }

    return widgets;
  }

  Widget _buildFilterPill(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryGreen : AppColors.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textDark,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
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
      String day, String month, String time, String weight, String variance, bool isNegativeVariance) {
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
                    const Text(
                      'KG',
                      style: TextStyle(
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
