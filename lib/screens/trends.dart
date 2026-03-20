import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';
import '../providers/settings_provider.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<WeightProvider, SettingsProvider>(
      builder: (context, provider, settings, child) {
        if (provider.isLoading || settings.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool has7Days = provider.hasDataSpan(7);
        final bool has14Days = provider.hasDataSpan(14);
        final bool has30Days = provider.hasDataSpan(30);

        // Calculate main trend text
        String titleText = 'No trend yet';
        String subtitleText = 'Log more weight entries to see your progress.';

        if (has7Days) {
          final current7DayAvgLbs = provider.getRollingAverage(7) ?? 0;
          final prev7DayAvgLbs = provider.getRollingAverage(7, endDate: DateTime.now().subtract(const Duration(days: 7))) ?? 0;
          double diff = current7DayAvgLbs - prev7DayAvgLbs;

          if (settings.preferredUnit == 'KG') {
             diff /= 2.20462;
          }

          if (diff < -0.2) {
            titleText = 'Your weight is\ntrending down.';
            subtitleText = 'You are making steady progress. Based on the last week, your weight is consistently moving in the right direction.';
          } else if (diff > 0.2) {
            titleText = 'Your weight is\ntrending up.';
            subtitleText = 'Your average weight has increased over the last week. Stay consistent with your logs.';
          } else {
            titleText = 'Your weight is\nstable.';
            subtitleText = 'Your weight has remained relatively stable over the last week.';
          }
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PROGRESS UPDATE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitleText,
                  style: const TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.4),
                ),
                const SizedBox(height: 24),
                if (has30Days) _buildAverageDeltaCard(provider, settings),
                if (has30Days) const SizedBox(height: 24),

                if (has7Days) _buildChangeCard(
                  provider,
                  settings,
                  '1-Week Average\nChange',
                  7,
                ),
                if (has14Days) _buildChangeCard(
                  provider,
                  settings,
                  '2-Week Average Change',
                  14,
                ),
                if (has30Days) _buildChangeCard(
                  provider,
                  settings,
                  '1-Month Average Change',
                  30,
                ),

                if (!has7Days) const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text(
                      'Keep logging your weight. Trends will appear here once you have at least 7 days of data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textLight, fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 8),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      },
    );
  }
  Widget _buildAverageDeltaCard(WeightProvider provider, SettingsProvider settings) {
    final current30DayAvgLbs = provider.getRollingAverage(30) ?? 0;
    final prev30DayAvgLbs = provider.getRollingAverage(30, endDate: DateTime.now().subtract(const Duration(days: 30))) ?? 0;
    double diff = current30DayAvgLbs - prev30DayAvgLbs;
    if (settings.preferredUnit == 'KG') {
       diff /= 2.20462;
    }
    final isDown = diff <= 0;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: AppColors.primaryGreen, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(isDown ? Icons.trending_down : Icons.trending_up, color: isDown ? AppColors.primaryGreen : Colors.red, size: 28),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AVG. MONTHLY DELTA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} ${settings.preferredUnit}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDown ? AppColors.primaryGreen : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeCard(WeightProvider provider, SettingsProvider settings, String title, int days) {
    final currentAvgLbs = provider.getRollingAverage(days) ?? 0;
    final prevAvgLbs = provider.getRollingAverage(days, endDate: DateTime.now().subtract(Duration(days: days))) ?? 0;

    if (prevAvgLbs == 0) return const SizedBox(); // Need previous period data too

    double currentAvg = settings.preferredUnit == 'KG' ? currentAvgLbs / 2.20462 : currentAvgLbs;
    double prevAvg = settings.preferredUnit == 'KG' ? prevAvgLbs / 2.20462 : prevAvgLbs;

    final diff = currentAvg - prevAvg;
    final diffPct = (diff / prevAvg) * 100;
    final isDown = diff <= 0;

    String subtitle = '';
    if (days == 7) {
      subtitle = isDown ? 'Your weight has dropped slightly this week.' : 'Your weight has increased this week.';
    } else if (days == 14) {
      subtitle = isDown ? 'You are maintaining a good downward pace.' : 'Your weight trend is upward over two weeks.';
    } else {
      subtitle = isDown ? 'Your average is lower over the last month.' : 'Your average is higher over the last month.';
    }

    // Progress bar visualization logic: assuming max weight for bounds is prevAvg + 5, min is currentAvg - 5
    // Very simple normalization for progress bars just to show relative size
    double maxW = (prevAvg > currentAvg ? prevAvg : currentAvg) + 10;
    double currentProgress = currentAvg / maxW;
    double prevProgress = prevAvg / maxW;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                if (title.contains('1-Week'))
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.dividerColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      'RECENT\nCHANGE',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('CURRENT AVG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textLight)),
                const Text('PREVIOUS AVG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textLight)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 8, decoration: BoxDecoration(color: AppColors.dividerColor, borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: currentProgress,
                        child: Container(height: 8, decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 60,
                  child: Text('${currentAvg.toStringAsFixed(1)} ${settings.preferredUnit}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 8, decoration: BoxDecoration(color: AppColors.dividerColor.withOpacity(0.3), borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: prevProgress,
                        child: Container(height: 8, decoration: BoxDecoration(color: AppColors.textLight.withOpacity(0.4), borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 60,
                  child: Text('${prevAvg.toStringAsFixed(1)} ${settings.preferredUnit}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isDown ? AppColors.primaryGreen.withOpacity(0.05) : Colors.red.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDown ? AppColors.primaryGreen.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Text('DELTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text('${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} ${settings.preferredUnit}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDown ? AppColors.primaryGreen : Colors.red)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isDown ? Icons.arrow_drop_down : Icons.arrow_drop_up, color: isDown ? AppColors.primaryGreen : Colors.red, size: 16),
                        Text('${diffPct.abs().toStringAsFixed(1)}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDown ? AppColors.primaryGreen : Colors.red)),
                      ],
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

}
