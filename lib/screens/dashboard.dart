import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';
import '../providers/settings_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedTimeSpan = '1 MONTH';

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
        if (provider.isLoading || settings.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weight Momentum',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
            const SizedBox(height: 4),
            const Text(
              'Focusing on your weight trends over time.',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 16),
            _buildTimePills(),
            const SizedBox(height: 24),
                _buildChartCard(provider, settings),
                if (provider.hasDataSpan(7)) _buildWeeklyMomentumCard(provider, settings),
                _buildProgressCard(provider, settings),
                const SizedBox(height: 80), // padding for fab if any or bottom nav
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimePills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.dividerColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPill('1 WEEK'),
            _buildPill('2 WEEKS'),
            _buildPill('1 MONTH'),
            _buildPill('1 YEAR'),
            _buildPill('ALL TIME'),
          ],
        ),
      ),
    );
  }

  Widget _buildPill(String text) {
    final bool isSelected = _selectedTimeSpan == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTimeSpan = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: isSelected ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(WeightProvider provider, SettingsProvider settings) {
    if (provider.entries.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: const Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text(
              'No weight data yet. Log your weight to see your trend.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textLight, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // Filter entries based on selected time span
    final now = DateTime.now();
    DateTime startDate;
    int maxDays = 0;

    switch (_selectedTimeSpan) {
      case '1 WEEK':
        maxDays = 7;
        startDate = now.subtract(const Duration(days: 7));
        break;
      case '2 WEEKS':
        maxDays = 14;
        startDate = now.subtract(const Duration(days: 14));
        break;
      case '1 MONTH':
        maxDays = 30;
        startDate = now.subtract(const Duration(days: 30));
        break;
      case '1 YEAR':
        maxDays = 365;
        startDate = now.subtract(const Duration(days: 365));
        break;
      case 'ALL TIME':
      default:
        // Use earliest entry
        if (provider.entries.isNotEmpty) {
           startDate = provider.entries.last.date;
        } else {
           startDate = now.subtract(const Duration(days: 30));
        }
        maxDays = now.difference(startDate).inDays;
        break;
    }

    final entries = List.from(provider.entries.where((e) => e.date.isAfter(startDate.subtract(const Duration(days: 1)))).toList().reversed);

    // Map entries to FlSpot and adjust weights based on preferred unit
    List<FlSpot> dotsSpots = [];
    List<FlSpot> trendSpots = [];

    double minWeight = double.infinity;
    double maxWeight = double.negativeInfinity;

    if (entries.isNotEmpty) {
      for (var entry in entries) {
        double displayWeight = entry.weight;
        if (settings.preferredUnit == 'KG') {
           displayWeight = displayWeight / 2.20462;
        }

        if (displayWeight < minWeight) minWeight = displayWeight;
        if (displayWeight > maxWeight) maxWeight = displayWeight;

        final daysFromStart = entry.date.difference(startDate).inDays.toDouble();
        dotsSpots.add(FlSpot(daysFromStart >= 0 ? daysFromStart : 0, displayWeight));
      }

      // Compute trend line (7-day rolling average)
      for (int i = 0; i <= maxDays; i++) {
        final date = startDate.add(Duration(days: i));
        // Find if we have enough data up to this point
        final rollingAvg = provider.getRollingAverage(7, endDate: date);
        if (rollingAvg != null) {
            double displayAvg = rollingAvg;
            if (settings.preferredUnit == 'KG') {
               displayAvg = displayAvg / 2.20462;
            }
            trendSpots.add(FlSpot(i.toDouble(), displayAvg));

            if (displayAvg < minWeight) minWeight = displayAvg;
            if (displayAvg > maxWeight) maxWeight = displayAvg;
        }
      }

      // Fallback if trend spots are empty but we have data (e.g., less than 7 days of data total)
      if (trendSpots.isEmpty && dotsSpots.isNotEmpty) {
        trendSpots = List.from(dotsSpots);
      }
    }

    if (minWeight == double.infinity) {
      minWeight = 0;
      maxWeight = 10; // defaults
    } else {
      minWeight = (minWeight - 2).floorToDouble();
      maxWeight = (maxWeight + 2).ceilToDouble();
    }

    final double maxX = maxDays > 0 ? maxDays.toDouble() : 1.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  'WEIGHT MOVEMENT (${settings.preferredUnit})',
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitlesWidget: (value, meta) {
                          if (maxX <= 0) return const SizedBox();

                          // Display date for first, last, and middle points
                          if (value == 0 || value == maxX || value == (maxX / 2).roundToDouble()) {
                             final date = startDate.add(Duration(days: value.toInt()));
                             const style = TextStyle(color: AppColors.textLight, fontSize: 10);
                             return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Text(DateFormat('MMM dd').format(date).toUpperCase(), style: style),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: maxX,
                  minY: minWeight,
                  maxY: maxWeight,
                  lineBarsData: [
                    if (settings.showDailyData && dotsSpots.isNotEmpty)
                      LineChartBarData(
                        spots: dotsSpots,
                        isCurved: false,
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        barWidth: 0, // hide line, only show dots
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(radius: 3, color: AppColors.primaryGreen.withOpacity(0.4), strokeWidth: 0);
                        }),
                        belowBarData: BarAreaData(show: false),
                      ),
                    if (trendSpots.isNotEmpty)
                      LineChartBarData(
                        spots: trendSpots,
                        isCurved: true,
                        color: AppColors.primaryGreen,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: trendSpots.length < 10),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppColors.primaryGreen.withOpacity(0.05),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyMomentumCard(WeightProvider provider, SettingsProvider settings) {
    final current7DayAvgLbs = provider.getRollingAverage(7);
    final previous7DayAvgLbs = provider.getRollingAverage(7, endDate: DateTime.now().subtract(const Duration(days: 7)));

    if (current7DayAvgLbs == null || previous7DayAvgLbs == null) {
      return const SizedBox();
    }

    double diff = current7DayAvgLbs - previous7DayAvgLbs;
    if (settings.preferredUnit == 'KG') {
       diff = diff / 2.20462;
    }

    final isDown = diff <= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'WEEKLY MOMENTUM',
                  style: TextStyle(fontSize: 12, letterSpacing: 1.0, color: AppColors.textDark),
                ),
                Icon(Icons.trending_down, color: AppColors.primaryGreen, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  diff.abs().toStringAsFixed(1),
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: isDown ? AppColors.primaryGreen : Colors.red),
                ),
                const SizedBox(width: 4),
                Text(
                  settings.preferredUnit,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDown ? AppColors.primaryGreen : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isDown ? 'Weight is trending downward compared to last week' : 'Weight is trending upward compared to last week',
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(WeightProvider provider, SettingsProvider settings) {
    if (provider.entries.isEmpty) return const SizedBox();

    double currentWeightLbs = provider.entries.first.weight;
    double currentWeight = settings.preferredUnit == 'KG' ? currentWeightLbs / 2.20462 : currentWeightLbs;

    double diffToGoal = currentWeight - settings.goalWeight;
    bool hasReachedGoal = diffToGoal <= 0;

    // Forecast logic
    String forecastText = '';
    if (provider.hasDataSpan(7) && !hasReachedGoal) {
      final current7DayAvgLbs = provider.getRollingAverage(7);
      final previous7DayAvgLbs = provider.getRollingAverage(7, endDate: DateTime.now().subtract(const Duration(days: 7)));

      if (current7DayAvgLbs != null && previous7DayAvgLbs != null) {
         final diffLbs = current7DayAvgLbs - previous7DayAvgLbs;
         double goalLbs = settings.preferredUnit == 'KG' ? settings.goalWeight * 2.20462 : settings.goalWeight;

         if (diffLbs < 0 && current7DayAvgLbs > goalLbs) {
            final dailyRate = diffLbs / 7.0;
            final daysToGoal = ((current7DayAvgLbs - goalLbs) / -dailyRate).round();
            final forecastDate = DateTime.now().add(Duration(days: daysToGoal));
            forecastText = "Projected goal date: ${DateFormat('MMMM d, yyyy').format(forecastDate)}";
         } else if (diffLbs > 0) {
            forecastText = "Weight is currently trending upwards.";
         }
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'GOAL PROGRESS',
                  style: TextStyle(fontSize: 12, letterSpacing: 1.0, color: AppColors.textDark),
                ),
                Icon(Icons.flag, color: AppColors.dividerColor, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            if (hasReachedGoal)
               const Text(
                 'Congratulations! You have reached your goal.',
                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
               )
            else ...[
               Text(
                 '${diffToGoal.toStringAsFixed(1)} ${settings.preferredUnit} REMAINING',
                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
               ),
               if (forecastText.isNotEmpty) ...[
                 const SizedBox(height: 8),
                 Text(
                   forecastText,
                   style: const TextStyle(fontSize: 14, color: AppColors.textLight),
                 ),
                 const SizedBox(height: 8),
                 Text(
                   'BASED ON YOUR 1-WEEK MOMENTUM',
                   style: TextStyle(fontSize: 10, letterSpacing: 1.0, color: AppColors.textDark.withOpacity(0.7)),
                 ),
               ]
            ],
          ],
        ),
      ),
    );
  }
}
