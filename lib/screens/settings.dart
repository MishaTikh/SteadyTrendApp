import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart'; // for AppColors
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

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
    _goalController = TextEditingController(
      text: provider.goalWeight.toStringAsFixed(1),
    );
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
                      title: const Text(
                        'Preferred Unit',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                            double currentGoal =
                                double.tryParse(_goalController.text) ??
                                settings.goalWeight;
                            if (newUnit == 'KG') {
                              currentGoal = currentGoal / 2.20462;
                            } else if (newUnit == 'LBS') {
                              currentGoal = currentGoal * 2.20462;
                            }
                            _goalController.text = currentGoal.toStringAsFixed(
                              1,
                            );
                            settings.updateGoalWeight(currentGoal);
                          }

                          settings.updatePreferredUnit(newUnit);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return AppColors.primaryGreen;
                                }
                                return null;
                              }),
                          foregroundColor:
                              WidgetStateProperty.resolveWith<Color?>((
                                Set<WidgetState> states,
                              ) {
                                if (states.contains(WidgetState.selected)) {
                                  return Colors.white;
                                }
                                return AppColors.textDark;
                              }),
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text(
                        'Goal Weight',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('In ${settings.preferredUnit}'),
                      trailing: SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _goalController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
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
                              _goalController.text = settings.goalWeight
                                  .toStringAsFixed(1);
                            }
                          },
                          onTapOutside: (_) {
                            final parsed = double.tryParse(
                              _goalController.text,
                            );
                            if (parsed != null) {
                              settings.updateGoalWeight(parsed);
                            } else {
                              _goalController.text = settings.goalWeight
                                  .toStringAsFixed(1);
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
                  title: const Text(
                    'Show Daily Data Dots',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Display individual log entries under the trend line on charts.',
                  ),
                  trailing: Switch(
                    value: settings.showDailyData,
                    onChanged: (val) => settings.updateShowDailyData(val),
                    activeColor: AppColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle('NOTIFICATIONS'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text(
                        'Daily Reminder',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Receive a notification to log your weight.',
                      ),
                      trailing: Switch(
                        value: settings.isDailyReminderEnabled,
                        onChanged: (val) async {
                          if (val) {
                            bool hasPermission = await NotificationService()
                                .requestPermissions();
                            if (hasPermission) {
                              settings.updateDailyReminder(true);
                            } else {
                              // If permissions are not granted, ensure it stays off
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Notification permissions are required.',
                                    ),
                                  ),
                                );
                              }
                              settings.updateDailyReminder(false);
                            }
                          } else {
                            settings.updateDailyReminder(false);
                          }
                        },
                        activeColor: AppColors.primaryGreen,
                      ),
                    ),
                    if (settings.isDailyReminderEnabled) ...[
                      const Divider(height: 1),
                      ListTile(
                        title: const Text(
                          'Reminder Time',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _formatTime(settings.dailyReminderTime),
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.access_time,
                              color: AppColors.primaryGreen,
                            ),
                          ],
                        ),
                        onTap: () async {
                          final parts = settings.dailyReminderTime.split(':');
                          TimeOfDay initialTime = const TimeOfDay(
                            hour: 7,
                            minute: 0,
                          );
                          if (parts.length == 2) {
                            initialTime = TimeOfDay(
                              hour: int.tryParse(parts[0]) ?? 7,
                              minute: int.tryParse(parts[1]) ?? 0,
                            );
                          }

                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: initialTime,
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

                          if (picked != null) {
                            final newTime =
                                '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                            settings.updateDailyReminderTime(newTime);
                          }
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        final timeOfDay = TimeOfDay(hour: hour, minute: minute);

        // This requires access to BuildContext, but since this is just a helper,
        // we can format it manually or use material localizations.
        // For simplicity, formatting manually:
        final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
        int displayHour = timeOfDay.hourOfPeriod;
        if (displayHour == 0) displayHour = 12; // 12 AM or 12 PM

        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      }
    } catch (e) {
      // fallback
    }
    return timeStr;
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
