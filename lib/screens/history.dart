import 'package:flutter/material.dart';
import '../main.dart'; // for AppColors

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
            _buildMonthSection('SEPTEMBER 2023'),
            _buildLogEntry('28', 'SEP', '07:14 AM', '82.4', '-0.2', true),
            _buildLogEntry('25', 'SEP', '08:00 AM', '82.6', '+0.5', false),
            const SizedBox(height: 24),
            _buildMonthSection('AUGUST 2023'),
            _buildLogEntry('30', 'AUG', '07:30 AM', '82.1', '-1.2', true),
            const SizedBox(height: 48),
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
