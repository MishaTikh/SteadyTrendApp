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
  late ScrollController _scrollController;
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

        // 1 unit = 100 pixels (since each 0.1 increment is 10 pixels wide)
        _scrollController = ScrollController(
          initialScrollOffset: _currentWeight * 100,
        );
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    Provider.of<WeightProvider>(
      context,
      listen: false,
    ).addWeight(_currentWeight, _selectedDate, _selectedUnit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Weight logged successfully!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _showManualWeightEntry() {
    final TextEditingController controller = TextEditingController(
      text: _currentWeight.toStringAsFixed(1),
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Weight'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Weight ($_selectedUnit)',
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              final parsed = double.tryParse(value);
              if (parsed != null && parsed >= 0) {
                Navigator.pop(context);
                _scrollController.animateTo(
                  parsed * 100,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final parsed = double.tryParse(controller.text);
                if (parsed != null && parsed >= 0) {
                  Navigator.pop(context);
                  _scrollController.animateTo(
                    parsed * 100,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    ).then((_) => controller.dispose());
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 48.0,
                  ),
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
                            width: 180,
                            child: GestureDetector(
                              onTap: _showManualWeightEntry,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _currentWeight.toStringAsFixed(1),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                    height: 1.0,
                                  ),
                                ),
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
                          child: const Text(
                            'Confirm Weight',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
    if (_selectedDate.year == DateTime.now().year &&
        _selectedDate.month == DateTime.now().month &&
        _selectedDate.day == DateTime.now().day) {
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
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: AppColors.primaryGreen,
          ),
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
                color: _selectedUnit == 'LBS'
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'LBS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _selectedUnit == 'LBS'
                      ? Colors.white
                      : AppColors.textDark,
                ),
              ),
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
                color: _selectedUnit == 'KG'
                    ? AppColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'KG',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _selectedUnit == 'KG'
                      ? Colors.white
                      : AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualRuler() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;

        return SizedBox(
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification notification) {
                  if (notification is ScrollUpdateNotification) {
                    setState(() {
                      _currentWeight = notification.metrics.pixels / 100;
                      if (_currentWeight < 0) _currentWeight = 0;
                    });
                  }
                  return true;
                },
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: halfWidth),
                  itemBuilder: (context, index) {
                    final isWholeNumber = index % 10 == 0;
                    final isHalfNumber = index % 5 == 0 && !isWholeNumber;

                    double height = 16;
                    if (isWholeNumber)
                      height = 40;
                    else if (isHalfNumber)
                      height = 24;

                    return Container(
                      width: 10,
                      alignment: Alignment.center,
                      child: Container(
                        width: 2,
                        height: height,
                        color: isWholeNumber
                            ? AppColors.textDark
                            : AppColors.dividerColor,
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
