import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../main.dart'; // for AppColors
import '../providers/weight_provider.dart';
import '../providers/settings_provider.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedUnit = 'LBS';
  double _currentWeight = 150.0;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final provider = Provider.of<WeightProvider>(context, listen: false);
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      setState(() {
        _selectedUnit = settings.preferredUnit;
        if (provider.entries.isNotEmpty) {
          double lastWeight = provider.entries.first.weight; // stored in LBS
          if (_selectedUnit == 'KG') {
            _currentWeight = lastWeight / 2.20462;
          } else {
            _currentWeight = lastWeight;
          }
        } else {
          _currentWeight = _selectedUnit == 'KG' ? 70.0 : 150.0;
        }
        _initialized = true;
      });
    }
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: AppColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveWeight() {
    Provider.of<WeightProvider>(context, listen: false)
        .addWeight(_currentWeight, _selectedDate, _selectedUnit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight logged successfully!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
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
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: _buildDatePickerPill(),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 150,
                            child: TextField(
                              controller: TextEditingController(text: _currentWeight.toStringAsFixed(1))
                                ..selection = TextSelection.fromPosition(TextPosition(offset: _currentWeight.toStringAsFixed(1).length)),
                              onChanged: (val) {
                                final parsed = double.tryParse(val);
                                if (parsed != null) {
                                  _currentWeight = parsed;
                                }
                              },
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 64, // adjusted to fit textfield well
                                fontWeight: FontWeight.w900,
                                color: AppColors.textDark,
                                height: 1.0,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
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
                          onPressed: _saveWeight,
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
    String dateText = DateFormat('MMM dd').format(_selectedDate).toUpperCase();
    if (_selectedDate.year == DateTime.now().year && _selectedDate.month == DateTime.now().month && _selectedDate.day == DateTime.now().day) {
      dateText = 'TODAY, $dateText';
    }

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

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.dividerColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (_selectedUnit != 'LBS') {
                setState(() {
                  _selectedUnit = 'LBS';
                  _currentWeight = _currentWeight * 2.20462;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedUnit == 'LBS' ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('LBS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _selectedUnit == 'LBS' ? Colors.white : AppColors.textDark)),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_selectedUnit != 'KG') {
                setState(() {
                  _selectedUnit = 'KG';
                  _currentWeight = _currentWeight / 2.20462;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _selectedUnit == 'KG' ? AppColors.primaryGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('KG', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _selectedUnit == 'KG' ? Colors.white : AppColors.textDark)),
            ),
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
