import 'package:flutter/material.dart';
import '../main.dart'; // for AppColors

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

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
              'Your weight is\ntrending down.',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'You are making steady progress.\nBased on the last 30 days, your weight\nis consistently moving in the right\ndirection.',
              style: TextStyle(fontSize: 16, color: AppColors.textDark, height: 1.4),
            ),
            const SizedBox(height: 24),
            _buildAverageDeltaCard(),
            const SizedBox(height: 24),
            _buildChangeCard(
              '1-Week Average\nChange',
              'Your weight has dropped\nslightly this week.',
              '82.1kg',
              '82.6kg',
              '-0.5kg',
              '- 0.6%',
              0.55,
              0.6,
            ),
            _buildChangeCard(
              '2-Week Average Change',
              'You are maintaining a good downward\npace.',
              '82.4kg',
              '83.5kg',
              '-1.1kg',
              '- 1.3%',
              0.5,
              0.55,
            ),
            _buildChangeCard(
              '1-Month Average Change',
              'Your average is lower over the last month.',
              '83.2kg',
              '85.6kg',
              '-2.4kg',
              '- 2.8%',
              0.45,
              0.55,
            ),
            const SizedBox(height: 8),
            _buildLogWeightCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildAverageDeltaCard() {
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
          Icon(Icons.trending_down, color: AppColors.primaryGreen, size: 28),
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
              const Text(
                '-2.4kg',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChangeCard(String title, String subtitle, String currentVal, String prevVal, String delta, String deltaPct, double currentProgress, double prevProgress) {
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
                  child: Text(currentVal, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
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
                  child: Text(prevVal, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryGreen.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    const Text('DELTA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.textLight)),
                    const SizedBox(height: 4),
                    Text(delta, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_drop_down, color: AppColors.primaryGreen, size: 16),
                        Text(deltaPct, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)),
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

  Widget _buildLogWeightCard() {
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
              onPressed: () {},
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
