import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';
import '../models/weight_entry.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            Consumer<WeightProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final entries = provider.entries;
                if (entries.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48.0),
                      child: Text(
                        'NO RECORDS YET',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.5,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }

                // Group by Month/Year
                Map<String, List<WeightEntry>> grouped = {};
                for (var entry in entries) {
                  final key = '${_getFullMonth(entry.date.month)} ${entry.date.year}';
                  if (!grouped.containsKey(key)) {
                    grouped[key] = [];
                  }
                  grouped[key]!.add(entry);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final monthKey = grouped.keys.elementAt(index);
                    final monthEntries = grouped[monthKey]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthSection(monthKey),
                        ...monthEntries.map((entry) {
                           final variance = provider.getVarianceForEntry(entry);
                           return _buildDynamicLogEntry(entry, variance, provider, context);
                        }),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                );
              },
            ),
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
  }

  String _getFullMonth(int month) {
    switch (month) {
      case 1: return 'JANUARY';
      case 2: return 'FEBRUARY';
      case 3: return 'MARCH';
      case 4: return 'APRIL';
      case 5: return 'MAY';
      case 6: return 'JUNE';
      case 7: return 'JULY';
      case 8: return 'AUGUST';
      case 9: return 'SEPTEMBER';
      case 10: return 'OCTOBER';
      case 11: return 'NOVEMBER';
      case 12: return 'DECEMBER';
      default: return '';
    }
  }

  String _getShortMonth(int month) {
    switch (month) {
      case 1: return 'JAN';
      case 2: return 'FEB';
      case 3: return 'MAR';
      case 4: return 'APR';
      case 5: return 'MAY';
      case 6: return 'JUN';
      case 7: return 'JUL';
      case 8: return 'AUG';
      case 9: return 'SEP';
      case 10: return 'OCT';
      case 11: return 'NOV';
      case 12: return 'DEC';
      default: return '';
    }
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

  Widget _buildDynamicLogEntry(WeightEntry entry, double? variance, WeightProvider provider, BuildContext context) {
    final day = entry.date.day.toString().padLeft(2, '0');
    final month = _getShortMonth(entry.date.month);

    // Time formatting
    int hour = entry.date.hour;
    final isPM = hour >= 12;
    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;
    final minute = entry.date.minute.toString().padLeft(2, '0');
    final time = '${hour.toString().padLeft(2, '0')}:$minute ${isPM ? 'PM' : 'AM'}';

    final weight = entry.weight.toStringAsFixed(1);

    String varianceStr = '--';
    bool isNegativeVariance = false;

    if (variance != null) {
      isNegativeVariance = variance < 0;
      final signStr = variance > 0 ? '+' : '';
      varianceStr = '$signStr${variance.toStringAsFixed(1)}';
    }

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
                if (variance != null)
                  Row(
                    children: [
                      Icon(
                        isNegativeVariance ? Icons.trending_down : Icons.trending_up,
                        size: 14,
                        color: isNegativeVariance ? AppColors.positiveGreen : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        varianceStr,
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
                  )
                else
                  const Text(
                    'Needs more data',
                    style: TextStyle(
                        fontSize: 10, color: AppColors.textLight),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.dividerColor, size: 20),
              onPressed: () {
                provider.deleteEntry(entry.id);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted.')));
              },
            ),
          ],
        ),
      ),
    );
  }
}
