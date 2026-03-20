import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WeightProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
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
            const SizedBox(height: 16),
            _buildDailyDataToggle(),
            const SizedBox(height: 16),
                _buildChartCard(provider),
                if (provider.hasDataSpan(7)) _buildWeeklyMomentumCard(provider),
                _buildProgressCard(),
                if (provider.hasDataSpan(7)) _buildForecastCard(provider),
                const SizedBox(height: 80), // padding for fab if any or bottom nav
              ],
            ),
          ),
        );
      },
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

  Widget _buildChartCard(WeightProvider provider) {
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

    final entries = List.from(provider.entries.reversed);

    // Calculate min/max for chart bounds
    double minWeight = double.infinity;
    double maxWeight = double.negativeInfinity;

    for (var entry in entries) {
      if (entry.weight < minWeight) minWeight = entry.weight;
      if (entry.weight > maxWeight) maxWeight = entry.weight;
    }

    // Add padding to bounds
    minWeight = (minWeight - 2).floorToDouble();
    maxWeight = (maxWeight + 2).ceilToDouble();

    // Map entries to FlSpot
    List<FlSpot> spots = [];
    if (entries.length == 1) {
       spots.add(FlSpot(0, entries[0].weight));
       spots.add(FlSpot(1, entries[0].weight));
    } else {
      final firstDate = entries.first.date;
      for (var entry in entries) {
        final days = entry.date.difference(firstDate).inDays.toDouble();
        spots.add(FlSpot(days, entry.weight));
      }
    }

    final maxX = spots.last.x;

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
                          if (entries.isEmpty) return const SizedBox();

                          // Display date for first, last, and maybe middle points
                          if (value == 0 || value == maxX || (maxX > 0 && value == (maxX / 2).roundToDouble())) {
                             final firstDate = entries.first.date;
                             final date = firstDate.add(Duration(days: value.toInt()));
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
                  maxX: maxX > 0 ? maxX : 1,
                  minY: minWeight,
                  maxY: maxWeight,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primaryGreen,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: spots.length < 10),
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

  Widget _buildWeeklyMomentumCard(WeightProvider provider) {
    final current7DayAvg = provider.getRollingAverage(7);
    final previous7DayAvg = provider.getRollingAverage(7, endDate: DateTime.now().subtract(const Duration(days: 7)));

    if (current7DayAvg == null || previous7DayAvg == null) {
      return const SizedBox();
    }

    final diff = current7DayAvg - previous7DayAvg;
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
                  'KG', // keeping default as KG
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

  Widget _buildProgressCard() {
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
                const Text(
                  '65% OF JOURNEY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                Text(
                  '9.2 LBS REMAINING',
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
                  widthFactor: 0.65,
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
  }

  Widget _buildForecastCard(WeightProvider provider) {
    final current7DayAvg = provider.getRollingAverage(7);
    final previous7DayAvg = provider.getRollingAverage(7, endDate: DateTime.now().subtract(const Duration(days: 7)));

    if (current7DayAvg == null || previous7DayAvg == null) {
      return const SizedBox();
    }

    final diff = current7DayAvg - previous7DayAvg;
    // Assume a goal weight of 70kg for display purposes, as we don't have user settings yet
    const double goalWeight = 70.0;

    if (diff >= 0 || current7DayAvg <= goalWeight) {
      return const SizedBox(); // Not losing weight or already reached goal
    }

    // Days to reach goal = (current - goal) / (-diff/7 days)
    final dailyRate = diff / 7.0;
    final daysToGoal = ((current7DayAvg - goalWeight) / -dailyRate).round();
    final forecastDate = DateTime.now().add(Duration(days: daysToGoal));

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
                  TextSpan(text: DateFormat('MMMM d').format(forecastDate), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
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
  }
}
