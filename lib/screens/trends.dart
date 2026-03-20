import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({super.key});

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Your weight is\ntrending down.', // Will be updated dynamically below
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Keep logging data consistently to see your trends update in real-time.',
              style: TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.4),
            ),
            const SizedBox(height: 24),
            Consumer<WeightProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    _buildAverageDeltaCard(provider),
                    const SizedBox(height: 24),
                    _build1WeekChangeCard(provider),
                    _build2WeekChangeCard(provider),
                    _build1MonthChangeCard(provider),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            _buildLogWeightCard(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageDeltaCard(WeightProvider provider) {
    final delta = provider.averageMonthlyDelta;
    String deltaStr = 'Needs Data';
    IconData icon = Icons.trending_flat;
    Color color = AppColors.textLight;

    if (delta != null) {
      deltaStr = '${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)}kg';
      icon = delta < 0 ? Icons.trending_down : Icons.trending_up;
      color = delta < 0 ? AppColors.primaryGreen : Colors.red;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
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
                deltaStr,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build1WeekChangeCard(WeightProvider provider) {
    final current = provider.current7DayAverage;
    final previous = provider.previous7DayAverage;
    if (current == null || previous == null) return const SizedBox.shrink();

    return _buildChangeCard(
      '1-Week Average\nChange',
      'Based on your last 7 days.',
      '${current.toStringAsFixed(1)}kg',
      '${previous.toStringAsFixed(1)}kg',
      current,
      previous,
    );
  }

  Widget _build2WeekChangeCard(WeightProvider provider) {
    final current = provider.current14DayAverage;
    final previous = provider.previous14DayAverage;
    if (current == null || previous == null) return const SizedBox.shrink();

    return _buildChangeCard(
      '2-Week Average Change',
      'Based on your last 14 days.',
      '${current.toStringAsFixed(1)}kg',
      '${previous.toStringAsFixed(1)}kg',
      current,
      previous,
    );
  }

  Widget _build1MonthChangeCard(WeightProvider provider) {
    final current = provider.current30DayAverage;
    final previous = provider.previous30DayAverage;
    if (current == null || previous == null) return const SizedBox.shrink();

    return _buildChangeCard(
      '1-Month Average Change',
      'Based on your last 30 days.',
      '${current.toStringAsFixed(1)}kg',
      '${previous.toStringAsFixed(1)}kg',
      current,
      previous,
    );
  }

  Widget _buildChangeCard(String title, String subtitle, String currentValStr, String prevValStr, double currentVal, double prevVal) {
    final deltaVal = currentVal - prevVal;
    final deltaPctVal = (deltaVal / prevVal) * 100;

    final signStr = deltaVal > 0 ? '+' : '';
    final delta = '$signStr${deltaVal.toStringAsFixed(1)}kg';
    final deltaPct = '${deltaPctVal.toStringAsFixed(1)}%';

    final isDown = deltaVal < 0;
    final color = isDown ? AppColors.primaryGreen : Colors.red;
    final icon = isDown ? Icons.arrow_drop_down : Icons.arrow_drop_up;

    // mock progress logic for visual bar
    double maxVal = currentVal > prevVal ? currentVal : prevVal;
    // pad max val for visual scale
    maxVal = maxVal + 10;
    double currentProgress = currentVal / maxVal;
    double prevProgress = prevVal / maxVal;

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
                  child: Text(currentValStr, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
                  child: Text(prevValStr, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Text('DELTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(delta, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: color, size: 16),
                        Text(deltaPct, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
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

  Widget _buildLogWeightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Log Weight',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Daily logs increase precision of trend\nmodels.',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      hintText: '00.0',
                      hintStyle: TextStyle(fontSize: 24, color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                Text(
                  'KG',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                final text = _weightController.text;
                if (text.isNotEmpty) {
                  final weight = double.tryParse(text);
                  if (weight != null) {
                    await Provider.of<WeightProvider>(context, listen: false).addEntry(DateTime.now(), weight);
                    _weightController.clear();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight logged!')));
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text('Save Entry', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
