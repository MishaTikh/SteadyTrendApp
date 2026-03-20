import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<SettingsProvider>(context, listen: false);
    _goalController = TextEditingController(text: provider.goalWeight.toStringAsFixed(1));
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          if (settings.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle('PREFERENCES'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Preferred Unit', style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'LBS', label: Text('LBS')),
                          ButtonSegment(value: 'KG', label: Text('KG')),
                        ],
                        selected: {settings.preferredUnit},
                        onSelectionChanged: (Set<String> newSelection) {
                          String oldUnit = settings.preferredUnit;
                          String newUnit = newSelection.first;

                          // Convert the displayed goal weight in the text field if the unit changed
                          if (oldUnit != newUnit) {
                            double currentGoal = double.tryParse(_goalController.text) ?? settings.goalWeight;
                            if (newUnit == 'KG') {
                              currentGoal = currentGoal / 2.20462;
                            } else if (newUnit == 'LBS') {
                              currentGoal = currentGoal * 2.20462;
                            }
                            _goalController.text = currentGoal.toStringAsFixed(1);
                            settings.updateGoalWeight(currentGoal);
                          }

                          settings.updatePreferredUnit(newUnit);
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return AppColors.primaryGreen;
                              }
                              return null;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.selected)) {
                                return Colors.white;
                              }
                              return AppColors.textDark;
                            },
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('Goal Weight', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('In ${settings.preferredUnit}'),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _goalController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            border: UnderlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) {
                              settings.updateGoalWeight(parsed);
                            } else {
                              _goalController.text = settings.goalWeight.toStringAsFixed(1);
                            }
                          },
                          onTapOutside: (_) {
                             final parsed = double.tryParse(_goalController.text);
                            if (parsed != null) {
                              settings.updateGoalWeight(parsed);
                            } else {
                              _goalController.text = settings.goalWeight.toStringAsFixed(1);
                            }
                            FocusManager.instance.primaryFocus?.unfocus();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('DISPLAY'),
              Card(
                child: ListTile(
                  title: const Text('Show Daily Data Dots', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Display individual log entries under the trend line on charts.'),
                  trailing: Switch(
                    value: settings.showDailyData,
                    onChanged: (val) => settings.updateShowDailyData(val),
                    activeColor: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
