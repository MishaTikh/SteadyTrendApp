import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox(height: 16),
            _buildDailyDataToggle(),
            const SizedBox(height: 16),
            _buildChartCard(),
            _buildWeeklyMomentumCard(),
            _buildProgressCard(),
            _buildForecastCard(),
            const SizedBox(height: 80), // padding for fab if any or bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildTimePills() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPill('1 WEEK', true),
          _buildPill('2 WEEKS', false),
          _buildPill('1 MONTH', false),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool isSelected) {
    return Container(
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
    );
  }

  Widget _buildDailyDataToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'DAILY DATA',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textLight),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 20,
            width: 36,
            child: Switch(
              value: true,
              onChanged: (val) {},
              activeColor: Colors.white,
              activeTrackColor: AppColors.primaryGreen,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Card(
            margin: EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final entries = provider.entries;
        if (entries.length < 2) {
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.show_chart, size: 48, color: AppColors.dividerColor),
                      const SizedBox(height: 16),
                      Text(
                        'Not enough data yet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Log your weight for at least two days to see your momentum chart.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.textLight),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // We want to show the entries in chronological order for the chart
        final chartEntries = List.of(entries)..sort((a, b) => a.date.compareTo(b.date));

        // Let's show up to the last 14 days if we have them, otherwise just whatever we have
        final cutoffDate = DateTime.now().subtract(const Duration(days: 14));
        final recentEntries = chartEntries.where((e) => e.date.isAfter(cutoffDate) || e.date.isAtSameMomentAs(cutoffDate)).toList();

        // If we don't have recent entries (maybe they stopped logging), just show the last 7 entries
        final displayEntries = recentEntries.isNotEmpty ? recentEntries : chartEntries.sublist(chartEntries.length > 7 ? chartEntries.length - 7 : 0);

        if (displayEntries.length < 2) {
            // Re-check just in case filtering left us with < 2
            return const Card(
              margin: EdgeInsets.only(bottom: 16),
              child: SizedBox(
                height: 200,
                child: Center(child: Text("Need more recent data", style: TextStyle(color: AppColors.textLight))),
              ),
            );
        }

        final minDate = displayEntries.first.date;
        final maxDate = displayEntries.last.date;
        final dateRange = maxDate.difference(minDate).inDays.toDouble();

        double minWeight = displayEntries.first.weight;
        double maxWeight = displayEntries.first.weight;
        for (var e in displayEntries) {
          if (e.weight < minWeight) minWeight = e.weight;
          if (e.weight > maxWeight) maxWeight = e.weight;
        }

        final spots = displayEntries.map((e) {
          final x = e.date.difference(minDate).inDays.toDouble();
          return FlSpot(x, e.weight);
        }).toList();

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
                    const Text(
                      'WEIGHT MOVEMENT',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.primaryGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 160,
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
                            interval: dateRange > 7 ? (dateRange / 4).ceilToDouble() : 1,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value > dateRange) return const SizedBox.shrink();
                              final date = minDate.add(Duration(days: value.toInt()));
                              final monthStr = _getMonthStr(date.month);
                              final text = '$monthStr ${date.day.toString().padLeft(2, '0')}';
                              const style = TextStyle(color: AppColors.textLight, fontSize: 10);
                              return SideTitleWidget(
                                meta: meta,
                                space: 8,
                                child: Text(text, style: style),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: dateRange,
                      minY: (minWeight - 2).floorToDouble(),
                      maxY: (maxWeight + 2).ceilToDouble(),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.primaryGreen,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
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
      },
    );
  }

  String _getMonthStr(int month) {
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

  Widget _buildWeeklyMomentumCard() {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        final change = provider.oneWeekChange;

        if (change == null) {
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
                      Icon(Icons.trending_flat, color: AppColors.textLight, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Need more data to calculate momentum',
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
          );
        }

        final isDown = change < 0;
        final icon = isDown ? Icons.trending_down : Icons.trending_up;
        final color = isDown ? AppColors.primaryGreen : Colors.red;
        final signStr = change > 0 ? '+' : '';

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
                    Icon(icon, color: color, size: 20),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$signStr${change.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: color),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'KG',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  isDown
                    ? 'Weight is trending downward compared to last week'
                    : 'Weight is trending upward compared to last week',
                  style: const TextStyle(fontSize: 14, color: AppColors.textDark),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressCard() {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        // Just mock some basic progress logic or show need more data.
        if (provider.entries.isEmpty) {
          return const SizedBox.shrink(); // Hide if empty
        }

        // Mock goal logic: Let's assume a goal of current max weight - 5kg
        double maxWeight = provider.entries.first.weight;
        for(var e in provider.entries) {
          if (e.weight > maxWeight) maxWeight = e.weight;
        }

        double currentWeight = provider.entries.first.weight;
        double goalWeight = maxWeight - 5.0;

        if (maxWeight - goalWeight <= 0) return const SizedBox.shrink();

        double progressPct = (maxWeight - currentWeight) / (maxWeight - goalWeight);
        if (progressPct < 0) progressPct = 0;
        if (progressPct > 1) progressPct = 1;

        double remaining = currentWeight - goalWeight;
        if (remaining < 0) remaining = 0;

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
                      'OVERALL PROGRESS',
                      style: TextStyle(fontSize: 12, letterSpacing: 1.0, color: AppColors.textDark),
                    ),
                    Icon(Icons.flag, color: AppColors.dividerColor, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${(progressPct * 100).toInt()}% OF JOURNEY',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    Text(
                      '${remaining.toStringAsFixed(1)} KG REMAINING',
                      style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.7)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.dividerColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progressPct,
                      child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForecastCard() {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        final change = provider.oneWeekChange;

        if (change == null || change >= 0) {
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
                        'GOAL FORECAST',
                        style: TextStyle(fontSize: 12, letterSpacing: 1.0, color: AppColors.textDark),
                      ),
                      Icon(Icons.calendar_today, color: AppColors.dividerColor, size: 20),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Need a consistent downward trend to calculate forecast.",
                    style: TextStyle(fontSize: 14, color: AppColors.textLight),
                  )
                ]
              )
            )
           );
        }

        // Extremely simplified forecast based on recent mocked progress logic
        double maxWeight = provider.entries.first.weight;
        for(var e in provider.entries) {
          if (e.weight > maxWeight) maxWeight = e.weight;
        }
        double currentWeight = provider.entries.first.weight;
        double goalWeight = maxWeight - 5.0;

        double remaining = currentWeight - goalWeight;

        int daysRemaining = 0;
        String dateStr = "";

        if (remaining > 0) {
          // change is negative (loss), e.g. -0.5 kg / week
          double dailyLoss = (-change) / 7.0;
          daysRemaining = (remaining / dailyLoss).ceil();
          final forecastDate = DateTime.now().add(Duration(days: daysRemaining));
          dateStr = '${_getMonthStr(forecastDate.month)} ${forecastDate.day}';
        } else {
          dateStr = 'Goal Reached!';
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
                      'GOAL FORECAST',
                      style: TextStyle(fontSize: 12, letterSpacing: 1.0, color: AppColors.textDark),
                    ),
                    Icon(Icons.calendar_today, color: AppColors.primaryGreen, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.4),
                    children: [
                      const TextSpan(text: "At your current rate, you're projected to reach your goal by "),
                      TextSpan(text: dateStr, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          children: List.generate(
                            10,
                            (index) => Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                height: 2,
                                color: AppColors.primaryGreen.withOpacity(0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'BASED ON YOUR 1-WEEK MOMENTUM',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.0, color: AppColors.textDark.withOpacity(0.7)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
