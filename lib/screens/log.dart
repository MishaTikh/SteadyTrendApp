import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default mock start value or placeholder. Let's make it blank for actual entry.
  }

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
              'Log Daily Weight',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Consistency fuels the trend logic.',
              style: TextStyle(fontSize: 16, color: AppColors.textLight),
            ),
            const SizedBox(height: 24),
            Center(
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                  child: Column(
                    children: [
                      _buildDatePickerPill(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 160,
                            child: TextField(
                              controller: _weightController,
                              textAlign: TextAlign.center,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                hintText: '00.0',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  fontSize: 72, // Slightly smaller to fit nicely
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textLight.withOpacity(0.3),
                                  height: 1.0,
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 72,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                                height: 1.0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildUnitToggle(),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _buildVisualRuler(),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            final text = _weightController.text;
                            if (text.isNotEmpty) {
                              final weight = double.tryParse(text);
                              if (weight != null) {
                                await Provider.of<WeightProvider>(context, listen: false).addEntry(DateTime.now(), weight);
                                _weightController.clear();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Weight logged successfully!')));
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid number.')));
                                }
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text('Confirm Weight', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerPill() {
    final now = DateTime.now();
    final monthStr = _getShortMonth(now.month);
    final dayStr = now.day.toString().padLeft(2, '0');
    final dateText = 'TODAY, $monthStr $dayStr';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryGreen),
          const SizedBox(width: 8),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('KG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: const Text('LBS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualRuler() {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(9, (index) {
          final isCenter = index == 4;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: isCenter ? 4 : 2,
            height: isCenter ? 32 : 16,
            decoration: BoxDecoration(
              color: isCenter ? AppColors.primaryGreen.withOpacity(0.4) : AppColors.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}
