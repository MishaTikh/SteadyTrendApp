import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../main.dart'; // for AppColors

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
                          const style = TextStyle(color: AppColors.textLight, fontSize: 10);
                          String text = '';
                          if (value == 0) text = 'OCT 14';
                          else if (value == 3) text = 'OCT 21';
                          else if (value == 6) text = 'OCT 28';
                          else if (value == 9) text = 'NOV 04';
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
                  maxX: 9,
                  minY: 70,
                  maxY: 80,
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 72),
                        FlSpot(3, 73),
                        FlSpot(6, 75),
                        FlSpot(9, 77),
                      ],
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
  }

  Widget _buildWeeklyMomentumCard() {
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
                const Text(
                  '-1.4',
                  style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 4),
                Text(
                  'LBS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Weight is trending downward compared to last week',
              style: TextStyle(fontSize: 14, color: AppColors.textDark),
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

  Widget _buildForecastCard() {
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
              text: const TextSpan(
                style: TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.4),
                children: [
                  TextSpan(text: "At your current rate, you're projected to reach your goal by "),
                  TextSpan(text: "January 12", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
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
